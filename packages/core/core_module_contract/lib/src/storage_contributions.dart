import 'package:core_foundation/core_foundation.dart';
import 'package:flutter/widgets.dart';

import 'contributions.dart';

/// Builds a localized text that contains a number, such as "Drawer 3" or
/// "5 shelves".
typedef LocalizedNumberTextBuilder = String Function(BuildContext context, int number);

/// Translates a seeded catalog key, or returns `null` for keys the
/// contribution does not know.
typedef CatalogNameBuilder = String? Function(BuildContext context, String catalogKey);

/// A storage domain such as the freezer or the pantry (architecture 10.7).
///
/// The module that contributes it is the domain's on/off switch: it is
/// optional, its navigation destination is the domain's tab, and switching
/// it off hides the domain everywhere without deleting anything.
@immutable
final class StorageDomainContribution {
  const StorageDomainContribution({
    required this.identifier,
    required this.sortOrder,
    required this.iconEmoji,
    required this.labelBuilder,
    required this.descriptionBuilder,
    required this.storedOnLabelBuilder,
    required this.countsDiscardsAsWaste,
  });

  final StorageDomainIdentifier identifier;

  /// Order of the domain tabs: Freezer 10, Fridge 20, Pantry 30, Household 40.
  final int sortOrder;

  /// The colour icon of the domain's tab and switch, such as "❄️".
  final String iconEmoji;

  /// One short word: "Freezer".
  final LocalizedTextBuilder labelBuilder;

  /// One line next to the domain's switch in Options: "Frozen food, drawers
  /// and baskets".
  final LocalizedTextBuilder descriptionBuilder;

  /// What the date a batch was put away is called here: "Frozen on" or
  /// "Bought on".
  final LocalizedTextBuilder storedOnLabelBuilder;

  /// Whether throwing something away from this domain is food waste;
  /// used-up dish soap never is (architecture 10.7, "Waste is a domain property").
  final bool countsDiscardsAsWaste;
}

/// A starting point offered when adding a storage place of one kind, such as
/// "Upright freezer with 5 drawers".
@immutable
final class StorageTemplateContribution {
  const StorageTemplateContribution({
    required this.identifier,
    required this.compartmentCount,
    required this.labelBuilder,
  });

  /// Stable, unique across all modules: "freezer.upright_five".
  final String identifier;

  /// At least one, because a storage place always keeps a compartment.
  final int compartmentCount;

  final LocalizedTextBuilder labelBuilder;
}

/// A kind of storage place, such as an upright freezer or a kitchen
/// cupboard, with the default names of the place and its compartments.
@immutable
final class StorageKindContribution {
  const StorageKindContribution({
    required this.storageName,
    required this.domainIdentifier,
    required this.sortOrder,
    required this.iconEmoji,
    required this.placeNameBuilder,
    required this.kindDescriptionBuilder,
    required this.compartmentNameBuilder,
    required this.compartmentCountBuilder,
    required this.addCompartmentLabelBuilder,
    required this.templates,
  });

  /// Stored with every storage place; never rename one that has shipped.
  final String storageName;

  final StorageDomainIdentifier domainIdentifier;

  /// Order among the kinds of all domains, used for template lists.
  final int sortOrder;

  final String iconEmoji;

  /// The default name of a place of this kind: "Chest freezer".
  final LocalizedTextBuilder placeNameBuilder;

  /// A short description for summaries: "chest freezer", "upright".
  final LocalizedTextBuilder kindDescriptionBuilder;

  /// The default name of a compartment: "Basket 2".
  final LocalizedNumberTextBuilder compartmentNameBuilder;

  /// "3 baskets".
  final LocalizedNumberTextBuilder compartmentCountBuilder;

  /// "Add basket".
  final LocalizedTextBuilder addCompartmentLabelBuilder;

  /// The templates for this kind, in the order they are offered.
  final List<StorageTemplateContribution> templates;
}

/// A category that ships with a module, seeded offline on start.
@immutable
final class SeededCategoryContribution {
  const SeededCategoryContribution({
    required this.catalogKey,
    required this.domainIdentifier,
    required this.shelfLifeDays,
    required this.iconEmoji,
    this.shelfLifeAfterOpeningDays,
  });

  /// Unique across all modules; never rename one that has shipped.
  final String catalogKey;

  /// The domain products of this category usually live in.
  final StorageDomainIdentifier domainIdentifier;

  /// How long products of this category keep, in days; at least one.
  final int shelfLifeDays;

  /// How long an opened package keeps, when that is shorter.
  final int? shelfLifeAfterOpeningDays;

  final String iconEmoji;
}

/// A product that ships with a module, seeded offline on start.
@immutable
final class SeededProductContribution {
  const SeededProductContribution({
    required this.catalogKey,
    required this.categoryCatalogKey,
    required this.canonicalUnit,
    required this.defaultPackageDisplayAmount,
    required this.iconEmoji,
    this.shelfLifeDays,
    this.shelfLifeAfterOpeningDays,
  });

  /// Unique across all modules; never rename one that has shipped.
  final String catalogKey;

  /// A category of the same or another contribution.
  final String categoryCatalogKey;

  final QuantityUnit canonicalUnit;

  /// In display units: grams, millilitres, pieces or portions.
  final num defaultPackageDisplayAmount;

  final String iconEmoji;

  /// Overrides the category's shelf life when set.
  final int? shelfLifeDays;

  /// Overrides the category's shelf life after opening when set.
  final int? shelfLifeAfterOpeningDays;
}

/// Seeded categories and products with their translations.
@immutable
final class CatalogContribution {
  const CatalogContribution({
    required this.categories,
    required this.products,
    required this.categoryNameBuilder,
    required this.productNameBuilder,
  });

  final List<SeededCategoryContribution> categories;
  final List<SeededProductContribution> products;
  final CatalogNameBuilder categoryNameBuilder;
  final CatalogNameBuilder productNameBuilder;
}
