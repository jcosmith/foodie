import 'package:flutter/widgets.dart';

import '../domain/catalog_names.dart';
import '../domain/product_catalog_failure.dart';
import '../l10n/generated/product_catalog_localizations.dart';

/// Seeded catalog names in the current app language.
final class LocalizedCatalogNames implements CatalogNames {
  const LocalizedCatalogNames(this._localizations);

  final ProductCatalogLocalizations _localizations;

  @override
  String? categoryName(String catalogKey) => switch (catalogKey) {
    'vegetables' => _localizations.categoryVegetables,
    'fruit' => _localizations.categoryFruit,
    'meatAndFish' => _localizations.categoryMeatAndFish,
    'meals' => _localizations.categoryMeals,
    'bakery' => _localizations.categoryBakery,
    'desserts' => _localizations.categoryDesserts,
    'other' => _localizations.categoryOther,
    _ => null,
  };

  @override
  String? productName(String catalogKey) => switch (catalogKey) {
    'leafSpinach' => _localizations.productLeafSpinach,
    'gardenPeas' => _localizations.productGardenPeas,
    'broccoli' => _localizations.productBroccoli,
    'mixedVegetables' => _localizations.productMixedVegetables,
    'herbs' => _localizations.productHerbs,
    'frenchFries' => _localizations.productFrenchFries,
    'mixedBerries' => _localizations.productMixedBerries,
    'strawberries' => _localizations.productStrawberries,
    'mango' => _localizations.productMango,
    'chickenBreast' => _localizations.productChickenBreast,
    'mincedMeat' => _localizations.productMincedMeat,
    'salmonFillet' => _localizations.productSalmonFillet,
    'fishFingers' => _localizations.productFishFingers,
    'prawns' => _localizations.productPrawns,
    'bologneseHomemade' => _localizations.productBologneseHomemade,
    'soupHomemade' => _localizations.productSoupHomemade,
    'lasagne' => _localizations.productLasagne,
    'pizzaMargherita' => _localizations.productPizzaMargherita,
    'wholegrainBread' => _localizations.productWholegrainBread,
    'breadRolls' => _localizations.productBreadRolls,
    'croissants' => _localizations.productCroissants,
    'vanillaIceCream' => _localizations.productVanillaIceCream,
    'cake' => _localizations.productCake,
    'butter' => _localizations.productButter,
    _ => null,
  };
}

/// Display names for screens of any feature that shows products.
extension ProductCatalogLocalizationContext on BuildContext {
  /// Seeded catalog names in the current app language.
  CatalogNames get catalogNames => LocalizedCatalogNames(ProductCatalogLocalizations.of(this));

  ProductDisplayNameResolver get productDisplayNameResolver =>
      ProductDisplayNameResolver(catalogNames);
}

extension ProductCatalogFailureTexts on ProductCatalogLocalizations {
  String describeFailure(ProductCatalogFailure failure) => switch (failure) {
    ProductNameMissing() => nameMissing,
    ProductNameTooLong() => nameTooLong,
    InvalidProductSetting() => invalidSetting,
    UnreadableIconImage() => iconImageUnreadable,
    ProductNotFound() || CategoryNotFound() => genericFailure,
  };
}
