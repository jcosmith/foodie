import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:meta/meta.dart';

import '../domain/stock_batch.dart';
import '../domain/storage_age_policy.dart';

/// A batch with everything a list row shows about it.
@immutable
final class InventoryItem {
  const InventoryItem({
    required this.batch,
    required this.product,
    required this.category,
    required this.compartment,
    required this.iconEmoji,
    required this.storageAgeStatus,
    this.eatBefore,
  });

  final StockBatch batch;
  final Product product;
  final Category? category;
  final Compartment? compartment;
  final String iconEmoji;
  final StorageAgeStatus storageAgeStatus;

  /// The day the recommended maximum storage time is used up; `null` when
  /// there is no recommendation.
  final CalendarDate? eatBefore;

  /// Orders by the freshness time left, least first: the earliest
  /// [eatBefore] first, items without one last, and otherwise the oldest
  /// frozen first.
  static int compareByEatBefore(InventoryItem first, InventoryItem second) {
    final firstEatBefore = first.eatBefore;
    final secondEatBefore = second.eatBefore;
    final byEatBefore = switch ((firstEatBefore, secondEatBefore)) {
      (null, null) => 0,
      (null, _) => 1,
      (_, null) => -1,
      (final firstDay?, final secondDay?) => firstDay.compareTo(secondDay),
    };
    return byEatBefore != 0 ? byEatBefore : first.batch.storedOn.compareTo(second.batch.storedOn);
  }
}

/// [items] ordered by the freshness time left, least first
/// ([InventoryItem.compareByEatBefore]); the order is stable.
List<InventoryItem> sortedByEatBefore(Iterable<InventoryItem> items) {
  final indexedItems = items.indexed.toList()
    ..sort((first, second) {
      final byEatBefore = InventoryItem.compareByEatBefore(first.$2, second.$2);
      return byEatBefore != 0 ? byEatBefore : first.$1.compareTo(second.$1);
    });
  return [for (final (_, item) in indexedItems) item];
}

/// The freezer contents joined with the catalog and the layout.
@immutable
final class InventoryOverview {
  const InventoryOverview({
    required this.items,
    required this.catalog,
    required this.layout,
    required this.today,
  });

  /// Builds the overview; batches of unknown products are left out.
  factory InventoryOverview.combine({
    required List<StockBatch> activeBatches,
    required ProductCatalog catalog,
    required StorageLayout layout,
    required CalendarDate today,
  }) => InventoryOverview(
    items: [
      for (final batch in activeBatches)
        if (catalog.productOf(batch.productIdentifier) case final product?)
          _itemOf(batch: batch, product: product, catalog: catalog, layout: layout, today: today),
    ],
    catalog: catalog,
    layout: layout,
    today: today,
  );

  static InventoryItem _itemOf({
    required StockBatch batch,
    required Product product,
    required ProductCatalog catalog,
    required StorageLayout layout,
    required CalendarDate today,
  }) {
    final recommendedMaximumStorageDays = catalog.recommendedMaximumStorageDaysOf(product) ?? 0;
    return InventoryItem(
      batch: batch,
      product: product,
      category: catalog.categoryOfProduct(product),
      compartment: layout.compartmentOf(batch.compartmentIdentifier),
      iconEmoji: catalog.iconEmojiOf(product),
      storageAgeStatus: StorageAgePolicy.evaluate(
        storedOn: batch.storedOn,
        today: today,
        recommendedMaximumStorageDays: recommendedMaximumStorageDays,
      ),
      eatBefore: recommendedMaximumStorageDays <= 0
          ? null
          : StorageAgePolicy.storageLimitReachedOn(
              storedOn: batch.storedOn,
              recommendedMaximumStorageDays: recommendedMaximumStorageDays,
            ),
    );
  }

  /// Oldest frozen first.
  final List<InventoryItem> items;
  final ProductCatalog catalog;
  final StorageLayout layout;
  final CalendarDate today;

  bool get hasStoragePlace => layout.hasStoragePlace;

  /// Items of one compartment, oldest frozen first.
  List<InventoryItem> itemsIn(CompartmentIdentifier compartmentIdentifier) => [
    for (final item in items)
      if (item.batch.compartmentIdentifier == compartmentIdentifier) item,
  ];

  /// Bags of one product, oldest frozen first (first in, first out).
  List<InventoryItem> itemsOfProduct(ProductIdentifier productIdentifier) => [
    for (final item in items)
      if (item.product.identifier == productIdentifier) item,
  ];

  InventoryItem? itemOf(StockBatchIdentifier stockBatchIdentifier) {
    for (final item in items) {
      if (item.batch.identifier == stockBatchIdentifier) return item;
    }
    return null;
  }
}
