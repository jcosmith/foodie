/// Test helpers for packages that store pictures.
library;

import 'dart:typed_data';

import 'package:image/image.dart' as image_codec;

/// A small JPEG photo of a single colour, as a camera would deliver it.
Uint8List createTestPhotoBytes({int width = 64, int height = 48, int red = 200}) {
  final photo = image_codec.Image(width: width, height: height);
  image_codec.fill(photo, color: image_codec.ColorRgb8(red, 120, 40));
  return image_codec.encodeJpg(photo, quality: 90);
}
