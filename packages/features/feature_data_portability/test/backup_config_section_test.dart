import 'dart:async';
import 'dart:io';

import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_design_system/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_data_portability/feature_data_portability.dart';
import 'package:feature_data_portability/src/application/backup_file_store.dart';
import 'package:feature_data_portability/src/application/data_portability_providers.dart';
import 'package:feature_data_portability/src/presentation/backup_widgets.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RememberingFileStore implements BackupFileStore {
  _RememberingFileStore(this.scratchParent);

  final Directory scratchParent;
  String? savedFileName;
  Uint8List? savedBytes;

  /// While set, the save dialog stays open until the test answers it:
  /// `true` saves, `false` cancels.
  Completer<bool>? openSaveDialog;
  bool isSaveDialogOpen = false;

  /// Thrown by the save dialog, as a platform error would be.
  Exception? saveError;

  @override
  Future<bool> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final error = saveError;
    if (error != null) throw error;
    isSaveDialogOpen = true;
    final isSaved = await (openSaveDialog?.future ?? Future.value(true));
    isSaveDialogOpen = false;
    if (isSaved) {
      savedFileName = fileName;
      savedBytes = bytes;
    }
    return isSaved;
  }

  @override
  Future<String?> pickFile() async => null;

  @override
  Future<Directory> createScratchDirectory() => scratchParent.createTemp('scratch');
}

void main() {
  late Directory temporaryDirectory;
  late ApplicationDatabase database;
  late ProviderContainer container;
  late _RememberingFileStore fileStore;
  late InMemoryMediaFileStore mediaFileStore;
  final clock = FixedClock(DateTime.utc(2026, 10, 2, 12));

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('backup_section_test');
    database = createInMemoryApplicationDatabase();
    fileStore = _RememberingFileStore(temporaryDirectory);
    mediaFileStore = InMemoryMediaFileStore();
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
        for (final module in const [
          StorageLayoutFeatureModule(),
          ProductCatalogFeatureModule(),
          InventoryFeatureModule(),
        ])
          ...module.buildProviderOverrides(dependencies),
        backupFileStoreProvider.overrideWithValue(fileStore),
        mediaFileStoreProvider.overrideWithValue(mediaFileStore),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  testWidgets('saves a password-protected backup from the Config section', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: const DataPortabilityFeatureModule().localizationDelegates,
          home: const Scaffold(body: SingleChildScrollView(child: BackupConfigSection())),
        ),
      ),
    );
    await _settle(tester);
    expect(find.text('No backup yet'), findsOneWidget);

    await tester.tap(find.text('Save backup'));
    await _settle(tester);
    // Nothing to leave out without photos.
    expect(find.text('Include photos'), findsNothing);
    final passwordFields = find.byType(TextField);
    await tester.enterText(passwordFields.at(0), 'short');
    await tester.enterText(passwordFields.at(1), 'short');
    await tester.tap(find.widgetWithText(FilledButton, 'Save backup').last);
    await _settle(tester);
    expect(find.text('At least 8 characters.'), findsOneWidget);
    expect(fileStore.savedBytes, isNull);

    await tester.enterText(passwordFields.at(0), 'freezer password');
    await tester.enterText(passwordFields.at(1), 'freezer password');
    await tester.tap(find.widgetWithText(FilledButton, 'Save backup').last);
    await _settleUntilFound(tester, find.text('Backup saved'));

    expect(fileStore.savedFileName, 'foodie-backup-2026-10-02.foodiebackup');
    expect(fileStore.savedBytes, isNotEmpty);
    expect(find.text('No backup yet'), findsNothing);
    expect(find.text('Working on your backup…'), findsNothing);
  });

  testWidgets('the progress dialog never stays: not over the save dialog, nor after a cancel or '
      'a failed save', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: const DataPortabilityFeatureModule().localizationDelegates,
          home: const Scaffold(body: SingleChildScrollView(child: BackupConfigSection())),
        ),
      ),
    );
    await _settle(tester);

    Future<void> startBackup() async {
      await tester.tap(find.text('Save backup'));
      await _settle(tester);
      final passwordFields = find.byType(TextField);
      await tester.enterText(passwordFields.at(0), 'freezer password');
      await tester.enterText(passwordFields.at(1), 'freezer password');
      await tester.tap(find.widgetWithText(FilledButton, 'Save backup').last);
    }

    // The system's save dialog is open: the app shows no spinner behind it,
    // so a dialog that never answers cannot leave one behind.
    final saveDialog = fileStore.openSaveDialog = Completer<bool>();
    await startBackup();
    await _settleUntil(tester, () => fileStore.isSaveDialogOpen);
    await tester.pumpAndSettle();
    expect(find.text('Working on your backup…'), findsNothing);
    expect(find.text('Protect your backup'), findsNothing);
    saveDialog.complete(false);
    await _settle(tester);
    expect(find.text('Backup saved'), findsNothing);
    expect(find.text('No backup yet'), findsOneWidget);

    fileStore
      ..openSaveDialog = null
      ..saveError = PlatformException(code: 'explorer_not_found');
    await startBackup();
    await _settleUntilFound(tester, find.text('The backup could not be saved.'));
    expect(find.text('Working on your backup…'), findsNothing);
    expect(find.text('No backup yet'), findsOneWidget);
  });

  testWidgets('offers to leave the photos out', (tester) async {
    final pictureFileName = createMediaFileName();
    final thumbnailFileName = createMediaFileName();
    mediaFileStore.filesByName
      ..[pictureFileName] = Uint8List(2000)
      ..[thumbnailFileName] = Uint8List(200);
    await tester.runAsync(
      () => database.itemPicturesDao.insertPicture(
        ItemPictureRow(
          itemPictureIdentifier: 'picture-1',
          ownerKind: 'product',
          ownerIdentifier: 'product-1',
          encryptedFileName: pictureFileName,
          thumbnailFileName: thumbnailFileName,
          widthPixels: 1600,
          heightPixels: 1200,
          byteSize: 2000,
          createdAt: clock.nowUtc(),
        ),
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: const DataPortabilityFeatureModule().localizationDelegates,
          home: const Scaffold(body: SingleChildScrollView(child: BackupConfigSection())),
        ),
      ),
    );
    await _settle(tester);

    await tester.tap(find.text('Save backup'));
    await _settle(tester);
    expect(find.text('1 photo, about 300 KB. Leave it out for a smaller file.'), findsOneWidget);
    await tester.tap(find.text('Include photos'));
    final passwordFields = find.byType(TextField);
    await tester.enterText(passwordFields.at(0), 'freezer password');
    await tester.enterText(passwordFields.at(1), 'freezer password');
    await tester.tap(find.widgetWithText(FilledButton, 'Save backup').last);
    await _settleUntilFound(tester, find.text('Backup saved'));

    final manifest = await tester.runAsync(() async {
      final backupFile = File('${temporaryDirectory.path}/saved.foodiebackup')
        ..writeAsBytesSync(fileStore.savedBytes!);
      final inspection = await DatabaseBackupGateway(
        database,
      ).inspectBackup(backupPath: backupFile.path, password: 'freezer password');
      return inspection.valueOrNull;
    });
    expect(manifest?.pictureCount, 0);
  });
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}

Future<void> _settleUntil(WidgetTester tester, bool Function() condition) async {
  for (var attempt = 0; attempt < 40 && !condition(); attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(condition(), isTrue);
}

/// The backup itself runs real database work, which needs a few rounds of
/// real time before its result reaches the screen.
Future<void> _settleUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsOneWidget);
}
