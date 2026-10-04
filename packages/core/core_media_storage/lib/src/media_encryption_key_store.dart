import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'media_encryption_key.dart';

/// Keeps the picture file key in the platform's secure key storage.
abstract interface class MediaEncryptionKeyStore {
  /// The stored key, created and stored on first use.
  Future<MediaEncryptionKey> readOrCreateKey();
}

/// Stores the key in the iOS Keychain or the Android Keystore-backed
/// storage, next to the database key and with the same options: "this
/// device only" on iOS, and no silent reset on Android errors, because a lost
/// key makes every picture unreadable.
final class SecureStorageMediaEncryptionKeyStore implements MediaEncryptionKeyStore {
  SecureStorageMediaEncryptionKeyStore({FlutterSecureStorage? secureStorage})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
            aOptions: AndroidOptions(resetOnError: false),
          );

  static const String _storageKey = 'core_media_storage.file_key';

  final FlutterSecureStorage _secureStorage;

  /// One read per instance: stores sharing it can never create two keys.
  Future<MediaEncryptionKey>? _key;

  @override
  Future<MediaEncryptionKey> readOrCreateKey() => _key ??= _readOrCreateKey();

  Future<MediaEncryptionKey> _readOrCreateKey() async {
    final storedKey = await _secureStorage.read(key: _storageKey);
    if (storedKey != null) return MediaEncryptionKey.fromBase64(storedKey);
    final newKey = MediaEncryptionKey.generate();
    await _secureStorage.write(key: _storageKey, value: newKey.base64);
    return newKey;
  }
}

/// Keeps the key in memory; for tests.
final class InMemoryMediaEncryptionKeyStore implements MediaEncryptionKeyStore {
  InMemoryMediaEncryptionKeyStore({MediaEncryptionKey? initialKey}) : _storedKey = initialKey;

  MediaEncryptionKey? _storedKey;

  @override
  Future<MediaEncryptionKey> readOrCreateKey() async =>
      _storedKey ??= MediaEncryptionKey.generate();
}
