import 'dart:async';
import 'dart:ui';

import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import '../application_version.dart';
import '../l10n/generated/application_shell_localizations.dart';
import '../modules/module_registry.dart';
import '../modules/preferences_module_enablement_store.dart';
import '../routing/application_router.dart';
import 'application_platform_services.dart';
import 'unavailable_notification_services.dart';

/// The result of a successful start: the provider container with every
/// module wired in, and the router.
final class BootstrappedApplication {
  BootstrappedApplication({
    required this.providerContainer,
    required this.router,
    required StreamSubscription<String> notificationTapSubscription,
    required List<ProviderSubscription<Object?>> providerSubscriptions,
  }) : _notificationTapSubscription = notificationTapSubscription,
       _providerSubscriptions = providerSubscriptions;

  final ProviderContainer providerContainer;
  final GoRouter router;
  final StreamSubscription<String> _notificationTapSubscription;

  /// Language, theme and the module switches, listened to for the app's lifetime.
  final List<ProviderSubscription<Object?>> _providerSubscriptions;

  Future<void> dispose() async {
    await _notificationTapSubscription.cancel();
    for (final subscription in _providerSubscriptions) {
      subscription.close();
    }
    final registeredModules = providerContainer.read(registeredFeatureModulesProvider);
    for (final module in registeredModules) {
      await module.disposeModule();
    }
    router.dispose();
    await providerContainer.read(applicationDatabaseProvider).close();
    providerContainer.dispose();
  }
}

/// Starts the application (architecture document, section 8.2): opens the
/// encrypted database, collects modules and their provider overrides,
/// initialises every module (event subscriptions and start-up reconciliation)
/// and builds the router.
final class ApplicationBootstrapper {
  ApplicationBootstrapper({
    required ApplicationPlatformServices platformServices,
    required List<FeatureModule> registeredModules,
    Clock clock = const SystemClock(),
    IdentifierGenerator identifierGenerator = const UuidIdentifierGenerator(),
    LocalLogger logger = const DeveloperConsoleLogger(),
  }) : _platformServices = platformServices,
       _registeredModules = registeredModules,
       _clock = clock,
       _identifierGenerator = identifierGenerator,
       _logger = logger;

  final ApplicationPlatformServices _platformServices;
  final List<FeatureModule> _registeredModules;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;
  final LocalLogger _logger;

  /// [applicationRestarter] is handed to modules, for restoring a backup.
  Future<BootstrappedApplication> bootstrap({
    required ApplicationRestarter applicationRestarter,
  }) async {
    assert(() {
      verifyModuleRegistry(_registeredModules);
      return true;
    }(), 'Module registry is inconsistent');

    final database = await _platformServices.openDatabase(
      clock: _clock,
      applicationVersion: applicationVersion,
    );
    final notificationServices = await _initializeNotificationServices();
    final domainEventBus = InProcessDomainEventBus(logger: _logger);
    final moduleDependencies = ModuleDependencies(
      clock: _clock,
      identifierGenerator: _identifierGenerator,
      domainEventBus: domainEventBus,
      logger: _logger,
    );

    final providerContainer = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        mediaFileStoreProvider.overrideWithValue(_platformServices.createMediaFileStore()),
        receiptMediaFileStoreProvider.overrideWithValue(
          _platformServices.createReceiptMediaFileStore(),
        ),
        clockProvider.overrideWithValue(_clock),
        identifierGeneratorProvider.overrideWithValue(_identifierGenerator),
        localLoggerProvider.overrideWithValue(_logger),
        domainEventBusProvider.overrideWithValue(domainEventBus),
        notificationSchedulerProvider.overrideWithValue(notificationServices.scheduler),
        notificationPermissionServiceProvider.overrideWithValue(
          notificationServices.permissionService,
        ),
        notificationTapRouterProvider.overrideWithValue(notificationServices.tapRouter),
        registeredFeatureModulesProvider.overrideWithValue(_registeredModules),
        applicationVersionProvider.overrideWithValue(applicationVersion),
        applicationRestarterProvider.overrideWithValue(applicationRestarter),
        applicationLocaleReaderProvider.overrideWith((ref) {
          final preferencesStore = ref.watch(preferencesStoreProvider);
          return () async =>
              SupportedLocales.forLanguageCode(
                await preferencesStore.read(ApplicationPreferenceKeys.languageCode),
              ) ??
              SupportedLocales.resolve(PlatformDispatcher.instance.locales);
        }),
        moduleEnablementStoreProvider.overrideWith(
          (ref) => PreferencesModuleEnablementStore(ref.watch(preferencesStoreProvider)),
        ),
        for (final module in _registeredModules)
          ...module.buildProviderOverrides(moduleDependencies),
      ],
    );

    // Modules start knowing which domains are switched off, so nothing is
    // planned for a paused domain and replanned a moment later.
    final moduleSwitchesSubscription = providerContainer.listen(
      enabledFeatureModulesProvider,
      (_, _) {},
    );
    await providerContainer.read(enabledFeatureModulesProvider.future);

    final initializationContext = _ContainerModuleInitializationContext(
      providerContainer: providerContainer,
      domainEventBus: domainEventBus,
      clock: _clock,
      logger: _logger,
    );
    for (final module in _registeredModules) {
      try {
        await module.initializeModule(initializationContext);
      } on Object catch (error, stackTrace) {
        // One broken module must not keep the user from their data.
        _logger.log(
          LogSeverity.error,
          'Module ${module.moduleIdentifier} failed to initialise',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    final appearanceSubscriptions = await _applyLanguageAndTheme(providerContainer);

    final router = buildApplicationRouter(
      registeredModules: _registeredModules,
      initialLocation:
          await _moduleLaunchRoutePath(initializationContext) ??
          await notificationServices.tapRouter.launchRoutePath(),
    );
    // Cancelled in BootstrappedApplication.dispose.
    // ignore: cancel_subscriptions
    final notificationTapSubscription = notificationServices.tapRouter.tappedRoutePaths.listen(
      router.go,
    );
    return BootstrappedApplication(
      providerContainer: providerContainer,
      router: router,
      notificationTapSubscription: notificationTapSubscription,
      providerSubscriptions: [...appearanceSubscriptions, moduleSwitchesSubscription],
    );
  }

  /// Loads the language and theme before the first frame, so the app does
  /// not flash in the phone's language, and keeps the in-app language choice
  /// and the system's per-app language setting the same (decision D14).
  Future<List<ProviderSubscription<Object?>>> _applyLanguageAndTheme(
    ProviderContainer providerContainer,
  ) async {
    final preferencesStore = providerContainer.read(preferencesStoreProvider);
    final storedLanguageCode = await preferencesStore.read(ApplicationPreferenceKeys.languageCode);
    final perAppLanguageCode = await _platformServices.readPerAppLanguageCode();
    if (perAppLanguageCode != null && perAppLanguageCode != storedLanguageCode) {
      if (perAppLanguageCode.isNotEmpty &&
          SupportedLocales.forLanguageCode(perAppLanguageCode) != null) {
        // Changed in the system settings while the app was closed.
        await preferencesStore.write(ApplicationPreferenceKeys.languageCode, perAppLanguageCode);
      } else {
        await _platformServices.writePerAppLanguageCode(storedLanguageCode);
      }
    }

    final languageSubscription = providerContainer.listen(languageCodeChoiceProvider, (
      previous,
      next,
    ) {
      final previousLanguageCode = previous?.value;
      final nextLanguageCode = next.value;
      if (previousLanguageCode != null &&
          nextLanguageCode != null &&
          previousLanguageCode != nextLanguageCode) {
        unawaited(_platformServices.writePerAppLanguageCode(nextLanguageCode));
      }
    });
    final themeSubscription = providerContainer.listen(themeChoiceProvider, (_, _) {});
    await providerContainer.read(languageCodeChoiceProvider.future);
    await providerContainer.read(themeChoiceProvider.future);
    return [languageSubscription, themeSubscription];
  }

  Future<String?> _moduleLaunchRoutePath(ModuleInitializationContext context) async {
    for (final module in _registeredModules) {
      try {
        final launchRoutePath = await module.resolveLaunchRoutePath(context);
        if (launchRoutePath != null) return launchRoutePath;
      } on Object catch (error, stackTrace) {
        _logger.log(
          LogSeverity.error,
          'Module ${module.moduleIdentifier} could not pick a launch route',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return null;
  }

  Future<NotificationServices> _initializeNotificationServices() async {
    final shellLocalizations = lookupApplicationShellLocalizations(
      SupportedLocales.resolve(PlatformDispatcher.instance.locales),
    );
    try {
      return await _platformServices.initializeNotificationServices(
        NotificationChannelTexts(
          storageRemindersName: shellLocalizations.notificationChannelStorageRemindersName,
          storageRemindersDescription:
              shellLocalizations.notificationChannelStorageRemindersDescription,
          backupRemindersName: shellLocalizations.notificationChannelBackupRemindersName,
          backupRemindersDescription:
              shellLocalizations.notificationChannelBackupRemindersDescription,
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.log(
        LogSeverity.error,
        'Notifications are unavailable',
        error: error,
        stackTrace: stackTrace,
      );
      const unavailableServices = UnavailableNotificationServices();
      return (
        scheduler: unavailableServices,
        permissionService: unavailableServices,
        tapRouter: unavailableServices,
      );
    }
  }
}

final class _ContainerModuleInitializationContext implements ModuleInitializationContext {
  _ContainerModuleInitializationContext({
    required ProviderContainer providerContainer,
    required this.domainEventBus,
    required this.clock,
    required this.logger,
  }) : _providerContainer = providerContainer;

  final ProviderContainer _providerContainer;

  @override
  final DomainEventBus domainEventBus;

  @override
  final Clock clock;

  @override
  final LocalLogger logger;

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _providerContainer.read(provider);
}
