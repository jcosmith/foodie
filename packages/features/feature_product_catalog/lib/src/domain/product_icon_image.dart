import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A picture the user chose as a product's icon instead of an emoji: a small
/// square PNG, already scaled by the media storage (issue #21).
@immutable
final class ProductIconImage {
  const ProductIconImage(this.pngBytes);

  final Uint8List pngBytes;

  @override
  bool operator ==(Object other) {
    if (other is! ProductIconImage) return false;
    if (identical(other.pngBytes, pngBytes)) return true;
    if (other.pngBytes.length != pngBytes.length) return false;
    for (var index = 0; index < pngBytes.length; index++) {
      if (other.pngBytes[index] != pngBytes[index]) return false;
    }
    return true;
  }

  /// From the length and a sample of the bytes; equal icons hash alike.
  @override
  int get hashCode => Object.hash(
    pngBytes.length,
    Object.hashAll(pngBytes.take(32)),
    Object.hashAll(pngBytes.skip(pngBytes.length > 32 ? pngBytes.length - 32 : 0)),
  );
}
