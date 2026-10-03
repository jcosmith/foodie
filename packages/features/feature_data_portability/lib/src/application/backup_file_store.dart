import 'dart:io';
import 'dart:typed_data';

/// The system's save and open dialogs. The app never sends a file anywhere
/// itself; the user decides where it goes (section 11).
abstract interface class BackupFileStore {
  /// Returns `false` when the user cancelled.
  Future<bool> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  });

  /// A readable local copy of the file the user picked, or `null`.
  Future<String?> pickFile();

  /// Private scratch space for building a backup; emptied by the caller.
  Future<Directory> createScratchDirectory();
}
