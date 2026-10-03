import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../application/backup_file_store.dart';

/// The platform's own save and open dialogs (Storage Access Framework on
/// Android, the document picker on iOS).
final class SystemDialogBackupFileStore implements BackupFileStore {
  const SystemDialogBackupFileStore();

  @override
  Future<bool> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async =>
      await FilePicker.saveFile(fileName: fileName, bytes: bytes, mimeType: mimeType) != null;

  @override
  Future<String?> pickFile() async {
    final pickedFiles = await FilePicker.pickFiles();
    return pickedFiles.singleOrNull?.path;
  }

  @override
  Future<Directory> createScratchDirectory() async =>
      (await getTemporaryDirectory()).createTemp('backup');
}
