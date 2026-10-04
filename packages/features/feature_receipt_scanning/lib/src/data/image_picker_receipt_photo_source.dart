import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../application/receipt_capture.dart';

/// The system camera and photo picker. The photo stays a local file in the
/// app's cache until it is discarded.
final class ImagePickerReceiptPhotoSource implements ReceiptPhotoSource {
  ImagePickerReceiptPhotoSource({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<ReceiptPhoto?> takePhoto() => _pick(ImageSource.camera);

  @override
  Future<ReceiptPhoto?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<ReceiptPhoto?> _pick(ImageSource source) async {
    // Full resolution: small print needs every pixel for recognition; the
    // stored page is shrunk afterwards.
    final file = await _imagePicker.pickImage(source: source, requestFullMetadata: false);
    if (file == null) return null;
    return ReceiptPhoto(path: file.path, bytes: await file.readAsBytes());
  }

  @override
  Future<void> discard(ReceiptPhoto photo) async {
    final file = File(photo.path);
    if (file.existsSync()) await file.delete();
  }
}
