import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/media_file_backup_file_access.dart';
import '../domain/backup_policies.dart';
import 'backup_file_store.dart';
import 'backup_use_cases.dart';
import 'csv_export_use_case.dart';
import 'replan_backup_reminder_use_case.dart';

abstract final class DataPortabilityPreferenceKeys {
  static final PreferenceKey<DateTime?> lastBackupAt = PreferenceKey.optionalInstant(
    moduleNamespace: 'data_portability',
    name: 'last_backup_at',
  );
}

/// Bound to the system dialogs by the module's provider overrides.
final backupFileStoreProvider = Provider<BackupFileStore>(
  (ref) => throw UnimplementedError('backupFileStoreProvider must be overridden'),
);

/// The picture files that travel inside backups.
final backupPictureFilesProvider = Provider<BackupFileAccess>(
  (ref) => MediaFileBackupFileAccess(ref.watch(mediaFileStoreProvider)),
);

final lastBackupAtProvider = StreamProvider<DateTime?>(
  (ref) => ref.watch(preferencesStoreProvider).watch(DataPortabilityPreferenceKeys.lastBackupAt),
);

/// Whether the home dashboard should suggest a backup.
final isBackupDueProvider = Provider<bool>((ref) {
  final lastBackupAt = ref.watch(lastBackupAtProvider);
  final activeBatches = ref.watch(_activeBatchesProvider).value;
  if (!lastBackupAt.hasValue || activeBatches == null) return false;
  return BackupReminderPolicy.isBackupDue(
    lastBackupAt: lastBackupAt.value,
    now: ref.watch(clockProvider).nowUtc(),
    hasStoredFood: activeBatches.isNotEmpty,
  );
});

final _activeBatchesProvider = StreamProvider<List<StockBatch>>(
  (ref) => ref.watch(inventoryQueryServiceProvider).watchActiveBatches(),
);

final createBackupUseCaseProvider = Provider<CreateBackupUseCase>(
  (ref) => CreateBackupUseCase(
    backupGateway: ref.watch(databaseBackupGatewayProvider),
    pictureFiles: ref.watch(backupPictureFilesProvider),
    fileStore: ref.watch(backupFileStoreProvider),
    preferencesStore: ref.watch(preferencesStoreProvider),
    clock: ref.watch(clockProvider),
    applicationVersion: ref.watch(applicationVersionProvider),
  ),
);

final restoreBackupUseCaseProvider = Provider<RestoreBackupUseCase>(
  (ref) => RestoreBackupUseCase(
    backupGateway: ref.watch(databaseBackupGatewayProvider),
    pictureFiles: ref.watch(backupPictureFilesProvider),
    applicationRestarter: ref.watch(applicationRestarterProvider),
  ),
);

final csvExportUseCaseProvider = Provider<CsvExportUseCase>(
  (ref) => CsvExportUseCase(
    inventory: ref.watch(inventoryQueryServiceProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
    fileStore: ref.watch(backupFileStoreProvider),
    clock: ref.watch(clockProvider),
  ),
);

final replanBackupReminderUseCaseProvider = Provider<ReplanBackupReminderUseCase>(
  (ref) => ReplanBackupReminderUseCase(
    inventory: ref.watch(inventoryQueryServiceProvider),
    preferencesStore: ref.watch(preferencesStoreProvider),
    reconciler: ref.watch(scheduledNotificationReconcilerProvider),
    readApplicationLocale: ref.watch(applicationLocaleReaderProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Replans the backup reminder when food comes or goes, after every backup
/// and when the app language changes.
final backupReminderReplanningCoordinatorProvider = Provider<RecomputationCoordinator>((ref) {
  final domainEventBus = ref.watch(domainEventBusProvider);
  final preferencesStore = ref.watch(preferencesStoreProvider);
  final coordinator = RecomputationCoordinator(
    description: 'the backup reminder',
    subscribeToEvents: (requestRecomputation) => [
      domainEventBus.subscribe<StockBatchEvent>((_) => requestRecomputation()),
    ],
    settingChanges: [
      preferencesStore.watch(DataPortabilityPreferenceKeys.lastBackupAt),
      preferencesStore.watch(ApplicationPreferenceKeys.languageCode),
    ],
    recompute: ref.watch(replanBackupReminderUseCaseProvider).execute,
    logger: ref.watch(localLoggerProvider),
  );
  ref.onDispose(coordinator.stop);
  return coordinator;
});
