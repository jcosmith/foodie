import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/domain.dart';

import '../domain/category.dart';
import '../domain/product.dart';
import '../domain/product_catalog_repository.dart';
import '../domain/product_icon_image.dart';

/// [ProductCatalogRepository] on top of the product catalog DAO.
final class DriftProductCatalogRepository implements ProductCatalogRepository {
  const DriftProductCatalogRepository(this._productCatalogDao);

  final ProductCatalogDao _productCatalogDao;

  @override
  Stream<List<Category>> watchCategories() =>
      _productCatalogDao.watchCategories().map((rows) => rows.map(_categoryFromRow).toList());

  @override
  Future<List<Category>> readCategories() async =>
      (await _productCatalogDao.readCategories()).map(_categoryFromRow).toList();

  @override
  Stream<List<Product>> watchProductsIncludingArchived() => _productCatalogDao
      .watchProducts(includeArchived: true)
      .map((rows) => rows.map(_productFromRow).toList());

  @override
  Future<Product?> readProduct(ProductIdentifier productIdentifier) async {
    final row = await _productCatalogDao.readProduct(productIdentifier.value);
    return row == null ? null : _productFromRow(row);
  }

  @override
  Future<Set<String>> readCategoryCatalogKeys() => _productCatalogDao.readCategoryCatalogKeys();

  @override
  Future<Set<String>> readProductCatalogKeys() => _productCatalogDao.readProductCatalogKeys();

  @override
  Future<void> insertCategory(Category category) =>
      _productCatalogDao.insertCategory(_rowFromCategory(category));

  @override
  Future<void> updateCategory(Category category) =>
      _productCatalogDao.replaceCategory(_rowFromCategory(category));

  @override
  Future<void> insertProduct(Product product) =>
      _productCatalogDao.insertProduct(_rowFromProduct(product));

  @override
  Future<void> updateProduct(Product product) =>
      _productCatalogDao.replaceProduct(_rowFromProduct(product));

  static Category _categoryFromRow(CategoryRow row) => Category(
    identifier: CategoryIdentifier(row.categoryIdentifier),
    catalogKey: row.catalogKey,
    customName: row.customName,
    recommendedMaximumStorageDays: row.recommendedMaximumStorageDays,
    iconEmoji: row.iconEmoji,
    sortOrder: row.sortOrder,
  );

  static CategoryRow _rowFromCategory(Category category) => CategoryRow(
    categoryIdentifier: category.identifier.value,
    catalogKey: category.catalogKey,
    customName: category.customName,
    recommendedMaximumStorageDays: category.recommendedMaximumStorageDays,
    iconEmoji: category.iconEmoji,
    sortOrder: category.sortOrder,
  );

  static Product _productFromRow(ProductRow row) {
    final canonicalUnit = QuantityUnit.fromStorageName(row.canonicalUnit);
    final defaultPackageAmount = row.defaultPackageQuantity;
    return Product(
      identifier: ProductIdentifier(row.productIdentifier),
      categoryIdentifier: CategoryIdentifier(row.categoryIdentifier),
      catalogKey: row.catalogKey,
      customName: row.customName,
      canonicalUnit: canonicalUnit,
      defaultPackageQuantity: defaultPackageAmount == null
          ? null
          : Quantity(amountInBaseUnits: defaultPackageAmount, unit: canonicalUnit),
      recommendedMaximumStorageDays: row.recommendedMaximumStorageDays,
      iconEmoji: row.iconEmoji,
      iconImage: switch (row.iconImage) {
        final pngBytes? => ProductIconImage(pngBytes),
        null => null,
      },
      defaultCompartmentIdentifier: switch (row.defaultCompartmentIdentifier) {
        final compartmentIdentifier? => CompartmentIdentifier(compartmentIdentifier),
        null => null,
      },
      isArchived: row.isArchived,
      createdAt: row.createdAt,
    );
  }

  static ProductRow _rowFromProduct(Product product) => ProductRow(
    productIdentifier: product.identifier.value,
    categoryIdentifier: product.categoryIdentifier.value,
    catalogKey: product.catalogKey,
    customName: product.customName,
    canonicalUnit: product.canonicalUnit.storageName,
    defaultPackageQuantity: product.defaultPackageQuantity?.amountInBaseUnits,
    recommendedMaximumStorageDays: product.recommendedMaximumStorageDays,
    iconEmoji: product.iconEmoji,
    iconImage: product.iconImage?.pngBytes,
    defaultCompartmentIdentifier: product.defaultCompartmentIdentifier?.value,
    isArchived: product.isArchived,
    createdAt: product.createdAt,
  );
}
