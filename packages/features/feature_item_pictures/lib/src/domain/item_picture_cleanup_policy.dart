import 'package:core_events/core_events.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';

import 'item_picture.dart';

/// Which picture goes away after a domain event (architecture document,
/// section 10.2): a batch's picture once the batch is used up or thrown
/// away completely, a product's picture once the product is archived.
abstract final class ItemPictureCleanupPolicy {
  static ItemPictureOwner? ownerToCleanUpAfter(DomainEvent event) => switch (event) {
    StockBatchConsumed(:final quantityRemaining, :final stockBatchIdentifier) ||
    StockBatchDiscarded(
      :final quantityRemaining,
      :final stockBatchIdentifier,
    ) when quantityRemaining.isZero => StockBatchPictureOwner(stockBatchIdentifier),
    ProductArchived(:final productIdentifier) => ProductPictureOwner(productIdentifier),
    _ => null,
  };
}
