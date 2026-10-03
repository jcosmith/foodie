import 'dart:io';
import 'dart:typed_data';

import 'package:core_database/core_database.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Keeps the saved backup on disk and offers it again when a file is picked,
/// like saving to and opening from the phone's Downloads folder.
final class _DownloadsFolderFileStore implements BackupFileStore {
  _DownloadsFolderFileStore(this.downloadsDirectory);

  final Directory downloadsDirectory;
  String? savedFilePath;

  @override
  Future<bool> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final savedFile = File('${downloadsDirectory.path}/$fileName');
    await savedFile.writeAsBytes(bytes);
    savedFilePath = savedFile.path;
    return true;
  }

  @override
  Future<String?> pickFile() async => savedFilePath;

  @override
  Future<Directory> createScratchDirectory() => downloadsDirectory.createTemp('scratch');
}

final class _RecordingApplicationRestarter implements ApplicationRestarter {
  int restartCount = 0;

  @override
  Future<void> restart() async => restartCount++;
}

/// The Config tab sits in a tab of the bottom navigation, so it has its own
/// navigator below the app's root navigator, as in the app shell.
GoRouter _buildRouterWithConfigTab() => GoRouter(
  initialLocation: '/config',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(body: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/config',
              builder: (context, state) =>
                  const Scaffold(body: SingleChildScrollView(child: BackupConfigSection())),
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  late Directory temporaryDirectory;
  late ApplicationDatabase database;
  late ProviderContainer container;
  late _DownloadsFolderFileStore fileStore;
  late _RecordingApplicationRestarter applicationRestarter;
  final clock = FixedClock(DateTime.utc(2026, 10, 2, 12));
  const password = 'freezer password';

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('backup_round_trip_test');
    final phoneDirectory = Directory('${temporaryDirectory.path}/phone')..createSync();
    final downloadsDirectory = Directory('${temporaryDirectory.path}/downloads')..createSync();
    // A database file, as on a phone: a restore is staged next to it.
    database = await EncryptedDatabaseOpener(
      keyStore: InMemoryDatabaseEncryptionKeyStore(),
      clock: clock,
      applicationVersion: '0.1.0',
      privateDirectoryProvider: () async => phoneDirectory,
    ).open();
    fileStore = _DownloadsFolderFileStore(downloadsDirectory);
    applicationRestarter = _RecordingApplicationRestarter();
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
        mediaFileStoreProvider.overrideWithValue(InMemoryMediaFileStore()),
        applicationRestarterProvider.overrideWithValue(applicationRestarter),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  testWidgets('saves a backup from the Config tab and restores it again', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: buildLocalizedTestRouterApplication(
          featureLocalizationDelegates: const DataPortabilityFeatureModule().localizationDelegates,
          routerConfig: _buildRouterWithConfigTab(),
        ),
      ),
    );
    await _settle(tester);

    await tester.tap(find.text('Save backup'));
    await _settleUntilFound(tester, find.text('Protect your backup'));
    final passwordFields = find.byType(TextField);
    await tester.enterText(passwordFields.at(0), password);
    await tester.enterText(passwordFields.at(1), password);
    await tester.tap(find.widgetWithText(FilledButton, 'Save backup').last);
    await _settleUntilFound(tester, find.text('Backup saved'));

    // The progress dialog is gone and the Config tab is still there.
    expect(find.text('Working on your backup…'), findsNothing);
    expect(find.byType(BackupConfigSection), findsOneWidget);
    expect(fileStore.savedFilePath, isNotNull);

    await tester.tap(find.text('Restore backup'));
    await _settleUntilFound(tester, find.text('Open backup'));
    await tester.enterText(find.byType(TextField), password);
    await tester.tap(find.widgetWithText(FilledButton, 'Open'));
    await _settleUntilFound(tester, find.text('Replace everything?'));
    expect(find.text('Working on your backup…'), findsNothing);
    expect(find.byType(BackupConfigSection), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await _settleUntil(tester, () => applicationRestarter.restartCount > 0);
    expect(applicationRestarter.restartCount, 1);
    final databasePath = (await tester.runAsync(
      () => database
          .customSelect("SELECT file FROM pragma_database_list WHERE name = 'main'")
          .getSingle(),
    ))!.read<String>('file');
    expect(File(DatabaseBackupGateway.restoreStagingPathFor(databasePath)).existsSync(), isTrue);
  });
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}

Future<void> _settleUntilFound(WidgetTester tester, Finder finder) async {
  await _settleUntil(tester, () => finder.evaluate().isNotEmpty);
  expect(finder, findsOneWidget);
}

/// The backup encrypts and copies a real database file, which takes real
/// time, and more of it on a slow machine; so this waits by the clock, not
/// for a fixed number of rounds.
Future<void> _settleUntil(WidgetTester tester, bool Function() condition) async {
  final stopwatch = Stopwatch()..start();
  while (!condition() && stopwatch.elapsed < const Duration(seconds: 60)) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}
