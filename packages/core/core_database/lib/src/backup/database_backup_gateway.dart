import 'dart:io';

import 'package:core_foundation/core_foundation.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../application_database.dart';

/// What a backup file says about itself.
@immutable
final class BackupManifest {
  const BackupManifest({
    required this.applicationVersion,
    required this.schemaVersion,
    required this.createdAt,
    this.pictureCount = 0,
    this.isPasswordProtected = true,
    this.formatVersion = currentFormatVersion,
  });

  /// 1: database only. 2: picture files travel inside the backup. 3: the
  /// password is optional; a backup without one is a plain SQLite file.
  static const int currentFormatVersion = 3;

  final int formatVersion;
  final String applicationVersion;
  final int schemaVersion;
  final DateTime createdAt;

  /// Pictures whose files are in the backup; 0 for a backup made without
  /// pictures or before they existed.
  final int pictureCount;

  /// Whether the file is encrypted with a password. Every backup before
  /// format 3 is.
  final bool isPasswordProtected;
}

/// Files kept outside the database that travel inside a backup: the
/// encrypted picture files of item_pictures (decision D11). The backup holds
/// them decrypted, protected by the backup password like everything else;
/// the device's own file key never leaves the phone.
abstract interface class BackupFileAccess {
  /// The decrypted contents of a file, or `null` when it is gone or
  /// unreadable; the picture is then left out of the backup.
  Future<Uint8List?> readFileForBackup(String fileName);

  /// Stores a file from a backup under its name. Names the store would
  /// never create are ignored.
  Future<void> restoreFileFromBackup(String fileName, Uint8List contents);
}

/// Why a backup file cannot be restored.
sealed class BackupFileFailure extends Failure {
  const BackupFileFailure();
}

/// SQLCipher cannot tell a wrong password from a file that is no database.
final class WrongPasswordOrUnreadableFile extends BackupFileFailure {
  const WrongPasswordOrUnreadableFile();

  @override
  String get debugDescription => 'Wrong password, or not an encrypted database';
}

/// The backup is encrypted, and no password was given.
final class BackupNeedsPassword extends BackupFileFailure {
  const BackupNeedsPassword();

  @override
  String get debugDescription => 'The backup is protected by a password';
}

/// The password is right, but the file is not a backup of this app.
final class NotAFoodieBackup extends BackupFileFailure {
  const NotAFoodieBackup();

  @override
  String get debugDescription => 'The database has no backup manifest';
}

/// Made by a newer version of the app; the user has to update first.
final class BackupFromNewerVersion extends BackupFileFailure {
  const BackupFromNewerVersion(this.manifest);

  final BackupManifest manifest;

  @override
  String get debugDescription => 'Backup schema ${manifest.schemaVersion} is newer';
}

/// Backups of the live database (architecture document, section 11).
///
/// A backup is a copy of the database encrypted by SQLCipher with the
/// user's password (SQLCipher derives the key with PBKDF2 and a random salt
/// per file and authenticates every page), plus a small manifest table. The
/// password is optional (issue #12): without one, the copy is a plain SQLite
/// file that anyone who gets it can read; the restore recognises it by its
/// header and needs no password. The device's own database key never leaves
/// the phone. The copy is taken with
/// `sqlcipher_export` inside one read transaction, so it is consistent;
/// SQLite's `VACUUM INTO` would keep the device key.
///
/// Picture files are kept outside the database, so a backup copies them into
/// one more table of the backup file (section 10.2: "the backup archive
/// contains the database snapshot plus the picture files"). A restore writes
/// them back before the staged database is put in place, so the rule "file
/// first, row second" holds here too.
final class DatabaseBackupGateway {
  DatabaseBackupGateway(this._database);

  final ApplicationDatabase _database;

  // Named from the time the app was called Freezer; kept so older backups
  // can still be restored.
  static const String _manifestTable = 'freezer_backup_manifest';
  static const String _filesTable = 'freezer_backup_files';

  /// The first bytes of every unencrypted SQLite file. An encrypted file
  /// starts with its random salt instead.
  static const String _plainDatabaseHeader = 'SQLite format 3\u0000';

  /// Where a prepared restore waits until the database is closed; the
  /// opener moves it in place on the next start ([EncryptedDatabaseOpener]).
  static String restoreStagingPathFor(String databasePath) => '$databasePath.restoring';

  /// How many pictures a backup would include.
  Future<int> countPicturesForBackup() async {
    final row = await _database
        .customSelect('SELECT count(*) AS picture_count FROM item_pictures')
        .getSingle();
    return row.read<int>('picture_count');
  }

  /// Writes a copy of the database to [destinationPath], encrypted with
  /// [password], or unencrypted without one. With [pictureFiles], the
  /// picture files go in too; without, the backup has no pictures at all.
  Future<void> exportSnapshot({
    required String destinationPath,
    required String? password,
    required String applicationVersion,
    required DateTime createdAt,
    BackupFileAccess? pictureFiles,
  }) async {
    await _deleteIfPresent(destinationPath);
    // An empty key makes SQLCipher write a plain SQLite file.
    await _database.customStatement('ATTACH DATABASE ? AS backup KEY ?', [
      destinationPath,
      password ?? '',
    ]);
    try {
      await _database.transaction(
        () => _database.customSelect("SELECT sqlcipher_export('backup')").get(),
      );
      // The schema version is an integer we own, so interpolating it is safe.
      await _database.customStatement('PRAGMA backup.user_version = ${_database.schemaVersion}');
      final pictureCount = pictureFiles == null
          ? await _leavePicturesOutOfBackup()
          : await _copyPictureFilesIntoBackup(pictureFiles);
      await _database.customStatement(
        'CREATE TABLE backup.$_manifestTable (name TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)',
      );
      for (final (name, value) in [
        ('format_version', '${BackupManifest.currentFormatVersion}'),
        ('application_version', applicationVersion),
        ('created_at', createdAt.toUtc().toIso8601String()),
        ('picture_count', '$pictureCount'),
        ('password_protected', '${password != null}'),
      ]) {
        await _database.customStatement(
          'INSERT INTO backup.$_manifestTable (name, value) VALUES (?, ?)',
          [name, value],
        );
      }
    } finally {
      await _database.customStatement('DETACH DATABASE backup');
    }
  }

  /// Removes the picture rows from the copy, so a restore has no rows whose
  /// files are missing. Returns the picture count, 0.
  Future<int> _leavePicturesOutOfBackup() async {
    await _database.customStatement('DELETE FROM backup.item_pictures');
    return 0;
  }

  /// Copies the files of every picture row in the copy, one at a time so a
  /// large collection never sits in memory at once. A picture whose files
  /// cannot be read is left out, row included. Returns the picture count.
  Future<int> _copyPictureFilesIntoBackup(BackupFileAccess pictureFiles) async {
    await _database.customStatement(
      'CREATE TABLE backup.$_filesTable (name TEXT NOT NULL PRIMARY KEY, contents BLOB NOT NULL)',
    );
    final pictureRows = await _database
        .customSelect(
          'SELECT item_picture_identifier, encrypted_file_name, thumbnail_file_name '
          'FROM backup.item_pictures',
        )
        .get();
    var pictureCount = 0;
    for (final pictureRow in pictureRows) {
      final fileNames = [
        pictureRow.read<String>('encrypted_file_name'),
        pictureRow.read<String>('thumbnail_file_name'),
      ];
      final fileContents = [
        for (final fileName in fileNames) await pictureFiles.readFileForBackup(fileName),
      ];
      if (fileContents.contains(null)) {
        await _database.customStatement(
          'DELETE FROM backup.item_pictures WHERE item_picture_identifier = ?',
          [pictureRow.read<String>('item_picture_identifier')],
        );
        continue;
      }
      for (final (index, fileName) in fileNames.indexed) {
        await _database.customStatement(
          'INSERT OR REPLACE INTO backup.$_filesTable (name, contents) VALUES (?, ?)',
          [fileName, fileContents[index]],
        );
      }
      pictureCount++;
    }
    return pictureCount;
  }

  /// Opens a backup and reads its manifest without changing anything. An
  /// unprotected backup needs no [password]; for a protected one, a missing
  /// password is a [BackupNeedsPassword] failure, so the caller can ask.
  Future<Result<BackupManifest, BackupFileFailure>> inspectBackup({
    required String backupPath,
    String? password,
  }) => _withAttachedBackup(backupPath, password, (manifest) async => manifest);

  /// Copies a backup into a staging file encrypted like the live database.
  /// Restarting the app moves it in place; the normal migrations then
  /// upgrade an older schema.
  ///
  /// The backup's picture files are written through [pictureFiles] first.
  /// Should the restore never complete, they are orphans that the start-up
  /// sweep removes; once it completes, the sweep removes the old pictures.
  Future<Result<BackupManifest, BackupFileFailure>> prepareRestore({
    required String backupPath,
    String? password,
    BackupFileAccess? pictureFiles,
  }) => _withAttachedBackup(backupPath, password, (manifest) async {
    final hasPictureFiles = await _restoredBackupHasTable(_filesTable);
    if (hasPictureFiles && pictureFiles != null) await _restorePictureFiles(pictureFiles);
    final stagingPath = restoreStagingPathFor(await _liveDatabasePath());
    // Written under a temporary name and renamed when complete, so a crash
    // never leaves a half-written file that the next start would move in.
    final partialPath = '$stagingPath.partial';
    await _deleteIfPresent(partialPath);
    // Without a KEY clause, SQLCipher uses the live database's key.
    await _database.customStatement('ATTACH DATABASE ? AS staging', [partialPath]);
    try {
      await _database.customSelect("SELECT sqlcipher_export('staging', 'restored')").get();
      await _database.customStatement('PRAGMA staging.user_version = ${manifest.schemaVersion}');
      await _database.customStatement('DROP TABLE staging.$_manifestTable');
      if (hasPictureFiles) {
        await _database.customStatement('DROP TABLE staging.$_filesTable');
        // Gives back the space the picture files took in the copy.
        await _database.customStatement('VACUUM staging');
      }
    } finally {
      await _database.customStatement('DETACH DATABASE staging');
    }
    await File(partialPath).rename(stagingPath);
    return manifest;
  });

  Future<Result<BackupManifest, BackupFileFailure>> _withAttachedBackup(
    String backupPath,
    String? password,
    Future<BackupManifest> Function(BackupManifest manifest) whileAttached,
  ) async {
    final isPasswordProtected = !await _isPlainDatabase(backupPath);
    if (isPasswordProtected && password == null) {
      return const Result.failure(BackupNeedsPassword());
    }
    try {
      await _database.customStatement('ATTACH DATABASE ? AS restored KEY ?', [
        backupPath,
        if (isPasswordProtected) password else '',
      ]);
      await _database.customSelect('SELECT count(*) FROM restored.sqlite_master').get();
    } on Exception {
      // A SqliteException, wrapped in a DriftRemoteException when the
      // database runs in a background isolate.
      try {
        await _database.customStatement('DETACH DATABASE restored');
      } on Exception {
        // It was never attached.
      }
      return const Result.failure(WrongPasswordOrUnreadableFile());
    }
    try {
      final manifest = await _readManifest(isPasswordProtected: isPasswordProtected);
      if (manifest == null) return const Result.failure(NotAFoodieBackup());
      if (manifest.schemaVersion > _database.schemaVersion) {
        return Result.failure(BackupFromNewerVersion(manifest));
      }
      return Result.success(await whileAttached(manifest));
    } finally {
      await _database.customStatement('DETACH DATABASE restored');
    }
  }

  Future<void> _restorePictureFiles(BackupFileAccess pictureFiles) async {
    final fileNames = await _database
        .customSelect('SELECT name FROM restored.$_filesTable')
        .map((row) => row.read<String>('name'))
        .get();
    // One file at a time, so a large collection never sits in memory at once.
    for (final fileName in fileNames) {
      final fileRow = await _database
          .customSelect(
            'SELECT contents FROM restored.$_filesTable WHERE name = ?',
            variables: [Variable<String>(fileName)],
          )
          .getSingle();
      await pictureFiles.restoreFileFromBackup(fileName, fileRow.read<Uint8List>('contents'));
    }
  }

  Future<bool> _restoredBackupHasTable(String tableName) async {
    final matchingTables = await _database
        .customSelect(
          "SELECT 1 FROM restored.sqlite_master WHERE type = 'table' AND name = ?",
          variables: [Variable<String>(tableName)],
        )
        .get();
    return matchingTables.isNotEmpty;
  }

  Future<BackupManifest?> _readManifest({required bool isPasswordProtected}) async {
    if (!await _restoredBackupHasTable(_manifestTable)) return null;
    final values = {
      for (final row
          in await _database.customSelect('SELECT name, value FROM restored.$_manifestTable').get())
        row.read<String>('name'): row.read<String>('value'),
    };
    final schemaVersion = (await _database.customSelect('PRAGMA restored.user_version').getSingle())
        .read<int>('user_version');
    return BackupManifest(
      formatVersion: int.tryParse(values['format_version'] ?? '') ?? 0,
      applicationVersion: values['application_version'] ?? '',
      schemaVersion: schemaVersion,
      createdAt: DateTime.tryParse(values['created_at'] ?? '')?.toUtc() ?? DateTime.utc(1970),
      pictureCount: int.tryParse(values['picture_count'] ?? '') ?? 0,
      // Told by the file itself, which cannot be wrong about it.
      isPasswordProtected: isPasswordProtected,
    );
  }

  Future<String> _liveDatabasePath() async {
    final mainRow = await _database
        .customSelect("SELECT file FROM pragma_database_list WHERE name = 'main'")
        .getSingle();
    final path = mainRow.read<String>('file');
    if (path.isEmpty) throw StateError('An in-memory database cannot be restored into');
    return path;
  }

  static Future<bool> _isPlainDatabase(String path) async {
    final file = File(path);
    if (!file.existsSync()) return false;
    final handle = await file.open();
    try {
      final header = await handle.read(_plainDatabaseHeader.length);
      return String.fromCharCodes(header) == _plainDatabaseHeader;
    } finally {
      await handle.close();
    }
  }

  static Future<void> _deleteIfPresent(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}
