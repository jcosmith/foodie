import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

typedef ItemPictureIdentifier = TypedIdentifier<ItemPicture>;

/// What a picture belongs to: a product (its catalog photo, shown wherever
/// the product appears) or one stock batch (the label of a homemade meal).
@immutable
sealed class ItemPictureOwner {
  const ItemPictureOwner();

  /// How the owner is stored: `product` or `stock_batch`.
  String get kindStorageName;

  String get identifierValue;

  static ItemPictureOwner fromStorage({required String kind, required String identifier}) =>
      switch (kind) {
        ProductPictureOwner.storageName => ProductPictureOwner(ProductIdentifier(identifier)),
        StockBatchPictureOwner.storageName => StockBatchPictureOwner(
          StockBatchIdentifier(identifier),
        ),
        _ => throw ArgumentError.value(kind, 'kind', 'Unknown picture owner'),
      };

  @override
  bool operator ==(Object other) =>
      other is ItemPictureOwner &&
      other.kindStorageName == kindStorageName &&
      other.identifierValue == identifierValue;

  @override
  int get hashCode => Object.hash(kindStorageName, identifierValue);
}

final class ProductPictureOwner extends ItemPictureOwner {
  const ProductPictureOwner(this.productIdentifier);

  static const String storageName = 'product';

  final ProductIdentifier productIdentifier;

  @override
  String get kindStorageName => storageName;

  @override
  String get identifierValue => productIdentifier.value;
}

final class StockBatchPictureOwner extends ItemPictureOwner {
  const StockBatchPictureOwner(this.stockBatchIdentifier);

  static const String storageName = 'stock_batch';

  final StockBatchIdentifier stockBatchIdentifier;

  @override
  String get kindStorageName => storageName;

  @override
  String get identifierValue => stockBatchIdentifier.value;
}

/// Where a stored picture and its thumbnail are; public API for other
/// modules that need to know whether an item has a picture.
@immutable
final class ItemPictureReference {
  const ItemPictureReference({
    required this.encryptedFileName,
    required this.thumbnailFileName,
    required this.widthPixels,
    required this.heightPixels,
    required this.byteSize,
  });

  final String encryptedFileName;
  final String thumbnailFileName;
  final int widthPixels;
  final int heightPixels;
  final int byteSize;

  Set<String> get allFileNames => {encryptedFileName, thumbnailFileName};

  @override
  bool operator ==(Object other) =>
      other is ItemPictureReference &&
      other.encryptedFileName == encryptedFileName &&
      other.thumbnailFileName == thumbnailFileName &&
      other.widthPixels == widthPixels &&
      other.heightPixels == heightPixels &&
      other.byteSize == byteSize;

  @override
  int get hashCode =>
      Object.hash(encryptedFileName, thumbnailFileName, widthPixels, heightPixels, byteSize);
}

/// The one picture of a product or a stock batch.
@immutable
final class ItemPicture {
  const ItemPicture({
    required this.identifier,
    required this.owner,
    required this.reference,
    required this.createdAt,
  });

  final ItemPictureIdentifier identifier;
  final ItemPictureOwner owner;
  final ItemPictureReference reference;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is ItemPicture &&
      other.identifier == identifier &&
      other.owner == owner &&
      other.reference == reference &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(identifier, owner, reference, createdAt);
}

/// All pictures, looked up by owner.
@immutable
final class ItemPictureCatalog {
  ItemPictureCatalog(Iterable<ItemPicture> pictures)
    : _picturesByOwner = {for (final picture in pictures) picture.owner: picture};

  static final ItemPictureCatalog empty = ItemPictureCatalog(const []);

  final Map<ItemPictureOwner, ItemPicture> _picturesByOwner;

  Iterable<ItemPicture> get pictures => _picturesByOwner.values;

  ItemPicture? pictureOf(ItemPictureOwner owner) => _picturesByOwner[owner];

  /// A batch's own picture, or else its product's picture.
  ItemPicture? pictureForBatch({
    required StockBatchIdentifier stockBatchIdentifier,
    required ProductIdentifier productIdentifier,
  }) =>
      _picturesByOwner[StockBatchPictureOwner(stockBatchIdentifier)] ??
      _picturesByOwner[ProductPictureOwner(productIdentifier)];

  /// Every file a picture row refers to, for the orphan sweep.
  Set<String> get referencedFileNames => {
    for (final picture in pictures) ...picture.reference.allFileNames,
  };
}
