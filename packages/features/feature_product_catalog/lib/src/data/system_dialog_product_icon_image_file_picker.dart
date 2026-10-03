import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../application/product_icon_image_file_picker.dart';

/// The platform's open dialog filtered to pictures (Storage Access
/// Framework on Android, the document picker on iOS), so icons can come
/// from any folder, such as Downloads.
final class SystemDialogProductIconImageFilePicker implements ProductIconImageFilePicker {
  const SystemDialogProductIconImageFilePicker();

  @override
  Future<Uint8List?> pickImageFile() async {
    final pickedFiles = await FilePicker.pickFiles(type: FileType.image);
    return pickedFiles.singleOrNull?.readAsBytes();
  }
}
