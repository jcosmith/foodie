import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_product_catalog/src/domain/seeded_catalog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in ProductCatalogLocalizations.supportedLocales) {
    test('every seeded entry has a ${locale.languageCode} name', () {
      final catalogNames = LocalizedCatalogNames(lookupProductCatalogLocalizations(locale));

      for (final category in SeededCatalog.categories) {
        expect(
          catalogNames.categoryName(category.catalogKey),
          isNotNull,
          reason: category.catalogKey,
        );
      }
      for (final product in SeededCatalog.products) {
        expect(catalogNames.productName(product.catalogKey), isNotNull, reason: product.catalogKey);
      }
    });
  }

  test('seeded keys are unique and point at seeded categories', () {
    final categoryKeys = {for (final category in SeededCatalog.categories) category.catalogKey};
    final productKeys = [for (final product in SeededCatalog.products) product.catalogKey];

    expect(productKeys.toSet(), hasLength(productKeys.length));
    for (final product in SeededCatalog.products) {
      expect(categoryKeys, contains(product.categoryCatalogKey));
    }
  });

  test('user names win over translations', () {
    final resolver = ProductDisplayNameResolver(
      LocalizedCatalogNames(lookupProductCatalogLocalizations(const Locale('de'))),
    );
    final spinach = Product(
      identifier: const ProductIdentifier('spinach'),
      categoryIdentifier: const CategoryIdentifier('vegetables'),
      catalogKey: 'leafSpinach',
      canonicalUnit: QuantityUnit.gram,
      createdAt: DateTime.utc(2026),
    );

    expect(resolver.productName(spinach), 'Blattspinat');
    expect(
      resolver.productName(spinach.copyWith(customName: () => 'Spinat vom Markt')),
      'Spinat vom Markt',
    );
  });
}
