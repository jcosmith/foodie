import 'category.dart';
import 'product.dart';

/// Translated names of seeded catalog entries, implemented by the
/// presentation layer with the current localizations.
abstract interface class CatalogNames {
  /// The translated name for a seeded category key, or `null` if unknown.
  String? categoryName(String catalogKey);

  /// The translated name for a seeded product key, or `null` if unknown.
  String? productName(String catalogKey);
}

/// Names as users see them (decision D6): their own name if they typed one,
/// otherwise the translation of the catalog key.
final class ProductDisplayNameResolver {
  const ProductDisplayNameResolver(this._catalogNames);

  final CatalogNames _catalogNames;

  String productName(Product product) => _resolve(
    customName: product.customName,
    catalogKey: product.catalogKey,
    translate: _catalogNames.productName,
  );

  String categoryName(Category category) => _resolve(
    customName: category.customName,
    catalogKey: category.catalogKey,
    translate: _catalogNames.categoryName,
  );

  static String _resolve({
    required String? customName,
    required String? catalogKey,
    required String? Function(String catalogKey) translate,
  }) {
    if (customName != null) return customName;
    if (catalogKey == null) return '';
    return translate(catalogKey) ?? catalogKey;
  }
}
