import 'dart:io';

import 'package:core_foundation/core_foundation.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../application_database.dart';
import '../backup/database_backup_gateway.dart';
import 'database_encryption_key.dart';
import 'database_encryption_key_store.dart';
import 'sqlcipher_setup.dart';

/// Thrown when a database file exists but its key is gone, for example after
/// the platform's secure storage was reset. The data cannot be decrypted; the
/// user can only restore a backup or start over.
final class DatabaseEncryptionKeyLostException implements Exception {
  const DatabaseEncryptionKeyLostException();

  @override
  String toString() => 'DatabaseEncryptionKeyLostException';
}

/// Opens the application database encrypted with SQLCipher.
///
/// The file lives in the app's private Application Support directory. On iOS
/// the app shell marks that directory as excluded from iCloud backups; on
/// Android, Auto Backup is switched off in the manifest.
final class EncryptedDatabaseOpener {
  EncryptedDatabaseOpener({
    required DatabaseEncryptionKeyStore keyStore,
    required Clock clock,
    required String applicationVersion,
    Future<Directory> Function()? privateDirectoryProvider,
  }) : _keyStore = keyStore,
       _clock = clock,
       _applicationVersion = applicationVersion,
       _privateDirectoryProvider = privateDirectoryProvider ?? getApplicationSupportDirectory;

  /// Kept from the time the app was called Freezer, so installed apps
  /// find their data after the rename.
  static const String databaseFileName = 'freezer.sqlite';

  final DatabaseEncryptionKeyStore _keyStore;
  final Clock _clock;
  final String _applicationVersion;
  final Future<Directory> Function() _privateDirectoryProvider;

  Future<File> databaseFile() async {
    final privateDirectory = await _privateDirectoryProvider();
    return File(path.join(privateDirectory.path, databaseFileName));
  }

  Future<ApplicationDatabase> open() async {
    final file = await databaseFile();
    await _moveRestoredDatabaseInPlace(file);
    final key = await _readOrCreateKey(databaseFileExists: file.existsSync());
    return ApplicationDatabase(
      NativeDatabase.createInBackground(
        file,
        setup: (rawDatabase) => applySqlCipherKey(rawDatabase, key),
      ),
      clock: _clock,
      applicationVersion: _applicationVersion,
    );
  }

  /// Finishes a restore prepared by [DatabaseBackupGateway.prepareRestore]:
  /// the staging file replaces the database while nothing has it open.
  static Future<void> _moveRestoredDatabaseInPlace(File databaseFile) async {
    final stagingFile = File(DatabaseBackupGateway.restoreStagingPathFor(databaseFile.path));
    if (!stagingFile.existsSync()) return;
    for (final journalSuffix in ['-wal', '-shm', '-journal']) {
      final journalFile = File('${databaseFile.path}$journalSuffix');
      if (journalFile.existsSync()) await journalFile.delete();
    }
    await stagingFile.rename(databaseFile.path);
  }

  Future<DatabaseEncryptionKey> _readOrCreateKey({required bool databaseFileExists}) async {
    final storedKey = await _keyStore.readKey();
    if (storedKey != null) return storedKey;
    if (databaseFileExists) throw const DatabaseEncryptionKeyLostException();
    final newKey = DatabaseEncryptionKey.generate();
    await _keyStore.storeKey(newKey);
    return newKey;
  }
}
