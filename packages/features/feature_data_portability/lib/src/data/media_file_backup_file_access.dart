import 'dart:io';
import 'dart:typed_data';

import 'package:core_database/core_database.dart';
import 'package:core_media_storage/core_media_storage.dart';

/// Lets backups carry the encrypted picture files: decrypted with the
/// device key on the way into a backup, encrypted with it again on the way
/// back (section 10.2).
final class MediaFileBackupFileAccess implements BackupFileAccess {
  const MediaFileBackupFileAccess(this._mediaFileStore);

  final MediaFileStore _mediaFileStore;

  @override
  Future<Uint8List?> readFileForBackup(String fileName) async {
    if (!MediaFileNames.isValid(fileName)) return null;
    try {
      return await _mediaFileStore.readFile(fileName);
    } on FileSystemException {
      return null;
    } on UnreadableMediaFileException {
      return null;
    }
  }

  /// A backup is a file from outside the app, so a name this app would
  /// never create (one that could point outside the picture folder) is
  /// skipped rather than written.
  @override
  Future<void> restoreFileFromBackup(String fileName, Uint8List contents) async {
    if (!MediaFileNames.isValid(fileName)) return;
    await _mediaFileStore.writeFile(fileName, contents);
  }
}
