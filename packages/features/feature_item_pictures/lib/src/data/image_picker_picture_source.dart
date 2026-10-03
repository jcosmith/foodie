import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../application/picture_source.dart';

/// The camera or the system photo picker through image_picker. On Android
/// 13 and later the photo picker needs no storage permission; the camera
/// permission is asked for only when the user first takes a photo.
///
/// The platform scales very large photos down first, which keeps decoding
/// fast, and returns JPEG (also for HEIC photos on iOS). The media store
/// re-encodes the result anyway, which drops every bit of metadata.
final class ImagePickerPictureSource implements PictureSource {
  ImagePickerPictureSource({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  static const double _maximumEdgeFromPlatformInPixels = 2400;
  static const int _qualityFromPlatform = 95;

  final ImagePicker _imagePicker;

  @override
  Future<Uint8List?> obtainPicture(PictureSourceKind kind) async {
    final pickedFile = await _imagePicker.pickImage(
      source: switch (kind) {
        PictureSourceKind.camera => ImageSource.camera,
        PictureSourceKind.gallery => ImageSource.gallery,
      },
      maxWidth: _maximumEdgeFromPlatformInPixels,
      maxHeight: _maximumEdgeFromPlatformInPixels,
      imageQuality: _qualityFromPlatform,
      requestFullMetadata: false,
    );
    return pickedFile?.readAsBytes();
  }
}
