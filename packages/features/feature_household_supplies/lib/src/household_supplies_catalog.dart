import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';

/// Supplies a household uses up and buys again, seeded offline (no online
/// product database is ever queried). They keep no shelf life, so they never
/// become due; a date printed on a package can still be entered.
abstract final class HouseholdSuppliesCatalog {
  static const List<SeededCategoryContribution> categories = [
    SeededCategoryContribution(
      catalogKey: 'cleaning',
      domainIdentifier: StorageDomainIdentifier.household,
      iconEmoji: '🧽',
    ),
    SeededCategoryContribution(
      catalogKey: 'laundry',
      domainIdentifier: StorageDomainIdentifier.household,
      iconEmoji: '🧺',
    ),
    SeededCategoryContribution(
      catalogKey: 'bathroomAndCare',
      domainIdentifier: StorageDomainIdentifier.household,
      iconEmoji: '🧼',
    ),
    SeededCategoryContribution(
      catalogKey: 'kitchenPaperAndWrap',
      domainIdentifier: StorageDomainIdentifier.household,
      iconEmoji: '🧻',
    ),
  ];

  static const List<SeededProductContribution> products = [
    SeededProductContribution(
      catalogKey: 'dishSoap',
      categoryCatalogKey: 'cleaning',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧴',
    ),
    SeededProductContribution(
      catalogKey: 'dishwasherTabs',
      categoryCatalogKey: 'cleaning',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 40,
      iconEmoji: '🫧',
    ),
    SeededProductContribution(
      catalogKey: 'allPurposeCleaner',
      categoryCatalogKey: 'cleaning',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧴',
    ),
    SeededProductContribution(
      catalogKey: 'glassCleaner',
      categoryCatalogKey: 'cleaning',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🪟',
    ),
    SeededProductContribution(
      catalogKey: 'descaler',
      categoryCatalogKey: 'cleaning',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧪',
    ),
    SeededProductContribution(
      catalogKey: 'spongesAndCloths',
      categoryCatalogKey: 'cleaning',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 5,
      iconEmoji: '🧽',
    ),
    SeededProductContribution(
      catalogKey: 'binBags',
      categoryCatalogKey: 'cleaning',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 20,
      iconEmoji: '🗑️',
    ),
    SeededProductContribution(
      catalogKey: 'detergent',
      categoryCatalogKey: 'laundry',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧺',
    ),
    SeededProductContribution(
      catalogKey: 'softener',
      categoryCatalogKey: 'laundry',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🌸',
    ),
    SeededProductContribution(
      catalogKey: 'stainRemover',
      categoryCatalogKey: 'laundry',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧴',
    ),
    SeededProductContribution(
      catalogKey: 'toiletPaper',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 8,
      iconEmoji: '🧻',
    ),
    SeededProductContribution(
      catalogKey: 'handSoap',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧼',
    ),
    SeededProductContribution(
      catalogKey: 'toothpaste',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🪥',
    ),
    SeededProductContribution(
      catalogKey: 'toothbrushes',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 2,
      iconEmoji: '🪥',
    ),
    SeededProductContribution(
      catalogKey: 'shampoo',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧴',
    ),
    SeededProductContribution(
      catalogKey: 'showerGel',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧴',
    ),
    SeededProductContribution(
      catalogKey: 'deodorant',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🧴',
    ),
    SeededProductContribution(
      catalogKey: 'razorBlades',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 4,
      iconEmoji: '🪒',
    ),
    SeededProductContribution(
      catalogKey: 'cottonPads',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 80,
      iconEmoji: '⚪',
    ),
    SeededProductContribution(
      catalogKey: 'sanitaryProducts',
      categoryCatalogKey: 'bathroomAndCare',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 20,
      iconEmoji: '🩸',
    ),
    SeededProductContribution(
      catalogKey: 'kitchenRoll',
      categoryCatalogKey: 'kitchenPaperAndWrap',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 4,
      iconEmoji: '🧻',
    ),
    SeededProductContribution(
      catalogKey: 'tissues',
      categoryCatalogKey: 'kitchenPaperAndWrap',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 10,
      iconEmoji: '🤧',
    ),
    SeededProductContribution(
      catalogKey: 'aluminiumFoil',
      categoryCatalogKey: 'kitchenPaperAndWrap',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🥡',
    ),
    SeededProductContribution(
      catalogKey: 'clingFilm',
      categoryCatalogKey: 'kitchenPaperAndWrap',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '🎞️',
    ),
    SeededProductContribution(
      catalogKey: 'bakingPaper',
      categoryCatalogKey: 'kitchenPaperAndWrap',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 1,
      iconEmoji: '📜',
    ),
    SeededProductContribution(
      catalogKey: 'freezerBags',
      categoryCatalogKey: 'kitchenPaperAndWrap',
      canonicalUnit: QuantityUnit.piece,
      defaultPackageDisplayAmount: 50,
      iconEmoji: '🛍️',
    ),
  ];
}
