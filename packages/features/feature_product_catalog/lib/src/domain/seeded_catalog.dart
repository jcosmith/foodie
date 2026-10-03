import 'package:core_foundation/core_foundation.dart';

/// A category that ships with the app.
final class SeededCategory {
  const SeededCategory({
    required this.catalogKey,
    required this.recommendedMaximumStorageDays,
    required this.iconEmoji,
  });

  final String catalogKey;
  final int recommendedMaximumStorageDays;
  final String iconEmoji;
}

/// A product that ships with the app; its name is translated through its
/// catalog key until the user renames it.
final class SeededProduct {
  const SeededProduct({
    required this.catalogKey,
    required this.categoryCatalogKey,
    required this.canonicalUnit,
    required this.defaultPackageDisplayAmount,
    required this.iconEmoji,
  });

  final String catalogKey;
  final String categoryCatalogKey;
  final QuantityUnit canonicalUnit;

  /// In display units: grams, millilitres, pieces or portions.
  final num defaultPackageDisplayAmount;

  final String iconEmoji;

  Quantity get defaultPackageQuantity =>
      Quantity.fromDisplayAmount(defaultPackageDisplayAmount, canonicalUnit);
}

/// The offline catalog seeded on first start (no online product database is
/// ever queried). Storage times are common household recommendations, shown
/// as guidance and editable; they are not safety guarantees.
abstract final class SeededCatalog {
  static const List<SeededCategory> categories = [
    SeededCategory(catalogKey: 'vegetables', recommendedMaximumStorageDays: 365, iconEmoji: '🥦'),
    SeededCategory(catalogKey: 'fruit', recommendedMaximumStorageDays: 300, iconEmoji: '🍓'),
    SeededCategory(catalogKey: 'meatAndFish', recommendedMaximumStorageDays: 270, iconEmoji: '🥩'),
    SeededCategory(catalogKey: 'meals', recommendedMaximumStorageDays: 120, iconEmoji: '🍲'),
    SeededCategory(catalogKey: 'bakery', recommendedMaximumStorageDays: 90, iconEmoji: '🍞'),
    SeededCategory(catalogKey: 'desserts', recommendedMaximumStorageDays: 180, iconEmoji: '🍨'),
    SeededCategory(catalogKey: 'other', recommendedMaximumStorageDays: 180, iconEmoji: '📦'),
  ];

  static const List<SeededProduct> products = [
    SeededProduct(
      catalogKey: 'leafSpinach',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 1000,
      iconEmoji: '🥬',
    ),
    SeededProduct(
      catalogKey: 'gardenPeas',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 750,
      iconEmoji: '🫛',
    ),
    SeededProduct(
      catalogKey: 'broccoli',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 450,
      iconEmoji: '🥦',
    ),
    SeededProduct(
      catalogKey: 'mixedVegetables',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 750,
      iconEmoji: '🥕',
    ),
    SeededProduct(
      catalogKey: 'herbs',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 50,
      iconEmoji: '🌿',
    ),
    SeededProduct(
      catalogKey: 'frenchFries',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 750,
      iconEmoji: '🍟',
    ),
    SeededProduct(
      catalogKey: 'mixedBerries',
      categoryCatalogKey: 'fruit',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🫐',
    ),
    SeededProduct(
      catalogKey: 'strawberries',
      categoryCatalogKey: 'fruit',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🍓',
    ),
    SeededProduct(
      catalogKey: 'mango',
      categoryCatalogKey: 'fruit',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 400,
      iconEmoji: '🥭',
    ),
    SeededProduct(
      catalogKey: 'chickenBreast',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 800,
      iconEmoji: '🍗',
    ),
    SeededProduct(
      catalogKey: 'mincedMeat',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🥩',
    ),
    SeededProduct(
      catalogKey: 'salmonFillet',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 250,
      iconEmoji: '🐟',
    ),
    SeededProduct(
      catalogKey: 'fishFingers',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 15,
      iconEmoji: '🐠',
    ),
    SeededProduct(
      catalogKey: 'prawns',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 400,
      iconEmoji: '🦐',
    ),
    SeededProduct(
      catalogKey: 'bologneseHomemade',
      categoryCatalogKey: 'meals',
      canonicalUnit: QuantityUnit.portion,
      defaultPackageDisplayAmount: 4,
      iconEmoji: '🍝',
    ),
    SeededProduct(
      catalogKey: 'soupHomemade',
      categoryCatalogKey: 'meals',
      canonicalUnit: QuantityUnit.portion,
      defaultPackageDisplayAmount: 2,
      iconEmoji: '🍲',
    ),
    SeededProduct(
      catalogKey: 'lasagne',
      categoryCatalogKey: 'meals',
      canonicalUnit: QuantityUnit.portion,
      defaultPackageDisplayAmount: 4,
      iconEmoji: '🥘',
    ),
    SeededProduct(
      catalogKey: 'pizzaMargherita',
      categoryCatalogKey: 'meals',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🍕',
    ),
    SeededProduct(
      catalogKey: 'wholegrainBread',
      categoryCatalogKey: 'bakery',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 10,
      iconEmoji: '🍞',
    ),
    SeededProduct(
      catalogKey: 'breadRolls',
      categoryCatalogKey: 'bakery',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 6,
      iconEmoji: '🥖',
    ),
    SeededProduct(
      catalogKey: 'croissants',
      categoryCatalogKey: 'bakery',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 6,
      iconEmoji: '🥐',
    ),
    SeededProduct(
      catalogKey: 'vanillaIceCream',
      categoryCatalogKey: 'desserts',
      canonicalUnit: QuantityUnit.milliliter,
      defaultPackageDisplayAmount: 1000,
      iconEmoji: '🍨',
    ),
    SeededProduct(
      catalogKey: 'cake',
      categoryCatalogKey: 'desserts',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🍰',
    ),
    SeededProduct(
      catalogKey: 'butter',
      categoryCatalogKey: 'other',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 250,
      iconEmoji: '🧈',
    ),
  ];
}
