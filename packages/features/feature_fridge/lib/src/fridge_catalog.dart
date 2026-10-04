import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';

/// Fresh food for the fridge, seeded offline (no online product database is
/// ever queried). Shelf lives are common household guidance for unopened
/// packages, with a shorter time once opened where that matters; they are
/// editable and not safety guarantees.
abstract final class FridgeCatalog {
  static const List<SeededCategoryContribution> categories = [
    SeededCategoryContribution(
      catalogKey: 'dairy',
      domainIdentifier: StorageDomainIdentifier.fridge,
      shelfLifeDays: 7,
      shelfLifeAfterOpeningDays: 3,
      iconEmoji: '🥛',
    ),
    SeededCategoryContribution(
      catalogKey: 'freshProduce',
      domainIdentifier: StorageDomainIdentifier.fridge,
      shelfLifeDays: 5,
      iconEmoji: '🥗',
    ),
    SeededCategoryContribution(
      catalogKey: 'freshMeatAndFish',
      domainIdentifier: StorageDomainIdentifier.fridge,
      shelfLifeDays: 2,
      iconEmoji: '🥩',
    ),
    SeededCategoryContribution(
      catalogKey: 'leftovers',
      domainIdentifier: StorageDomainIdentifier.fridge,
      shelfLifeDays: 3,
      iconEmoji: '🍱',
    ),
    SeededCategoryContribution(
      catalogKey: 'chilledOther',
      domainIdentifier: StorageDomainIdentifier.fridge,
      shelfLifeDays: 7,
      iconEmoji: '📦',
    ),
  ];

  static const List<SeededProductContribution> products = [
    SeededProductContribution(
      catalogKey: 'milk',
      categoryCatalogKey: 'dairy',
      canonicalUnit: QuantityUnit.milliliter,
      defaultPackageDisplayAmount: 1000,
      iconEmoji: '🥛',
      shelfLifeDays: 10,
      shelfLifeAfterOpeningDays: 3,
    ),
    SeededProductContribution(
      catalogKey: 'yoghurt',
      categoryCatalogKey: 'dairy',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🥣',
      shelfLifeDays: 14,
      shelfLifeAfterOpeningDays: 5,
    ),
    SeededProductContribution(
      catalogKey: 'cream',
      categoryCatalogKey: 'dairy',
      canonicalUnit: QuantityUnit.milliliter,
      defaultPackageDisplayAmount: 200,
      iconEmoji: '🍶',
      shelfLifeDays: 10,
      shelfLifeAfterOpeningDays: 3,
    ),
    SeededProductContribution(
      catalogKey: 'slicedCheese',
      categoryCatalogKey: 'dairy',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 150,
      iconEmoji: '🧀',
      shelfLifeDays: 21,
      shelfLifeAfterOpeningDays: 7,
    ),
    SeededProductContribution(
      catalogKey: 'mozzarella',
      categoryCatalogKey: 'dairy',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 125,
      iconEmoji: '🧀',
      shelfLifeDays: 14,
      shelfLifeAfterOpeningDays: 2,
    ),
    SeededProductContribution(
      catalogKey: 'eggs',
      categoryCatalogKey: 'dairy',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 10,
      iconEmoji: '🥚',
      shelfLifeDays: 21,
    ),
    SeededProductContribution(
      catalogKey: 'lettuce',
      categoryCatalogKey: 'freshProduce',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🥬',
    ),
    SeededProductContribution(
      catalogKey: 'tomatoes',
      categoryCatalogKey: 'freshProduce',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🍅',
      shelfLifeDays: 7,
    ),
    SeededProductContribution(
      catalogKey: 'cucumber',
      categoryCatalogKey: 'freshProduce',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🥒',
      shelfLifeDays: 7,
    ),
    SeededProductContribution(
      catalogKey: 'freshHerbs',
      categoryCatalogKey: 'freshProduce',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🌿',
      shelfLifeDays: 1,
    ),
    SeededProductContribution(
      catalogKey: 'freshMincedMeat',
      categoryCatalogKey: 'freshMeatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 500,
      iconEmoji: '🥩',
      shelfLifeDays: 1,
    ),
    SeededProductContribution(
      catalogKey: 'freshChickenBreast',
      categoryCatalogKey: 'freshMeatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 400,
      iconEmoji: '🍗',
    ),
    SeededProductContribution(
      catalogKey: 'freshFish',
      categoryCatalogKey: 'freshMeatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 300,
      iconEmoji: '🐟',
      shelfLifeDays: 1,
    ),
    SeededProductContribution(
      catalogKey: 'coldCuts',
      categoryCatalogKey: 'freshMeatAndFish',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 150,
      iconEmoji: '🥓',
      shelfLifeDays: 7,
      shelfLifeAfterOpeningDays: 3,
    ),
    SeededProductContribution(
      catalogKey: 'leftovers',
      categoryCatalogKey: 'leftovers',
      canonicalUnit: QuantityUnit.portion,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🍱',
    ),
    SeededProductContribution(
      catalogKey: 'pesto',
      categoryCatalogKey: 'chilledOther',
      canonicalUnit: QuantityUnit.gram,
      defaultPackageDisplayAmount: 190,
      iconEmoji: '🫙',
      shelfLifeDays: 60,
      shelfLifeAfterOpeningDays: 5,
    ),
  ];
}
