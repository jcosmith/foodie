import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:meta/meta.dart';

import '../domain/stock_batch.dart';
import '../domain/use_by_policy.dart';

/// A batch with everything a list row shows about it.
@immutable
final class InventoryItem {
  const InventoryItem({
    required this.batch,
    required this.product,
    required this.category,
    required this.compartment,
    required this.iconEmoji,
    required this.useByStatus,
    this.useBy,
  });

  final StockBatch batch;
  final Product product;
  final Category? category;
  final Compartment? compartment;
  final String iconEmoji;
  final UseByStatus useByStatus;

  /// When the batch should be used; `null` when nothing says so.
  final UseByDeadline? useBy;

  /// Orders by the time left, least first: the earliest last good day
  /// first, items without one last, and otherwise the oldest stored first.
  static int compareByUseBy(InventoryItem first, InventoryItem second) {
    final byUseBy = switch ((first.useBy?.lastGoodDay, second.useBy?.lastGoodDay)) {
      (null, null) => 0,
      (null, _) => 1,
      (_, null) => -1,
      (final firstDay?, final secondDay?) => firstDay.compareTo(secondDay),
    };
    return byUseBy != 0 ? byUseBy : first.batch.storedOn.compareTo(second.batch.storedOn);
  }
}

/// [items] ordered by the time left, least first
/// ([InventoryItem.compareByUseBy]); the order is stable.
List<InventoryItem> sortedByUseBy(Iterable<InventoryItem> items) {
  final indexedItems = items.indexed.toList()
    ..sort((first, second) {
      final byUseBy = InventoryItem.compareByUseBy(first.$2, second.$2);
      return byUseBy != 0 ? byUseBy : first.$1.compareTo(second.$1);
    });
  return [for (final (_, item) in indexedItems) item];
}

/// What is stored joined with the catalog and the layout.
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
    final useBy = UseByPolicy.deadlineOfBatch(
      batch,
      shelfLifeDays: catalog.recommendedMaximumStorageDaysOf(product),
      shelfLifeAfterOpeningDays: catalog.shelfLifeAfterOpeningDaysOf(product),
    );
    return InventoryItem(
      batch: batch,
      product: product,
      category: catalog.categoryOfProduct(product),
      compartment: layout.compartmentOf(batch.compartmentIdentifier),
      iconEmoji: catalog.iconEmojiOf(product),
      useByStatus: useBy?.statusOn(today) ?? UseByStatus.fresh,
      useBy: useBy,
    );
  }

  /// Oldest stored first.
  final List<InventoryItem> items;
  final ProductCatalog catalog;
  final StorageLayout layout;
  final CalendarDate today;

  bool get hasStoragePlace => layout.hasStoragePlace;

  /// The part of the overview one domain tab shows: its items, and a layout
  /// with only its storage places.
  InventoryOverview ofDomain(StorageDomainIdentifier domainIdentifier) => InventoryOverview(
    items: [
      for (final item in items)
        if (layout.domainOfCompartment(item.batch.compartmentIdentifier) == domainIdentifier) item,
    ],
    catalog: catalog,
    layout: layout.restrictedTo(domainIdentifier),
    today: today,
  );

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
