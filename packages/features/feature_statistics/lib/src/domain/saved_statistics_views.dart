import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:meta/meta.dart';

import 'statistics_date_range.dart';
import 'statistics_filter.dart';

/// A filter combination the user saved under a name, restored with one tap.
@immutable
final class SavedStatisticsView {
  const SavedStatisticsView({required this.name, required this.filter});

  final String name;
  final StatisticsFilter filter;

  @override
  bool operator ==(Object other) =>
      other is SavedStatisticsView && other.name == name && other.filter == filter;

  @override
  int get hashCode => Object.hash(name, filter);
}

/// Ready-made views (UI examples document, phone 8), built from the seeded
/// categories that exist.
enum SuggestedStatisticsView {
  /// Meals eaten on Saturdays and Sundays over a year, counted.
  weekendMeals,

  /// What was thrown away this year compared with last year, counted.
  wasteCheck,

  /// Fruit and desserts by month over all time.
  fruitSeason;

  StatisticsFilter filterFor(List<Category> categories) {
    Set<CategoryIdentifier> categoriesWithKeys(Set<String> catalogKeys) => {
      for (final category in categories)
        if (catalogKeys.contains(category.catalogKey)) category.identifier,
    };
    const initial = StatisticsFilter.initial;
    return switch (this) {
      weekendMeals => categoriesWithKeys({'meals'}).fold(
        initial
            .withPeriodPreset(StatisticsPeriodPreset.last12Months)
            .withMeasure(StatisticsMeasure.count)
            .withWeekdayToggled(DateTime.saturday)
            .withWeekdayToggled(DateTime.sunday),
        (filter, category) => filter.withCategoryToggled(category),
      ),
      wasteCheck =>
        initial
            .withPeriodPreset(StatisticsPeriodPreset.last12Months)
            .withActivity(StatisticsActivity.discarded)
            .withMeasure(StatisticsMeasure.count)
            .withComparison(StatisticsComparison.samePeriodLastYear),
      fruitSeason => categoriesWithKeys({'fruit', 'desserts'}).fold(
        initial
            .withPeriodPreset(StatisticsPeriodPreset.allTime)
            .withGranularity(StatisticsGranularity.month)
            .withComparison(StatisticsComparison.off),
        (filter, category) => filter.withCategoryToggled(category),
      ),
    };
  }
}

/// Turns saved views into JSON-ready maps and back, for the preferences
/// store. Unknown values fall back to the defaults, so a view saved by a
/// newer version never breaks an older one.
abstract final class SavedStatisticsViewCodec {
  static List<Map<String, Object?>> encodeViews(List<SavedStatisticsView> views) => [
    for (final view in views) {'name': view.name, 'filter': encodeFilter(view.filter)},
  ];

  static List<SavedStatisticsView> decodeViews(Object? encoded) {
    if (encoded is! List) throw const FormatException('Saved views must be a list');
    return [
      for (final entry in encoded)
        if (entry case {'name': final String name, 'filter': final Map<String, Object?> filter})
          SavedStatisticsView(name: name, filter: decodeFilter(filter)),
    ];
  }

  static Map<String, Object?> encodeFilter(StatisticsFilter filter) => {
    'period': filter.periodPreset.name,
    if (filter.customPeriod case final customPeriod?) ...{
      'from': customPeriod.firstDay.toIso8601String(),
      'to': customPeriod.lastDay.toIso8601String(),
    },
    'comparison': filter.comparison.name,
    'granularity': filter.granularity.name,
    'measure': filter.measure.name,
    'activity': filter.activity.name,
    'categories': [for (final identifier in filter.categoryIdentifiers) identifier.value],
    'products': [for (final identifier in filter.productIdentifiers) identifier.value],
    'compartments': [for (final identifier in filter.compartmentIdentifiers) identifier.value],
    'weekdays': [...filter.weekdays],
  };

  static StatisticsFilter decodeFilter(Map<String, Object?> encoded) {
    TEnum enumValue<TEnum extends Enum>(List<TEnum> values, String key, TEnum fallback) =>
        values.where((value) => value.name == encoded[key]).firstOrNull ?? fallback;
    Iterable<String> texts(String key) => switch (encoded[key]) {
      final List<Object?> list => list.whereType<String>(),
      _ => const [],
    };
    const initial = StatisticsFilter.initial;
    var filter = initial
        .withComparison(enumValue(StatisticsComparison.values, 'comparison', initial.comparison))
        .withGranularity(
          enumValue(StatisticsGranularity.values, 'granularity', initial.granularity),
        )
        .withMeasure(enumValue(StatisticsMeasure.values, 'measure', initial.measure))
        .withActivity(enumValue(StatisticsActivity.values, 'activity', initial.activity));
    final periodPreset = enumValue(StatisticsPeriodPreset.values, 'period', initial.periodPreset);
    final (from, to) = (encoded['from'], encoded['to']);
    if (periodPreset == StatisticsPeriodPreset.custom && from is String && to is String) {
      filter = filter.withCustomPeriod(
        StatisticsDateRange(CalendarDate.parseIso8601(from), CalendarDate.parseIso8601(to)),
      );
    } else if (periodPreset != StatisticsPeriodPreset.custom) {
      filter = filter.withPeriodPreset(periodPreset);
    }
    for (final identifier in texts('categories')) {
      filter = filter.withCategoryToggled(CategoryIdentifier(identifier));
    }
    for (final identifier in texts('products')) {
      filter = filter.withProductToggled(ProductIdentifier(identifier));
    }
    for (final identifier in texts('compartments')) {
      filter = filter.withCompartmentToggled(CompartmentIdentifier(identifier));
    }
    if (encoded['weekdays'] case final List<Object?> weekdays) {
      for (final weekday in weekdays.whereType<int>()) {
        if (weekday >= DateTime.monday && weekday <= DateTime.sunday) {
          filter = filter.withWeekdayToggled(weekday);
        }
      }
    }
    return filter;
  }
}
