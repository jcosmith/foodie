import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A random 256-bit AES-GCM key for picture files. It never leaves the
/// device: backups carry the pictures decrypted inside the password-encrypted
/// backup instead.
@immutable
final class MediaEncryptionKey {
  MediaEncryptionKey.fromBytes(List<int> bytes) : bytes = Uint8List.fromList(bytes) {
    if (bytes.length != keyLengthInBytes) {
      throw ArgumentError('A media key must be $keyLengthInBytes bytes long');
    }
  }

  /// Creates a new key from a cryptographically secure random source.
  factory MediaEncryptionKey.generate({Random? secureRandom}) {
    final random = secureRandom ?? Random.secure();
    return MediaEncryptionKey.fromBytes(
      List<int>.generate(keyLengthInBytes, (_) => random.nextInt(256)),
    );
  }

  factory MediaEncryptionKey.fromBase64(String encodedKey) =>
      MediaEncryptionKey.fromBytes(base64Decode(encodedKey));

  static const int keyLengthInBytes = 32;

  final Uint8List bytes;

  String get base64 => base64Encode(bytes);

  @override
  bool operator ==(Object other) {
    if (other is! MediaEncryptionKey) return false;
    for (var index = 0; index < keyLengthInBytes; index++) {
      if (other.bytes[index] != bytes[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(bytes);

  /// Never print the key.
  @override
  String toString() => 'MediaEncryptionKey(redacted)';
}
