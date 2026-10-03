import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:core_foundation/core_foundation.dart';
import 'package:image/image.dart' as image_codec;
import 'package:meta/meta.dart';

/// Why a picture could not be stored.
sealed class MediaStorageFailure extends Failure {
  const MediaStorageFailure();
}

/// The chosen file is no picture the app can read.
final class UnreadableImage extends MediaStorageFailure {
  const UnreadableImage();

  @override
  String get debugDescription => 'The image could not be decoded';
}

/// A picture ready to store: re-encoded as JPEG without any metadata, plus a
/// square thumbnail for lists.
@immutable
final class ProcessedPicture {
  const ProcessedPicture({
    required this.pictureBytes,
    required this.thumbnailBytes,
    required this.widthPixels,
    required this.heightPixels,
  });

  final Uint8List pictureBytes;
  final Uint8List thumbnailBytes;
  final int widthPixels;
  final int heightPixels;
}

/// Turns a photo from the camera or the gallery into what the app stores
/// (architecture document, section 10.2): the longest edge at most 1600
/// pixels, JPEG quality 80, and a 256-pixel thumbnail. Re-encoding drops
/// all EXIF metadata, including the GPS location many phones embed; the
/// orientation it records is applied to the pixels first.
final class ImageProcessingService {
  const ImageProcessingService();

  static const int maximumLongestEdgeInPixels = 1600;
  static const int thumbnailEdgeInPixels = 256;
  static const int jpegQuality = 80;

  /// Decodes and re-encodes in a background isolate, so the interface keeps
  /// running.
  Future<Result<ProcessedPicture, MediaStorageFailure>> processPicture(
    Uint8List sourceBytes,
  ) async {
    final processedPicture = await Isolate.run(() => processPictureSynchronously(sourceBytes));
    return processedPicture == null
        ? const Result.failure(UnreadableImage())
        : Result.success(processedPicture);
  }

  /// The same work on the calling isolate; `null` when the bytes are no
  /// picture.
  static ProcessedPicture? processPictureSynchronously(Uint8List sourceBytes) {
    final image_codec.Image? decodedImage;
    try {
      decodedImage = image_codec.decodeImage(sourceBytes);
    } on Object {
      return null;
    }
    if (decodedImage == null || decodedImage.width == 0 || decodedImage.height == 0) return null;

    final uprightImage = image_codec.bakeOrientation(decodedImage);
    final longestEdge = max(uprightImage.width, uprightImage.height);
    final resizedImage = longestEdge <= maximumLongestEdgeInPixels
        ? uprightImage
        : image_codec.copyResize(
            uprightImage,
            width: uprightImage.width >= uprightImage.height ? maximumLongestEdgeInPixels : null,
            height: uprightImage.width < uprightImage.height ? maximumLongestEdgeInPixels : null,
            interpolation: image_codec.Interpolation.average,
          );
    final thumbnailImage = image_codec.copyResizeCropSquare(
      resizedImage,
      size: min(thumbnailEdgeInPixels, min(resizedImage.width, resizedImage.height)),
      interpolation: image_codec.Interpolation.average,
    );
    return ProcessedPicture(
      pictureBytes: _encodeWithoutMetadata(resizedImage),
      thumbnailBytes: _encodeWithoutMetadata(thumbnailImage),
      widthPixels: resizedImage.width,
      heightPixels: resizedImage.height,
    );
  }

  /// The edge of a product icon made by [processIcon]: sharp at 40 logical
  /// pixels on screens with up to 4.8 physical pixels per logical one.
  static const int iconEdgeInPixels = 192;

  /// Turns any picture the app can read (PNG, JPEG, GIF, BMP, WebP, ...) into
  /// a product icon: a [iconEdgeInPixels] square PNG. The whole picture is
  /// scaled to fit and centred; the rest stays transparent, as does any
  /// transparency of the source. Metadata is dropped like for photos.
  Future<Result<Uint8List, MediaStorageFailure>> processIcon(Uint8List sourceBytes) async {
    final iconBytes = await Isolate.run(() => processIconSynchronously(sourceBytes));
    return iconBytes == null ? const Result.failure(UnreadableImage()) : Result.success(iconBytes);
  }

  /// The same work on the calling isolate; `null` when the bytes are no
  /// picture.
  static Uint8List? processIconSynchronously(Uint8List sourceBytes) {
    final image_codec.Image? decodedImage;
    try {
      decodedImage = image_codec.decodeImage(sourceBytes);
    } on Object {
      return null;
    }
    if (decodedImage == null || decodedImage.width == 0 || decodedImage.height == 0) return null;

    // Animated pictures keep their first frame.
    final uprightImage = image_codec.bakeOrientation(decodedImage.frames.first);
    final scale = iconEdgeInPixels / max(uprightImage.width, uprightImage.height);
    final scaledImage = image_codec.copyResize(
      uprightImage.convert(numChannels: 4),
      width: max(1, (uprightImage.width * scale).round()),
      height: max(1, (uprightImage.height * scale).round()),
      interpolation: scale < 1
          ? image_codec.Interpolation.average
          : image_codec.Interpolation.cubic,
    );
    final icon = image_codec.Image(
      width: iconEdgeInPixels,
      height: iconEdgeInPixels,
      numChannels: 4,
    );
    image_codec.compositeImage(
      icon,
      scaledImage,
      dstX: (iconEdgeInPixels - scaledImage.width) ~/ 2,
      dstY: (iconEdgeInPixels - scaledImage.height) ~/ 2,
      blend: image_codec.BlendMode.direct,
    );
    return image_codec.encodePng(icon);
  }

  static Uint8List _encodeWithoutMetadata(image_codec.Image image) {
    final imageWithoutMetadata = image_codec.Image.from(image)
      ..exif = image_codec.ExifData()
      ..iccProfile = null
      ..textData = null;
    return image_codec.encodeJpg(imageWithoutMetadata, quality: jpegQuality);
  }
}
