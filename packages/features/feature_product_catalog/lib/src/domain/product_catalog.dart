import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'category.dart';
import 'product.dart';

/// Categories and products as one read model with lookups.
@immutable
final class ProductCatalog {
  ProductCatalog({
    required List<Category> categories,
    required List<Product> productsIncludingArchived,
  }) : categories = List.unmodifiable(_sortedBySortOrder(categories)),
       _categoryByIdentifier = {for (final category in categories) category.identifier: category},
       _productByIdentifier = {
         for (final product in productsIncludingArchived) product.identifier: product,
       };

  static final ProductCatalog empty = ProductCatalog(
    categories: const [],
    productsIncludingArchived: const [],
  );

  static List<Category> _sortedBySortOrder(List<Category> categories) =>
      [...categories]..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));

  /// Categories in display order.
  final List<Category> categories;
  final Map<CategoryIdentifier, Category> _categoryByIdentifier;
  final Map<ProductIdentifier, Product> _productByIdentifier;

  /// Products the user can pick (not archived).
  Iterable<Product> get activeProducts =>
      _productByIdentifier.values.where((product) => !product.isArchived);

  Iterable<Product> activeProductsInCategory(CategoryIdentifier categoryIdentifier) =>
      activeProducts.where((product) => product.categoryIdentifier == categoryIdentifier);

  /// Any product, archived ones included.
  Product? productOf(ProductIdentifier productIdentifier) =>
      _productByIdentifier[productIdentifier];

  Category? categoryOf(CategoryIdentifier categoryIdentifier) =>
      _categoryByIdentifier[categoryIdentifier];

  Category? categoryOfProduct(Product product) => _categoryByIdentifier[product.categoryIdentifier];

  /// The emoji shown for a product: its own, else its category's.
  String iconEmojiOf(Product product) {
    final category = categoryOfProduct(product);
    return product.iconEmoji ?? category?.iconEmoji ?? '❄️';
  }

  /// The domain of the product's category; `null` for an unknown category.
  StorageDomainIdentifier? storageDomainOf(Product product) =>
      categoryOfProduct(product)?.storageDomain;

  /// The product's own shelf life after opening or its category's.
  int? shelfLifeAfterOpeningDaysOf(Product product) =>
      product.shelfLifeAfterOpeningDays ?? categoryOfProduct(product)?.shelfLifeAfterOpeningDays;

  /// The product's own recommendation or its category's.
  int? recommendedMaximumStorageDaysOf(Product product) {
    final category = categoryOfProduct(product);
    return product.recommendedMaximumStorageDays ?? category?.recommendedMaximumStorageDays;
  }
}
