import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contributions.dart';
import 'feature_module.dart';

/// Persists which optional modules the user switched off.
abstract interface class ModuleEnablementStore {
  /// Emits the identifiers of modules that are currently switched on.
  Stream<Set<String>> watchEnabledOptionalModuleIdentifiers(List<FeatureModule> optionalModules);

  Future<void> setModuleEnabled(FeatureModule module, {required bool isEnabled});
}

/// Every module the app was built with, in registry order. Overridden by the app shell.
final registeredFeatureModulesProvider = Provider<List<FeatureModule>>(
  (ref) => throw UnimplementedError('registeredFeatureModulesProvider must be overridden'),
);

/// The version shown in Options and written into backups. Overridden
/// by the app shell with the version from its pubspec.
final applicationVersionProvider = Provider<String>((ref) => '0.0.0');

/// Restarts the whole app: closes the database, opens it again (moving a
/// prepared restore in place) and initialises every module afresh.
abstract interface class ApplicationRestarter {
  Future<void> restart();
}

/// Overridden by the app shell.
final applicationRestarterProvider = Provider<ApplicationRestarter>(
  (ref) => throw UnimplementedError('applicationRestarterProvider must be overridden'),
);

/// Overridden by the app shell with a store backed by preferences.
final moduleEnablementStoreProvider = Provider<ModuleEnablementStore>(
  (ref) => throw UnimplementedError('moduleEnablementStoreProvider must be overridden'),
);

/// The modules that are on right now: every always-enabled module plus the
/// optional ones the user has not switched off. Contributions (dashboard
/// cards, quick actions, Config sections, item visuals, insight charts) are
/// read from here, so switching a module off removes them without a restart.
final enabledFeatureModulesProvider = StreamProvider<List<FeatureModule>>((ref) {
  final registeredModules = ref.watch(registeredFeatureModulesProvider);
  final optionalModules = registeredModules
      .where((module) => module.availability.isOptional)
      .toList();
  if (optionalModules.isEmpty) return Stream.value(registeredModules);
  return ref
      .watch(moduleEnablementStoreProvider)
      .watchEnabledOptionalModuleIdentifiers(optionalModules)
      .map((enabledOptionalIdentifiers) {
        final enabledModules = registeredModules
            .where(
              (module) =>
                  !module.availability.isOptional ||
                  enabledOptionalIdentifiers.contains(module.moduleIdentifier),
            )
            .toList();
        return _withAtLeastOneStorageDomain(enabledModules, registeredModules);
      });
});

/// The app always shows at least one domain tab (architecture 10.7). Options
/// never lets the last one be switched off, but stored switches can still
/// say otherwise, for example after a module was removed; then the first
/// domain in tab order stays on.
List<FeatureModule> _withAtLeastOneStorageDomain(
  List<FeatureModule> enabledModules,
  List<FeatureModule> registeredModules,
) {
  if (enabledModules.any((module) => module.storageDomain != null)) return enabledModules;
  final domainModules = registeredModules.where((module) => module.storageDomain != null).toList()
    ..sort(
      (first, second) => first.storageDomain!.sortOrder.compareTo(second.storageDomain!.sortOrder),
    );
  if (domainModules.isEmpty) return enabledModules;
  final keptModule = domainModules.first;
  return [
    for (final module in registeredModules)
      if (identical(module, keptModule) || enabledModules.contains(module)) module,
  ];
}

/// Whether the user may switch [module] off now: every optional module may,
/// except the last storage domain that is still on.
bool canSwitchModuleOff(FeatureModule module, {required List<FeatureModule> enabledModules}) {
  if (module.storageDomain == null) return true;
  return enabledModules.any(
    (enabledModule) => enabledModule != module && enabledModule.storageDomain != null,
  );
}

/// The item visual provider of the first enabled module that has one (item
/// pictures), or `null` when none is on.
final enabledItemVisualProvider = Provider<ItemVisualProvider?>((ref) {
  final enabledModules = ref.watch(enabledFeatureModulesProvider).value ?? const [];
  for (final module in enabledModules) {
    if (module.itemVisualProvider case final itemVisualProvider?) return itemVisualProvider;
  }
  return null;
});

/// Reads the language the app shows, for texts made outside any screen, such
/// as notifications. Overridden by the app shell with the language chosen in
/// Config or else the phone's; English by default.
final applicationLocaleReaderProvider = Provider<Future<Locale> Function()>(
  (ref) =>
      () async => const Locale('en'),
);
