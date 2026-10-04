import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';

/// The frozen-food catalog that shipped with the freezer app, seeded offline
/// (no online product database is ever queried). Storage times are common
/// household recommendations, shown as guidance and editable; they are not
/// safety guarantees.
abstract final class FreezerCatalog {
  static const List<SeededCategoryContribution> categories = [
    SeededCategoryContribution(
      catalogKey: 'vegetables',
      domainIdentifier: StorageDomainIdentifier.freezer,
      shelfLifeDays: 365,
      iconEmoji: '🥦',
    ),
    SeededCategoryContribution(
      catalogKey: 'fruit',
      domainIdentifier: StorageDomainIdentifier.freezer,
      shelfLifeDays: 300,
      iconEmoji: '🍓',
    ),
    SeededCategoryContribution(
      catalogKey: 'meatAndFish',
      domainIdentifier: StorageDomainIdentifier.freezer,
      shelfLifeDays: 270,
      iconEmoji: '🥩',
    ),
    SeededCategoryContribution(
      catalogKey: 'meals',
      domainIdentifier: StorageDomainIdentifier.freezer,
      shelfLifeDays: 120,
      iconEmoji: '🍲',
    ),
    SeededCategoryContribution(
      catalogKey: 'bakery',
      domainIdentifier: StorageDomainIdentifier.freezer,
      shelfLifeDays: 90,
      iconEmoji: '🍞',
    ),
    SeededCategoryContribution(
      catalogKey: 'desserts',
      domainIdentifier: StorageDomainIdentifier.freezer,
      shelfLifeDays: 180,
      iconEmoji: '🍨',
    ),
    SeededCategoryContribution(
      catalogKey: 'other',
      domainIdentifier: StorageDomainIdentifier.freezer,
      shelfLifeDays: 180,
      iconEmoji: '📦',
    ),
  ];

  static const List<SeededProductContribution> products = [
    SeededProductContribution(
      catalogKey: 'leafSpinach',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 1000,
      iconEmoji: '🥬',
    ),
    SeededProductContribution(
      catalogKey: 'gardenPeas',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 750,
      iconEmoji: '🫛',
    ),
    SeededProductContribution(
      catalogKey: 'broccoli',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 450,
      iconEmoji: '🥦',
    ),
    SeededProductContribution(
      catalogKey: 'mixedVegetables',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 750,
      iconEmoji: '🥕',
    ),
    SeededProductContribution(
      catalogKey: 'herbs',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 50,
      iconEmoji: '🌿',
    ),
    SeededProductContribution(
      catalogKey: 'frenchFries',
      categoryCatalogKey: 'vegetables',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 750,
      iconEmoji: '🍟',
    ),
    SeededProductContribution(
      catalogKey: 'mixedBerries',
      categoryCatalogKey: 'fruit',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🫐',
    ),
    SeededProductContribution(
      catalogKey: 'strawberries',
      categoryCatalogKey: 'fruit',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🍓',
    ),
    SeededProductContribution(
      catalogKey: 'mango',
      categoryCatalogKey: 'fruit',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 400,
      iconEmoji: '🥭',
    ),
    SeededProductContribution(
      catalogKey: 'chickenBreast',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 800,
      iconEmoji: '🍗',
    ),
    SeededProductContribution(
      catalogKey: 'mincedMeat',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🥩',
    ),
    SeededProductContribution(
      catalogKey: 'salmonFillet',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 250,
      iconEmoji: '🐟',
    ),
    SeededProductContribution(
      catalogKey: 'fishFingers',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 15,
      iconEmoji: '🐠',
    ),
    SeededProductContribution(
      catalogKey: 'prawns',
      categoryCatalogKey: 'meatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 400,
      iconEmoji: '🦐',
    ),
    SeededProductContribution(
      catalogKey: 'bologneseHomemade',
      categoryCatalogKey: 'meals',
      canonicalUnit: QuantityUnit.portion,
      defaultPackageDisplayAmount: 4,
      iconEmoji: '🍝',
    ),
    SeededProductContribution(
      catalogKey: 'soupHomemade',
      categoryCatalogKey: 'meals',
      canonicalUnit: QuantityUnit.portion,
      defaultPackageDisplayAmount: 2,
      iconEmoji: '🍲',
    ),
    SeededProductContribution(
      catalogKey: 'lasagne',
      categoryCatalogKey: 'meals',
      canonicalUnit: QuantityUnit.portion,
      defaultPackageDisplayAmount: 4,
      iconEmoji: '🥘',
    ),
    SeededProductContribution(
      catalogKey: 'pizzaMargherita',
      categoryCatalogKey: 'meals',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🍕',
    ),
    SeededProductContribution(
      catalogKey: 'wholegrainBread',
      categoryCatalogKey: 'bakery',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 10,
      iconEmoji: '🍞',
    ),
    SeededProductContribution(
      catalogKey: 'breadRolls',
      categoryCatalogKey: 'bakery',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 6,
      iconEmoji: '🥖',
    ),
    SeededProductContribution(
      catalogKey: 'croissants',
      categoryCatalogKey: 'bakery',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 6,
      iconEmoji: '🥐',
    ),
    SeededProductContribution(
      catalogKey: 'vanillaIceCream',
      categoryCatalogKey: 'desserts',
      canonicalUnit: QuantityUnit.milliliter,
      defaultPackageDisplayAmount: 1000,
      iconEmoji: '🍨',
    ),
    SeededProductContribution(
      catalogKey: 'cake',
      categoryCatalogKey: 'desserts',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🍰',
    ),
    SeededProductContribution(
      catalogKey: 'butter',
      categoryCatalogKey: 'other',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 250,
      iconEmoji: '🧈',
    ),
  ];
}
