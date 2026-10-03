import 'category.dart';
import 'product.dart';

/// Storage of categories and products, implemented on the product catalog DAO.
abstract interface class ProductCatalogRepository {
  Stream<List<Category>> watchCategories();

  Future<List<Category>> readCategories();

  /// Products including archived ones, so history keeps its names.
  Stream<List<Product>> watchProductsIncludingArchived();

  Future<Product?> readProduct(ProductIdentifier productIdentifier);

  Future<Set<String>> readCategoryCatalogKeys();

  Future<Set<String>> readProductCatalogKeys();

  Future<void> insertCategory(Category category);

  Future<void> updateCategory(Category category);

  Future<void> insertProduct(Product product);

  Future<void> updateProduct(Product product);
}
