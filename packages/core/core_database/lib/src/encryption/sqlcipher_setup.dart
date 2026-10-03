import 'package:sqlite3/sqlite3.dart';

import 'database_encryption_key.dart';

/// Thrown when the linked SQLite library has no encryption support.
///
/// The app refuses to fall back to an unencrypted database.
final class SqlCipherUnavailableException implements Exception {
  const SqlCipherUnavailableException();

  @override
  String toString() =>
      'SqlCipherUnavailableException: the linked SQLite has no SQLCipher support. '
      'Check hooks.user_defines.sqlite3.source in the workspace pubspec.yaml.';
}

/// Applies [key] to a freshly opened raw database connection.
///
/// Must run before any other statement. Verifies that SQLCipher is present
/// and that the key opens the file (a wrong key fails on the first read).
void applySqlCipherKey(Database rawDatabase, DatabaseEncryptionKey key) {
  final cipherVersionRows = rawDatabase.select('PRAGMA cipher_version');
  if (cipherVersionRows.isEmpty) {
    throw const SqlCipherUnavailableException();
  }
  // The key is validated to be hexadecimal, so interpolation is safe here.
  rawDatabase.execute('PRAGMA key = "x\'${key.hexadecimal}\'"');
  rawDatabase.select('SELECT count(*) FROM sqlite_master');
}
