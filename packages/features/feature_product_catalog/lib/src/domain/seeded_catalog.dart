import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

/// A category that ships with a domain module.
@immutable
final class SeededCategory {
  const SeededCategory({
    required this.catalogKey,
    required this.storageDomain,
    required this.recommendedMaximumStorageDays,
    required this.iconEmoji,
    this.shelfLifeAfterOpeningDays,
  });

  final String catalogKey;
  final StorageDomainIdentifier storageDomain;
  final int recommendedMaximumStorageDays;
  final int? shelfLifeAfterOpeningDays;
  final String iconEmoji;
}

/// A product that ships with a domain module; its name is translated through
/// its catalog key until the user renames it.
@immutable
final class SeededProduct {
  const SeededProduct({
    required this.catalogKey,
    required this.categoryCatalogKey,
    required this.canonicalUnit,
    required this.defaultPackageDisplayAmount,
    required this.iconEmoji,
    this.recommendedMaximumStorageDays,
    this.shelfLifeAfterOpeningDays,
  });

  final String catalogKey;

  /// A category of the same or another module.
  final String categoryCatalogKey;
  final QuantityUnit canonicalUnit;

  /// In display units: grams, millilitres, pieces or portions.
  final num defaultPackageDisplayAmount;

  final String iconEmoji;

  /// Overrides the category's storage time when set.
  final int? recommendedMaximumStorageDays;

  /// Overrides the category's shelf life after opening when set.
  final int? shelfLifeAfterOpeningDays;

  Quantity get defaultPackageQuantity =>
      Quantity.fromDisplayAmount(defaultPackageDisplayAmount, canonicalUnit);
}

/// The offline catalog of every registered module, seeded at every start (no
/// online product database is ever queried).
@immutable
final class SeededCatalog {
  const SeededCatalog({required this.categories, required this.products});

  static const SeededCatalog empty = SeededCatalog(categories: [], products: []);

  /// In the order they are listed, module after module.
  final List<SeededCategory> categories;
  final List<SeededProduct> products;
}
