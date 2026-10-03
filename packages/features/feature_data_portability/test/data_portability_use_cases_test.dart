import 'dart:io';
import 'dart:typed_data';

import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_data_portability/feature_data_portability.dart';
import 'package:feature_data_portability/src/application/backup_file_store.dart';
import 'package:feature_data_portability/src/application/csv_export_use_case.dart';
import 'package:feature_data_portability/src/application/data_portability_providers.dart';
import 'package:feature_data_portability/src/domain/data_portability_failure.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeFileStore implements BackupFileStore {
  _FakeFileStore(this.scratchParent);

  final Directory scratchParent;
  bool userCancels = false;
  String? savedFileName;
  Uint8List? savedBytes;
  String? fileToPick;

  @override
  Future<bool> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (userCancels) return false;
    savedFileName = fileName;
    savedBytes = bytes;
    return true;
  }

  @override
  Future<String?> pickFile() async => fileToPick;

  @override
  Future<Directory> createScratchDirectory() => scratchParent.createTemp('scratch');
}

final class _RecordingRestarter implements ApplicationRestarter {
  int restartCount = 0;

  @override
  Future<void> restart() async => restartCount++;
}

final class _EnglishCatalogNames implements CatalogNames {
  const _EnglishCatalogNames();

  @override
  String? categoryName(String catalogKey) => catalogKey == 'meatAndFish' ? 'Meat and fish' : null;

  @override
  String? productName(String catalogKey) => catalogKey == 'mincedMeat' ? 'Minced meat' : null;
}

final class _EnglishLayoutDefaultNames implements LayoutDefaultNames {
  const _EnglishLayoutDefaultNames();

  @override
  String freezerName(StorageKind storageKind) => 'Freezer';

  @override
  String compartmentName(StorageKind storageKind, int number) => 'Drawer $number';

  @override
  String removedName(String name) => '$name (removed)';
}

const _password = 'freezer password';

void main() {
  late Directory temporaryDirectory;
  late ApplicationDatabase database;
  late ProviderContainer container;
  late _FakeFileStore fileStore;
  late InMemoryMediaFileStore mediaFileStore;
  late _RecordingRestarter restarter;
  late FakeNotificationServices notificationServices;
  final clock = FixedClock(DateTime.utc(2026, 10, 2, 12));

  setUp(() async {
    clock.setTo(DateTime.utc(2026, 10, 2, 12));
    temporaryDirectory = await Directory.systemTemp.createTemp('data_portability_test');
    database = await EncryptedDatabaseOpener(
      keyStore: InMemoryDatabaseEncryptionKeyStore(),
      clock: clock,
      applicationVersion: '0.3.0',
      privateDirectoryProvider: () async => temporaryDirectory,
    ).open();
    fileStore = _FakeFileStore(temporaryDirectory);
    mediaFileStore = InMemoryMediaFileStore();
    restarter = _RecordingRestarter();
    notificationServices = FakeNotificationServices();
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: SequentialIdentifierGenerator(),
      domainEventBus: InProcessDomainEventBus(logger: RecordingLogger()),
      logger: RecordingLogger(),
    );
    container = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(clock),
        identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
        domainEventBusProvider.overrideWithValue(dependencies.domainEventBus),
        applicationVersionProvider.overrideWithValue('0.3.0'),
        applicationRestarterProvider.overrideWithValue(restarter),
        for (final module in const [
          StorageLayoutFeatureModule(),
          ProductCatalogFeatureModule(),
          InventoryFeatureModule(),
        ])
          ...module.buildProviderOverrides(dependencies),
        backupFileStoreProvider.overrideWithValue(fileStore),
        mediaFileStoreProvider.overrideWithValue(mediaFileStore),
        notificationSchedulerProvider.overrideWithValue(notificationServices),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  Future<String> saveBackup({bool includesPictures = true}) async {
    final result = await container
        .read(createBackupUseCaseProvider)
        .execute(
          password: _password,
          repeatedPassword: _password,
          includesPictures: includesPictures,
        );
    expect(result.valueOrNull, isTrue);
    final backupFile = File(
      '${temporaryDirectory.path}/${includesPictures ? '' : 'no-pictures-'}'
      '${fileStore.savedFileName}',
    )..writeAsBytesSync(fileStore.savedBytes!);
    return backupFile.path;
  }

  test('saves a backup and remembers when', () async {
    await saveBackup();

    expect(fileStore.savedFileName, 'freezer-backup-2026-10-02.freezerbackup');
    expect(
      await container
          .read(preferencesStoreProvider)
          .read(DataPortabilityPreferenceKeys.lastBackupAt),
      clock.nowUtc(),
    );
    expect(temporaryDirectory.listSync().whereType<Directory>(), isEmpty);
  });

  test('a cancelled save is not counted as a backup', () async {
    fileStore.userCancels = true;

    final result = await container
        .read(createBackupUseCaseProvider)
        .execute(password: _password, repeatedPassword: _password);

    expect(result.valueOrNull, isFalse);
    expect(
      await container
          .read(preferencesStoreProvider)
          .read(DataPortabilityPreferenceKeys.lastBackupAt),
      isNull,
    );
  });

  test('restoring checks the password, then prepares the restore and restarts', () async {
    final backupPath = await saveBackup();
    final restoreBackup = container.read(restoreBackupUseCaseProvider);

    expect(
      (await restoreBackup.inspect(
        backupPath: backupPath,
        password: 'wrong password',
      )).failureOrNull,
      isA<BackupNotReadable>(),
    );
    expect(
      (await restoreBackup.inspect(
        backupPath: backupPath,
        password: _password,
      )).valueOrNull?.createdAt,
      clock.nowUtc(),
    );
    expect(restarter.restartCount, 0);

    await restoreBackup.restore(backupPath: backupPath, password: _password);

    expect(restarter.restartCount, 1);
    expect(File('${temporaryDirectory.path}/freezer.sqlite.restoring').existsSync(), isTrue);
  });

  test('backups carry the photos unless left out; a restore writes them back first', () async {
    final pictureFileName = createMediaFileName();
    final thumbnailFileName = createMediaFileName();
    final pictureBytes = Uint8List.fromList(List.generate(40000, (index) => index % 251));
    mediaFileStore.filesByName
      ..[pictureFileName] = pictureBytes
      ..[thumbnailFileName] = Uint8List.fromList([1, 2, 3]);
    await database.itemPicturesDao.insertPicture(
      ItemPictureRow(
        itemPictureIdentifier: 'picture-1',
        ownerKind: 'product',
        ownerIdentifier: 'product-1',
        encryptedFileName: pictureFileName,
        thumbnailFileName: thumbnailFileName,
        widthPixels: 1600,
        heightPixels: 1200,
        byteSize: pictureBytes.length,
        createdAt: clock.nowUtc(),
      ),
    );
    expect(await container.read(createBackupUseCaseProvider).countPictures(), 1);
    final withPicturesPath = await saveBackup();
    final withoutPicturesPath = await saveBackup(includesPictures: false);
    expect(
      File(withoutPicturesPath).lengthSync(),
      lessThan(File(withPicturesPath).lengthSync() - pictureBytes.length),
    );
    final restoreBackup = container.read(restoreBackupUseCaseProvider);

    // Restored on a phone whose picture folder holds something else.
    mediaFileStore.filesByName
      ..clear()
      ..[createMediaFileName()] = Uint8List.fromList([9]);
    final withoutPictures = await restoreBackup.restore(
      backupPath: withoutPicturesPath,
      password: _password,
    );
    expect(withoutPictures.valueOrNull?.pictureCount, 0);
    expect(mediaFileStore.filesByName, hasLength(1));

    final withPictures = await restoreBackup.restore(
      backupPath: withPicturesPath,
      password: _password,
    );
    expect(withPictures.valueOrNull?.pictureCount, 1);
    expect(mediaFileStore.filesByName[pictureFileName], pictureBytes);
    expect(mediaFileStore.filesByName[thumbnailFileName], [1, 2, 3]);
  });

  test('exports the freezer contents and the history as CSV', () async {
    await const ProductCatalogFeatureModule().initializeModule(
      _ContainerInitializationContext(container),
    );
    final freezerCreation = await container
        .read(createFreezerFromTemplateUseCaseProvider)
        .execute(
          template: FreezerTemplate.uprightWithThreeDrawers,
          defaultNames: const _EnglishLayoutDefaultNames(),
        );
    expect(freezerCreation.isSuccess, isTrue);
    final layout = await container.read(storageLayoutQueryServiceProvider).readStorageLayout();
    final catalog = await container.read(productCatalogQueryServiceProvider).readCatalog();
    final mincedMeat = catalog.activeProducts.firstWhere(
      (product) => product.catalogKey == 'mincedMeat',
    );
    final batchIdentifier =
        (await container
                .read(addStockBatchUseCaseProvider)
                .execute(
                  AddStockBatchCommand(
                    productIdentifier: mincedMeat.identifier,
                    compartmentIdentifier: layout.activeCompartments.first.identifier,
                    quantity: const Quantity(amountInBaseUnits: 500, unit: QuantityUnit.gram),
                    frozenOn: CalendarDate(2026, 9, 1),
                    note: 'For lasagne, "the good one"',
                  ),
                ))
            .valueOrNull!;
    await container
        .read(consumeStockUseCaseProvider)
        .execute(
          stockBatchIdentifier: batchIdentifier,
          quantity: const Quantity(amountInBaseUnits: 250, unit: QuantityUnit.gram),
        );
    final texts = CsvExportTexts(
      contentsHeader: const [
        'Product',
        'Category',
        'Amount',
        'Unit',
        'Frozen on',
        'Drawer',
        'Note',
      ],
      historyHeader: const ['Time', 'Change', 'Product', 'Amount', 'Unit', 'Drawer', 'Reason'],
      catalogNames: const _EnglishCatalogNames(),
      layoutDefaultNames: const _EnglishLayoutDefaultNames(),
      movementKindName: (kind) => kind.name,
      discardReasonName: (reason) => reason.name,
      unitSymbol: (unit) => unit == QuantityUnit.gram ? 'g' : unit.name,
    );
    final csvExport = container.read(csvExportUseCaseProvider);

    final contentsLines = (await csvExport.buildCsv(
      CsvExportKind.freezerContents,
      texts,
    )).split('\r\n');
    final historyLines = (await csvExport.buildCsv(CsvExportKind.history, texts)).split('\r\n');

    expect(
      contentsLines[1],
      'Minced meat,Meat and fish,250,g,2026-09-01,Drawer 1,"For lasagne, ""the good one"""',
    );
    expect(historyLines, hasLength(4));
    expect(historyLines[1], contains(',added,Minced meat,500,g,Drawer 1,'));
    expect(historyLines[2], contains(',consumed,Minced meat,-250,g,Drawer 1,'));
  });

  test('schedules the backup reminder 90 days after food is stored or backed up', () async {
    await const ProductCatalogFeatureModule().initializeModule(
      _ContainerInitializationContext(container),
    );
    await container
        .read(createFreezerFromTemplateUseCaseProvider)
        .execute(
          template: FreezerTemplate.uprightWithThreeDrawers,
          defaultNames: const _EnglishLayoutDefaultNames(),
        );
    await const DataPortabilityFeatureModule().initializeModule(
      _ContainerInitializationContext(container),
    );
    expect(notificationServices.scheduledRequests, isEmpty);

    final layout = await container.read(storageLayoutQueryServiceProvider).readStorageLayout();
    final catalog = await container.read(productCatalogQueryServiceProvider).readCatalog();
    await container
        .read(addStockBatchUseCaseProvider)
        .execute(
          AddStockBatchCommand(
            productIdentifier: catalog.activeProducts.first.identifier,
            compartmentIdentifier: layout.activeCompartments.first.identifier,
            quantity: Quantity(
              amountInBaseUnits: 1,
              unit: catalog.activeProducts.first.canonicalUnit,
            ),
            frozenOn: CalendarDate(2026, 10, 1),
          ),
        );
    final firstReminder = notificationServices.scheduledRequests[7200];
    clock.advanceBy(const Duration(days: 10));
    await saveBackup();
    await container.read(backupReminderReplanningCoordinatorProvider).requestRecomputation();
    final reminderAfterBackup = notificationServices.scheduledRequests[7200];

    expect(firstReminder?.scheduledForLocalTime, DateTime(2026, 12, 31, 18));
    expect(firstReminder?.title, 'Time for a backup');
    expect(firstReminder?.tapRoutePath, DataPortabilityRoutes.backup);
    expect(reminderAfterBackup?.scheduledForLocalTime, DateTime(2027, 1, 10, 18));
  });
}

/// Lets a test run a module's start-up work, such as seeding the catalog,
/// against the test's provider container.
final class _ContainerInitializationContext implements ModuleInitializationContext {
  _ContainerInitializationContext(this._container);

  final ProviderContainer _container;

  @override
  Clock get clock => _container.read(clockProvider);

  @override
  DomainEventBus get domainEventBus => _container.read(domainEventBusProvider);

  @override
  LocalLogger get logger => RecordingLogger();

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _container.read(provider);
}
