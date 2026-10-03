import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'database_encryption_key.dart';

/// Keeps the SQLCipher key in the platform's secure key storage.
abstract interface class DatabaseEncryptionKeyStore {
  /// The stored key, or `null` if none has been created yet.
  Future<DatabaseEncryptionKey?> readKey();

  Future<void> storeKey(DatabaseEncryptionKey key);
}

/// Stores the key in the iOS Keychain or the Android Keystore-backed storage.
///
/// On iOS the key is "this device only" and readable after the first unlock,
/// so it is never synced through iCloud Keychain and never restored onto
/// another device (privacy table, section 11 of the architecture document).
/// On Android, errors do not silently reset the storage: losing the key would
/// make the database unreadable, so failures surface instead.
final class SecureStorageDatabaseEncryptionKeyStore implements DatabaseEncryptionKeyStore {
  SecureStorageDatabaseEncryptionKeyStore({FlutterSecureStorage? secureStorage})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
            aOptions: AndroidOptions(resetOnError: false),
          );

  static const String _storageKey = 'core_database.sqlcipher_key';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<DatabaseEncryptionKey?> readKey() async {
    final storedHexadecimal = await _secureStorage.read(key: _storageKey);
    return storedHexadecimal == null
        ? null
        : DatabaseEncryptionKey.fromHexadecimal(storedHexadecimal);
  }

  @override
  Future<void> storeKey(DatabaseEncryptionKey key) =>
      _secureStorage.write(key: _storageKey, value: key.hexadecimal);
}

/// Keeps the key in memory; for tests.
final class InMemoryDatabaseEncryptionKeyStore implements DatabaseEncryptionKeyStore {
  InMemoryDatabaseEncryptionKeyStore({DatabaseEncryptionKey? initialKey}) : _storedKey = initialKey;

  DatabaseEncryptionKey? _storedKey;

  @override
  Future<DatabaseEncryptionKey?> readKey() async => _storedKey;

  @override
  Future<void> storeKey(DatabaseEncryptionKey key) async => _storedKey = key;
}
