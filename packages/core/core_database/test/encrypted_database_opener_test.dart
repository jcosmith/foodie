import 'dart:io';

import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory temporaryDirectory;
  final clock = FixedClock(DateTime.utc(2026, 10, 2, 12));

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('core_database_test');
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  EncryptedDatabaseOpener createOpener(DatabaseEncryptionKeyStore keyStore) =>
      EncryptedDatabaseOpener(
        keyStore: keyStore,
        clock: clock,
        applicationVersion: '0.1.0',
        privateDirectoryProvider: () async => temporaryDirectory,
      );

  test('creates a key on first open and encrypts the file', () async {
    final keyStore = InMemoryDatabaseEncryptionKeyStore();
    final opener = createOpener(keyStore);

    final database = await opener.open();
    await database.preferencesDao.writeEncodedValue(
      preferenceKey: 'test.greeting',
      encodedValue: 'secret',
      updatedAt: clock.nowUtc(),
    );
    await database.close();

    expect(await keyStore.readKey(), isNotNull);
    final file = await opener.databaseFile();
    final fileBytes = await file.readAsBytes();
    expect(String.fromCharCodes(fileBytes.take(15)), isNot('SQLite format 3'));
    expect(String.fromCharCodes(fileBytes).contains('secret'), isFalse);
  });

  test('reopens with the stored key', () async {
    final keyStore = InMemoryDatabaseEncryptionKeyStore();
    final firstDatabase = await createOpener(keyStore).open();
    await firstDatabase.preferencesDao.writeEncodedValue(
      preferenceKey: 'test.greeting',
      encodedValue: 'hello',
      updatedAt: clock.nowUtc(),
    );
    await firstDatabase.close();

    final reopenedDatabase = await createOpener(keyStore).open();
    expect(await reopenedDatabase.preferencesDao.readEncodedValue('test.greeting'), 'hello');
    await reopenedDatabase.close();
  });

  test('cannot be read without the key', () async {
    final opener = createOpener(InMemoryDatabaseEncryptionKeyStore());
    final database = await opener.open();
    await database.preferencesDao.readEncodedValue('anything');
    await database.close();

    final unencryptedConnection = sqlite3.open((await opener.databaseFile()).path);
    expect(
      () => unencryptedConnection.select('SELECT count(*) FROM sqlite_master'),
      throwsA(isA<SqliteException>()),
    );
    unencryptedConnection.close();
  });

  test('refuses to create a new key when a database file already exists', () async {
    final opener = createOpener(InMemoryDatabaseEncryptionKeyStore());
    await (await opener.databaseFile()).writeAsString('existing encrypted data');

    expect(opener.open, throwsA(isA<DatabaseEncryptionKeyLostException>()));
  });

  test('the bundled SQLite is SQLCipher', () {
    final connection = sqlite3.openInMemory();
    expect(connection.select('PRAGMA cipher_version'), isNotEmpty);
    connection.close();
  });

  test('records the schema version and app version on creation', () async {
    final database = ApplicationDatabase(
      NativeDatabase.memory(),
      clock: clock,
      applicationVersion: '0.1.0',
    );

    final metadata = await database.schemaMetadataDao.readSchemaMetadata();

    expect(metadata?.schemaVersion, database.schemaVersion);
    expect(metadata?.lastMigratedByApplicationVersion, '0.1.0');
    await database.close();
  });

  test('keys are 256-bit and never printed', () {
    final key = DatabaseEncryptionKey.generate();
    expect(key.hexadecimal, hasLength(64));
    expect(key.toString(), isNot(contains(key.hexadecimal)));
    expect(() => DatabaseEncryptionKey.fromHexadecimal('xyz'), throwsArgumentError);
  });
}
