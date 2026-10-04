import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

typedef CategoryIdentifier = TypedIdentifier<Category>;

/// A product category such as vegetables or dairy. Its shelf life applies to
/// products that do not set their own.
@immutable
final class Category {
  const Category({
    required this.identifier,
    required this.recommendedMaximumStorageDays,
    required this.iconEmoji,
    required this.sortOrder,
    required this.storageDomain,
    this.catalogKey,
    this.customName,
    this.shelfLifeAfterOpeningDays,
  });

  final CategoryIdentifier identifier;

  /// Set for seeded categories, whose names are translated until renamed.
  final String? catalogKey;

  final String? customName;

  /// The shelf life in days.
  final int recommendedMaximumStorageDays;

  /// How long an opened package keeps, when that is shorter.
  final int? shelfLifeAfterOpeningDays;

  final String iconEmoji;
  final int sortOrder;

  /// Where products of this category usually live; decides, for example,
  /// whether throwing them away counts as waste.
  final StorageDomainIdentifier storageDomain;

  Category withRecommendedMaximumStorageDays(int recommendedMaximumStorageDays) => Category(
    identifier: identifier,
    catalogKey: catalogKey,
    customName: customName,
    recommendedMaximumStorageDays: recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays,
    iconEmoji: iconEmoji,
    sortOrder: sortOrder,
    storageDomain: storageDomain,
  );

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.identifier == identifier &&
      other.catalogKey == catalogKey &&
      other.customName == customName &&
      other.recommendedMaximumStorageDays == recommendedMaximumStorageDays &&
      other.shelfLifeAfterOpeningDays == shelfLifeAfterOpeningDays &&
      other.iconEmoji == iconEmoji &&
      other.sortOrder == sortOrder &&
      other.storageDomain == storageDomain;

  @override
  int get hashCode => Object.hash(
    identifier,
    catalogKey,
    customName,
    recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays,
    iconEmoji,
    sortOrder,
    storageDomain,
  );
}
