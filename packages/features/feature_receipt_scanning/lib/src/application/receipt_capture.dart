import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../domain/receipt_rows.dart';

/// A photo of a receipt as the camera or the gallery handed it over: a
/// temporary file, which is discarded once it is read and stored.
@immutable
final class ReceiptPhoto {
  const ReceiptPhoto({required this.path, required this.bytes});

  final String path;
  final Uint8List bytes;
}

/// The system camera and photo picker.
abstract interface class ReceiptPhotoSource {
  /// `null` when the user cancelled.
  Future<ReceiptPhoto?> takePhoto();

  /// `null` when the user cancelled.
  Future<ReceiptPhoto?> pickFromGallery();

  /// Deletes the temporary file; the stored page is a processed copy.
  Future<void> discard(ReceiptPhoto photo);
}

/// On-device text recognition (decision D16): text lines with their boxes on
/// the photo. Nothing leaves the phone.
abstract interface class ReceiptTextRecognizer {
  Future<List<RecognizedTextLine>> recognize(ReceiptPhoto photo);
}
