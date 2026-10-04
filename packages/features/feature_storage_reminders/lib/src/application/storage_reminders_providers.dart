import 'dart:async';

import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/storage_reminder_settings.dart';
import '../l10n/generated/storage_reminders_localizations.dart';
import 'localized_storage_reminder_notification_texts.dart';
import 'replan_storage_reminders_use_case.dart';
import 'storage_reminder_notification_texts.dart';
import 'storage_reminder_settings_store.dart';

final storageReminderSettingsStoreProvider = Provider<StorageReminderSettingsStore>(
  (ref) => StorageReminderSettingsStore(ref.watch(preferencesStoreProvider)),
);

final storageReminderSettingsProvider = StreamProvider<StorageReminderSettings>(
  (ref) => ref.watch(storageReminderSettingsStoreProvider).watch(),
);

/// Loads the notification words in the language the app shows.
final storageReminderNotificationTextsLoaderProvider =
    Provider<Future<StorageReminderNotificationTexts> Function()>((ref) {
      final readApplicationLocale = ref.watch(applicationLocaleReaderProvider);
      final catalogContributions = ref.watch(registeredCatalogContributionsProvider);
      return () async {
        final locale = await readApplicationLocale();
        return LocalizedStorageReminderNotificationTexts(
          lookupStorageRemindersLocalizations(locale),
          ContributedCatalogNames(catalogContributions, locale),
        );
      };
    });

final replanStorageRemindersUseCaseProvider = Provider<ReplanStorageRemindersUseCase>(
  (ref) => ReplanStorageRemindersUseCase(
    inventory: ref.watch(inventoryQueryServiceProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
    readPausedDomains: () => ref.read(pausedStorageDomainIdentifiersProvider),
    settingsStore: ref.watch(storageReminderSettingsStoreProvider),
    reconciler: ref.watch(scheduledNotificationReconcilerProvider),
    loadNotificationTexts: ref.watch(storageReminderNotificationTextsLoaderProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Replans the digest after every change to the inventory, to storage times
/// in the catalog, to the reminder settings or to the app language.
final storageReminderReplanningCoordinatorProvider = Provider<RecomputationCoordinator>((ref) {
  final domainEventBus = ref.watch(domainEventBusProvider);
  final preferencesStore = ref.watch(preferencesStoreProvider);
  final coordinator = RecomputationCoordinator(
    description: 'storage reminders',
    subscribeToEvents: (requestRecomputation) => [
      domainEventBus.subscribe<StockBatchEvent>((_) => requestRecomputation()),
      domainEventBus.subscribe<ProductUpdated>((_) => requestRecomputation()),
      domainEventBus.subscribe<ProductArchived>((_) => requestRecomputation()),
      domainEventBus.subscribe<CategoryUpdated>((_) => requestRecomputation()),
    ],
    settingChanges: [
      ref.watch(storageReminderSettingsStoreProvider).watch(),
      preferencesStore.watch(ApplicationPreferenceKeys.languageCode),
    ],
    recompute: ref.watch(replanStorageRemindersUseCaseProvider).execute,
    logger: ref.watch(localLoggerProvider),
  );
  // Switching a domain off or on again replans; listening keeps the
  // switches loaded for the use case.
  ref.listen(pausedStorageDomainIdentifiersProvider, (previous, next) {
    if (previous != null && !(previous.length == next.length && previous.containsAll(next))) {
      unawaited(coordinator.requestRecomputation());
    }
  });
  ref.onDispose(coordinator.stop);
  return coordinator;
});

/// What the "Use soon" card and screen list: batches that are no longer
/// fresh, the earliest last good day first; `null` while loading.
final eatSoonItemsProvider = Provider<List<InventoryItem>?>((ref) {
  final overview = ref.watch(inventoryOverviewProvider).value;
  if (overview == null) return null;
  return sortedByUseBy([
    for (final item in overview.items)
      if (item.useByStatus != UseByStatus.fresh) item,
  ]);
});
