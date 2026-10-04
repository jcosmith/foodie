import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';

/// How much of each product is at home, over all its batches.
Map<ProductIdentifier, Quantity> sumStockByProduct(Iterable<StockBatch> activeBatches) {
  final stockByProduct = <ProductIdentifier, Quantity>{};
  for (final batch in activeBatches) {
    final stockSoFar = stockByProduct[batch.productIdentifier];
    stockByProduct[batch.productIdentifier] = stockSoFar == null
        ? batch.quantityRemaining
        : stockSoFar + batch.quantityRemaining;
  }
  return stockByProduct;
}
