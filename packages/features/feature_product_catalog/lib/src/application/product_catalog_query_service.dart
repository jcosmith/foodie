import 'package:core_foundation/core_foundation.dart';

import '../domain/product.dart';
import '../domain/product_catalog.dart';
import '../domain/product_catalog_repository.dart';

/// Read-only access to categories and products for other features.
final class ProductCatalogQueryService {
  const ProductCatalogQueryService(this._repository);

  final ProductCatalogRepository _repository;

  /// The catalog, updated whenever a category or product changes.
  Stream<ProductCatalog> watchCatalog() => combineLatestOfTwo(
    _repository.watchCategories(),
    _repository.watchProductsIncludingArchived(),
    (categories, products) =>
        ProductCatalog(categories: categories, productsIncludingArchived: products),
  );

  Future<ProductCatalog> readCatalog() => watchCatalog().first;

  /// Any product, archived ones included.
  Future<Product?> readProduct(ProductIdentifier productIdentifier) =>
      _repository.readProduct(productIdentifier);
}
