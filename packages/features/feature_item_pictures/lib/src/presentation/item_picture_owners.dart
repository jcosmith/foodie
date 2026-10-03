import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';

import '../domain/item_picture.dart';

/// The owner whose own picture a visual subject means.
ItemPictureOwner itemPictureOwnerOf(ItemVisualSubject subject) => switch (subject) {
  ProductItemVisualSubject(:final productIdentifier) => ProductPictureOwner(
    ProductIdentifier(productIdentifier),
  ),
  StockBatchItemVisualSubject(:final stockBatchIdentifier) => StockBatchPictureOwner(
    StockBatchIdentifier(stockBatchIdentifier),
  ),
};

/// The picture to show for a subject: a batch falls back to its product's.
ItemPicture? itemPictureToShowFor(ItemPictureCatalog catalog, ItemVisualSubject subject) =>
    switch (subject) {
      ProductItemVisualSubject(:final productIdentifier) => catalog.pictureOf(
        ProductPictureOwner(ProductIdentifier(productIdentifier)),
      ),
      StockBatchItemVisualSubject(:final stockBatchIdentifier, :final productIdentifier) =>
        catalog.pictureForBatch(
          stockBatchIdentifier: StockBatchIdentifier(stockBatchIdentifier),
          productIdentifier: ProductIdentifier(productIdentifier),
        ),
    };
