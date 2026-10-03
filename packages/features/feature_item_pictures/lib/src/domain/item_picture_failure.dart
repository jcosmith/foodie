import 'package:core_foundation/core_foundation.dart';

/// Why a picture could not be attached.
sealed class ItemPictureFailure extends Failure {
  const ItemPictureFailure();
}

/// The chosen file is no picture the app can read.
final class PictureNotReadable extends ItemPictureFailure {
  const PictureNotReadable();

  @override
  String get debugDescription => 'The picture could not be read';
}

/// Taking or choosing a picture failed, for example because camera access
/// was refused.
final class PictureSourceUnavailable extends ItemPictureFailure {
  const PictureSourceUnavailable();

  @override
  String get debugDescription => 'The camera or the photo picker is unavailable';
}
