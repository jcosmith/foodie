import 'dart:math';

import 'package:meta/meta.dart';

/// A random 256-bit SQLCipher key, held as 64 lowercase hexadecimal characters.
@immutable
final class DatabaseEncryptionKey {
  DatabaseEncryptionKey.fromHexadecimal(this.hexadecimal) {
    if (!_hexadecimalKeyPattern.hasMatch(hexadecimal)) {
      throw ArgumentError('A database key must be 64 lowercase hexadecimal characters');
    }
  }

  /// Creates a new key from a cryptographically secure random source.
  factory DatabaseEncryptionKey.generate({Random? secureRandom}) {
    final random = secureRandom ?? Random.secure();
    final keyBytes = List<int>.generate(_keyLengthInBytes, (_) => random.nextInt(256));
    return DatabaseEncryptionKey.fromHexadecimal(
      keyBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(),
    );
  }

  static const int _keyLengthInBytes = 32;
  static final RegExp _hexadecimalKeyPattern = RegExp(r'^[0-9a-f]{64}$');

  final String hexadecimal;

  @override
  bool operator ==(Object other) =>
      other is DatabaseEncryptionKey && other.hexadecimal == hexadecimal;

  @override
  int get hashCode => hexadecimal.hashCode;

  /// Never print the key.
  @override
  String toString() => 'DatabaseEncryptionKey(redacted)';
}
