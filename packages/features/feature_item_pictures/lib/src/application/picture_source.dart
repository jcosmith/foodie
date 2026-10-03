import 'dart:typed_data';

/// Where a new picture comes from.
enum PictureSourceKind { camera, gallery }

/// Takes a photo or lets the user choose one; `null` when they cancel.
abstract interface class PictureSource {
  Future<Uint8List?> obtainPicture(PictureSourceKind kind);
}
