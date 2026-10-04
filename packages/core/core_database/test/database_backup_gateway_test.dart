import 'dart:io';
import 'dart:typed_data';

import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory temporaryDirectory;
  final clock = FixedClock(DateTime.utc(2026, 10, 2, 12));
  const password = "correct horse 'battery'";

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('backup_gateway_test');
  });
  tearDown(() => temporaryDirectory.delete(recursive: true));

  /// A database in its own folder with its own device key, like a phone.
  EncryptedDatabaseOpener phone(String name) {
    final directory = Directory('${temporaryDirectory.path}/$name')..createSync();
    return EncryptedDatabaseOpener(
      keyStore: InMemoryDatabaseEncryptionKeyStore(),
      clock: clock,
      applicationVersion: '0.2.0',
      privateDirectoryProvider: () async => directory,
    );
  }

  Future<String> createBackup({required String text}) async {
    final database = await phone('old_phone').open();
    await database.preferencesDao.writeEncodedValue(
      preferenceKey: 'test.text',
      encodedValue: text,
      updatedAt: clock.nowUtc(),
    );
    final backupPath = '${temporaryDirectory.path}/freezer.freezerbackup';
    await DatabaseBackupGateway(database).exportEncryptedSnapshot(
      destinationPath: backupPath,
      password: password,
      applicationVersion: '0.2.0',
      createdAt: clock.nowUtc(),
    );
    await database.close();
    return backupPath;
  }

  test('a backup restores on another phone after a restart', () async {
    final backupPath = await createBackup(text: 'from the old phone');
    expect(
      String.fromCharCodes(File(backupPath).readAsBytesSync()).contains('from the old phone'),
      isFalse,
    );

    final newPhone = phone('new_phone');
    final database = await newPhone.open();
    final result = await DatabaseBackupGateway(
      database,
    ).prepareRestore(backupPath: backupPath, password: password);
    expect(result.valueOrNull?.createdAt, clock.nowUtc());
    expect(result.valueOrNull?.applicationVersion, '0.2.0');
    expect(await database.preferencesDao.readEncodedValue('test.text'), isNull);
    await database.close();

    final restoredDatabase = await newPhone.open();
    expect(
      await restoredDatabase.preferencesDao.readEncodedValue('test.text'),
      'from the old phone',
    );
    final tableNames = await restoredDatabase
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((row) => row.read<String>('name'))
        .get();
    expect(tableNames, isNot(contains('freezer_backup_manifest')));
    await restoredDatabase.close();
  });

  test('a wrong password changes nothing', () async {
    final backupPath = await createBackup(text: 'secret');
    final database = await phone('new_phone').open();

    final result = await DatabaseBackupGateway(
      database,
    ).prepareRestore(backupPath: backupPath, password: 'wrong');

    expect(result.failureOrNull, isA<WrongPasswordOrUnreadableFile>());
    expect(await database.preferencesDao.readEncodedValue('test.text'), isNull);
    await database.close();
  });

  test('refuses other encrypted databases and backups of newer versions', () async {
    final strangerPath = '${temporaryDirectory.path}/stranger.sqlite';
    sqlite3.open(strangerPath)
      ..execute('PRAGMA key = ${_quoted(password)}')
      ..execute('CREATE TABLE notes (text TEXT)')
      ..close();
    final newerBackupPath = await createBackup(text: 'from the future');
    sqlite3.open(newerBackupPath)
      ..execute('PRAGMA key = ${_quoted(password)}')
      ..execute('PRAGMA user_version = 99')
      ..close();
    final database = await phone('new_phone').open();
    final gateway = DatabaseBackupGateway(database);

    expect(
      (await gateway.inspectBackup(backupPath: strangerPath, password: password)).failureOrNull,
      isA<NotAFoodieBackup>(),
    );
    expect(
      (await gateway.inspectBackup(backupPath: newerBackupPath, password: password)).failureOrNull,
      isA<BackupFromNewerVersion>(),
    );
    await database.close();
  });

  group('pictures', () {
    ItemPictureRow pictureRow(String identifier) => ItemPictureRow(
      itemPictureIdentifier: identifier,
      ownerKind: 'product',
      ownerIdentifier: 'product-$identifier',
      encryptedFileName: '$identifier.picture',
      thumbnailFileName: '$identifier.thumbnail',
      widthPixels: 1600,
      heightPixels: 1200,
      byteSize: 3,
      createdAt: clock.nowUtc(),
    );

    Future<String> createBackupWithPictures({required bool includesPictures}) async {
      final database = await phone('old_phone').open();
      final oldPhoneFiles = _InMemoryBackupFileAccess({
        'kept.picture': Uint8List.fromList([1, 2, 3]),
        'kept.thumbnail': Uint8List.fromList([4]),
        // The picture of 'lost' is gone; it is left out of the backup.
        'lost.thumbnail': Uint8List.fromList([5]),
      });
      await database.itemPicturesDao.insertPicture(pictureRow('kept'));
      await database.itemPicturesDao.insertPicture(pictureRow('lost'));
      final gateway = DatabaseBackupGateway(database);
      expect(await gateway.countPicturesForBackup(), 2);
      final backupPath = '${temporaryDirectory.path}/pictures.freezerbackup';
      await gateway.exportEncryptedSnapshot(
        destinationPath: backupPath,
        password: password,
        applicationVersion: '0.3.0',
        createdAt: clock.nowUtc(),
        pictureFiles: includesPictures ? oldPhoneFiles : null,
      );
      await database.close();
      return backupPath;
    }

    test('travel inside the backup and are written back before the restart', () async {
      final backupPath = await createBackupWithPictures(includesPictures: true);
      final newPhone = phone('new_phone');
      final database = await newPhone.open();
      final gateway = DatabaseBackupGateway(database);
      final newPhoneFiles = _InMemoryBackupFileAccess({});

      final inspection = await gateway.inspectBackup(backupPath: backupPath, password: password);
      expect(inspection.valueOrNull?.pictureCount, 1);
      expect(inspection.valueOrNull?.formatVersion, BackupManifest.currentFormatVersion);
      final result = await gateway.prepareRestore(
        backupPath: backupPath,
        password: password,
        pictureFiles: newPhoneFiles,
      );

      expect(result.valueOrNull?.pictureCount, 1);
      expect(newPhoneFiles.filesByName.keys, unorderedEquals(['kept.picture', 'kept.thumbnail']));
      expect(newPhoneFiles.filesByName['kept.picture'], [1, 2, 3]);
      await database.close();

      final restoredDatabase = await newPhone.open();
      expect(
        (await restoredDatabase.itemPicturesDao.readPictures()).map(
          (picture) => picture.itemPictureIdentifier,
        ),
        ['kept'],
      );
      final tableNames = await restoredDatabase
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((row) => row.read<String>('name'))
          .get();
      expect(tableNames, isNot(contains('freezer_backup_files')));
      await restoredDatabase.close();
    });

    test('a backup without pictures has no picture rows either', () async {
      final backupPath = await createBackupWithPictures(includesPictures: false);
      final newPhone = phone('new_phone');
      final database = await newPhone.open();
      final newPhoneFiles = _InMemoryBackupFileAccess({});

      final result = await DatabaseBackupGateway(
        database,
      ).prepareRestore(backupPath: backupPath, password: password, pictureFiles: newPhoneFiles);

      expect(result.valueOrNull?.pictureCount, 0);
      expect(newPhoneFiles.filesByName, isEmpty);
      await database.close();
      final restoredDatabase = await newPhone.open();
      expect(await restoredDatabase.itemPicturesDao.readPictures(), isEmpty);
      await restoredDatabase.close();
    });
  });
}

final class _InMemoryBackupFileAccess implements BackupFileAccess {
  _InMemoryBackupFileAccess(this.filesByName);

  final Map<String, Uint8List> filesByName;

  @override
  Future<Uint8List?> readFileForBackup(String fileName) async => filesByName[fileName];

  @override
  Future<void> restoreFileFromBackup(String fileName, Uint8List contents) async =>
      filesByName[fileName] = contents;
}

String _quoted(String text) => "'${text.replaceAll("'", "''")}'";
