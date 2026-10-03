import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'product_catalog_tables.dart';

part 'product_catalog_dao.g.dart';

/// Data access for feature_product_catalog.
@DriftAccessor(tables: [Categories, Products])
class ProductCatalogDao extends DatabaseAccessor<ApplicationDatabase>
    with _$ProductCatalogDaoMixin {
  ProductCatalogDao(super.attachedDatabase);

  Stream<List<CategoryRow>> watchCategories() =>
      (select(categories)..orderBy([(category) => OrderingTerm.asc(category.sortOrder)])).watch();

  Future<List<CategoryRow>> readCategories() =>
      (select(categories)..orderBy([(category) => OrderingTerm.asc(category.sortOrder)])).get();

  Future<Set<String>> readCategoryCatalogKeys() async {
    final rows = await (selectOnly(
      categories,
    )..addColumns([categories.catalogKey])).map((row) => row.read(categories.catalogKey)).get();
    return rows.nonNulls.toSet();
  }

  Future<void> insertCategory(CategoryRow category) => into(categories).insert(category);

  Future<void> replaceCategory(CategoryRow category) => update(categories).replace(category);

  Stream<List<ProductRow>> watchProducts({bool includeArchived = false}) {
    final query = select(products);
    if (!includeArchived) query.where((product) => product.isArchived.equals(false));
    return query.watch();
  }

  Future<List<ProductRow>> readProducts({bool includeArchived = false}) {
    final query = select(products);
    if (!includeArchived) query.where((product) => product.isArchived.equals(false));
    return query.get();
  }

  Future<ProductRow?> readProduct(String productIdentifier) => (select(
    products,
  )..where((product) => product.productIdentifier.equals(productIdentifier))).getSingleOrNull();

  Future<Set<String>> readProductCatalogKeys() async {
    final rows = await (selectOnly(
      products,
    )..addColumns([products.catalogKey])).map((row) => row.read(products.catalogKey)).get();
    return rows.nonNulls.toSet();
  }

  Future<void> insertProduct(ProductRow product) => into(products).insert(product);

  Future<void> replaceProduct(ProductRow product) => update(products).replace(product);
}
