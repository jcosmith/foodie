import 'package:meta/meta.dart';

/// Where a stored picture and its thumbnail are, and how large it is. The
/// owning feature keeps this in its own database row.
@immutable
final class StoredMediaReference {
  const StoredMediaReference({
    required this.fileName,
    required this.thumbnailFileName,
    required this.widthPixels,
    required this.heightPixels,
    required this.byteSize,
  });

  final String fileName;
  final String thumbnailFileName;
  final int widthPixels;
  final int heightPixels;

  /// Size of the encrypted picture file, without the thumbnail.
  final int byteSize;

  Set<String> get allFileNames => {fileName, thumbnailFileName};

  @override
  bool operator ==(Object other) =>
      other is StoredMediaReference &&
      other.fileName == fileName &&
      other.thumbnailFileName == thumbnailFileName &&
      other.widthPixels == widthPixels &&
      other.heightPixels == heightPixels &&
      other.byteSize == byteSize;

  @override
  int get hashCode => Object.hash(fileName, thumbnailFileName, widthPixels, heightPixels, byteSize);
}
