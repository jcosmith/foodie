import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

/// Categories that share one colour on every chart: a single category with
/// a palette slot of its own, or every other category together ("Other").
@immutable
final class StatisticsCategoryGroup {
  const StatisticsCategoryGroup({required this.paletteIndex, required this.categoryIdentifiers});

  /// `null` for the "Other" group.
  final int? paletteIndex;
  final Set<CategoryIdentifier> categoryIdentifiers;

  bool get isOther => paletteIndex == null;

  bool contains(CategoryIdentifier categoryIdentifier) =>
      categoryIdentifiers.contains(categoryIdentifier);
}

/// Gives each category a stable colour slot, so vegetables stay blue whether
/// two or six categories are shown (architecture document, section 10.6).
///
/// At most [distinctColorCount] categories get their own slot; the rest fold
/// into "Other". Seeded categories keep the slot the UI examples document
/// gives them; categories the user created take the free slots in display
/// order. The seeded "Other" category always folds into "Other".
final class StatisticsCategoryGrouping {
  factory StatisticsCategoryGrouping.fromCategories(
    List<Category> categoriesInDisplayOrder, {
    int distinctColorCount = 6,
  }) {
    final paletteIndexByCategory = <CategoryIdentifier, int>{};
    final takenSlots = <int>{};
    for (final category in categoriesInDisplayOrder) {
      final seededSlot = _seededPaletteIndexByCatalogKey[category.catalogKey];
      if (seededSlot != null && seededSlot < distinctColorCount && takenSlots.add(seededSlot)) {
        paletteIndexByCategory[category.identifier] = seededSlot;
      }
    }
    for (final category in categoriesInDisplayOrder) {
      if (paletteIndexByCategory.containsKey(category.identifier) ||
          category.catalogKey == _otherCatalogKey) {
        continue;
      }
      final freeSlot = Iterable<int>.generate(
        distinctColorCount,
      ).where((slot) => !takenSlots.contains(slot)).firstOrNull;
      if (freeSlot == null) break;
      takenSlots.add(freeSlot);
      paletteIndexByCategory[category.identifier] = freeSlot;
    }
    final groups = [
      for (final category in categoriesInDisplayOrder)
        if (paletteIndexByCategory[category.identifier] case final paletteIndex?)
          StatisticsCategoryGroup(
            paletteIndex: paletteIndex,
            categoryIdentifiers: {category.identifier},
          ),
    ];
    final otherCategoryIdentifiers = {
      for (final category in categoriesInDisplayOrder)
        if (!paletteIndexByCategory.containsKey(category.identifier)) category.identifier,
    };
    return StatisticsCategoryGrouping._(
      groups: [
        ...groups,
        if (otherCategoryIdentifiers.isNotEmpty)
          StatisticsCategoryGroup(
            paletteIndex: null,
            categoryIdentifiers: Set.unmodifiable(otherCategoryIdentifiers),
          ),
      ],
      paletteIndexByCategory: paletteIndexByCategory,
    );
  }

  StatisticsCategoryGrouping._({required this.groups, required this.paletteIndexByCategory});

  static const String _otherCatalogKey = 'other';

  static const Map<String, int> _seededPaletteIndexByCatalogKey = {
    'vegetables': 0,
    'meatAndFish': 1,
    'meals': 2,
    'fruit': 3,
    'bakery': 4,
    'desserts': 5,
  };

  /// In display order, "Other" last.
  final List<StatisticsCategoryGroup> groups;
  final Map<CategoryIdentifier, int> paletteIndexByCategory;

  /// `null` means the category is drawn as "Other".
  int? paletteIndexOf(CategoryIdentifier categoryIdentifier) =>
      paletteIndexByCategory[categoryIdentifier];

  /// The group of a category; categories created after this grouping fall
  /// into the "Other" group, or a new one when there is none.
  StatisticsCategoryGroup groupOf(CategoryIdentifier categoryIdentifier) {
    for (final group in groups) {
      if (group.contains(categoryIdentifier)) return group;
    }
    return groups.lastOrNull?.isOther ?? false
        ? groups.last
        : StatisticsCategoryGroup(paletteIndex: null, categoryIdentifiers: {categoryIdentifier});
  }
}
