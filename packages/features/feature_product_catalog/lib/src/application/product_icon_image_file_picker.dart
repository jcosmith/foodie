import 'dart:typed_data';

/// The system's open dialog, for a picture to use as a product icon. The
/// file is only read; it never leaves the phone.
abstract interface class ProductIconImageFilePicker {
  /// The contents of the picture the user picked, or `null` when cancelled.
  Future<Uint8List?> pickImageFile();
}
