import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

typedef CategoryIdentifier = TypedIdentifier<Category>;

/// A product category such as vegetables or meals. Its recommended maximum
/// storage time applies to products that do not set their own.
@immutable
final class Category {
  const Category({
    required this.identifier,
    required this.recommendedMaximumStorageDays,
    required this.iconEmoji,
    required this.sortOrder,
    this.catalogKey,
    this.customName,
  });

  final CategoryIdentifier identifier;

  /// Set for seeded categories, whose names are translated until renamed.
  final String? catalogKey;

  final String? customName;
  final int recommendedMaximumStorageDays;
  final String iconEmoji;
  final int sortOrder;

  Category withRecommendedMaximumStorageDays(int recommendedMaximumStorageDays) => Category(
    identifier: identifier,
    catalogKey: catalogKey,
    customName: customName,
    recommendedMaximumStorageDays: recommendedMaximumStorageDays,
    iconEmoji: iconEmoji,
    sortOrder: sortOrder,
  );

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.identifier == identifier &&
      other.catalogKey == catalogKey &&
      other.customName == customName &&
      other.recommendedMaximumStorageDays == recommendedMaximumStorageDays &&
      other.iconEmoji == iconEmoji &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(
    identifier,
    catalogKey,
    customName,
    recommendedMaximumStorageDays,
    iconEmoji,
    sortOrder,
  );
}
