import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:meta/meta.dart';

import 'statistics_date_range.dart';

/// The period presets of the filter row and sheet.
enum StatisticsPeriodPreset { last30Days, last3Months, last12Months, thisYear, allTime, custom }

/// What the key figures and the dashed trend line compare against.
enum StatisticsComparison { off, previousPeriod, samePeriodLastYear }

/// How the time axis is grouped; [automatic] picks by period length.
enum StatisticsGranularity { automatic, day, week, month }

/// What the charts add up. Units are never mixed: weight only counts
/// products kept in grams, volume those in millilitres, pieces those in
/// pieces or portions; count counts every item.
enum StatisticsMeasure { weight, volume, pieces, count }

/// The movement kinds statistics can show, named as in the movement log.
enum StatisticsActivity {
  consumed,
  added,
  discarded,
  moved;

  /// The movement kind stored in the database.
  String get storageName => name;

  static StatisticsActivity? fromStorageName(String storageName) {
    for (final activity in values) {
      if (activity.storageName == storageName) return activity;
    }
    return null;
  }
}

/// The one filter every chart on the Insights tab reads (decision D15).
/// Charts change it when tapped (cross-filtering); "Reset" returns to
/// [StatisticsFilter.initial].
///
/// Empty identifier sets mean "all".
@immutable
final class StatisticsFilter {
  const StatisticsFilter({
    this.periodPreset = StatisticsPeriodPreset.last3Months,
    this.customPeriod,
    this.comparison = StatisticsComparison.previousPeriod,
    this.granularity = StatisticsGranularity.automatic,
    this.measure = StatisticsMeasure.weight,
    this.activity = StatisticsActivity.consumed,
    this.categoryIdentifiers = const {},
    this.productIdentifiers = const {},
    this.compartmentIdentifiers = const {},
    this.weekdays = const {},
  }) : assert(
         periodPreset != StatisticsPeriodPreset.custom || customPeriod != null,
         'A custom period needs its dates',
       );

  /// Three months, compared with the three before, by weight, used
  /// (UI examples document, phone 7).
  static const StatisticsFilter initial = StatisticsFilter();

  final StatisticsPeriodPreset periodPreset;

  /// Set when [periodPreset] is [StatisticsPeriodPreset.custom].
  final StatisticsDateRange? customPeriod;
  final StatisticsComparison comparison;
  final StatisticsGranularity granularity;
  final StatisticsMeasure measure;

  /// What the category, share and calendar charts show.
  final StatisticsActivity activity;
  final Set<CategoryIdentifier> categoryIdentifiers;
  final Set<ProductIdentifier> productIdentifiers;
  final Set<CompartmentIdentifier> compartmentIdentifiers;

  /// [DateTime.monday] (1) to [DateTime.sunday] (7).
  final Set<int> weekdays;

  /// How many choices differ from [initial], for the "Filters · 3" button.
  /// The period is not counted: it is always visible in the filter row.
  int get activeFilterCount =>
      categoryIdentifiers.length +
      productIdentifiers.length +
      compartmentIdentifiers.length +
      weekdays.length +
      (measure != initial.measure ? 1 : 0) +
      (activity != initial.activity ? 1 : 0) +
      (comparison != initial.comparison ? 1 : 0) +
      (granularity != initial.granularity ? 1 : 0);

  StatisticsFilter withPeriodPreset(StatisticsPeriodPreset preset) {
    assert(preset != StatisticsPeriodPreset.custom, 'Use withCustomPeriod');
    return _copyWith(periodPreset: preset, customPeriod: () => null);
  }

  StatisticsFilter withCustomPeriod(StatisticsDateRange period) =>
      _copyWith(periodPreset: StatisticsPeriodPreset.custom, customPeriod: () => period);

  StatisticsFilter withComparison(StatisticsComparison comparison) =>
      _copyWith(comparison: comparison);

  StatisticsFilter withGranularity(StatisticsGranularity granularity) =>
      _copyWith(granularity: granularity);

  StatisticsFilter withMeasure(StatisticsMeasure measure) => _copyWith(measure: measure);

  StatisticsFilter withActivity(StatisticsActivity activity) => _copyWith(activity: activity);

  StatisticsFilter withCategoryToggled(CategoryIdentifier categoryIdentifier) =>
      _copyWith(categoryIdentifiers: _toggled(categoryIdentifiers, categoryIdentifier));

  /// Selects all of [categoryIdentifiers], or removes them when all are
  /// already selected; used for the folded "Other" categories.
  StatisticsFilter withCategoryGroupToggled(Set<CategoryIdentifier> categoryIdentifiers) =>
      _copyWith(
        categoryIdentifiers: this.categoryIdentifiers.containsAll(categoryIdentifiers)
            ? this.categoryIdentifiers.difference(categoryIdentifiers)
            : this.categoryIdentifiers.union(categoryIdentifiers),
      );

  StatisticsFilter withProductToggled(ProductIdentifier productIdentifier) =>
      _copyWith(productIdentifiers: _toggled(productIdentifiers, productIdentifier));

  StatisticsFilter withCompartmentToggled(CompartmentIdentifier compartmentIdentifier) =>
      _copyWith(compartmentIdentifiers: _toggled(compartmentIdentifiers, compartmentIdentifier));

  StatisticsFilter withWeekdayToggled(int weekday) {
    assert(weekday >= DateTime.monday && weekday <= DateTime.sunday, 'Not a weekday: $weekday');
    return _copyWith(weekdays: _toggled(weekdays, weekday));
  }

  static Set<TValue> _toggled<TValue>(Set<TValue> values, TValue value) =>
      values.contains(value) ? ({...values}..remove(value)) : {...values, value};

  StatisticsFilter _copyWith({
    StatisticsPeriodPreset? periodPreset,
    StatisticsDateRange? Function()? customPeriod,
    StatisticsComparison? comparison,
    StatisticsGranularity? granularity,
    StatisticsMeasure? measure,
    StatisticsActivity? activity,
    Set<CategoryIdentifier>? categoryIdentifiers,
    Set<ProductIdentifier>? productIdentifiers,
    Set<CompartmentIdentifier>? compartmentIdentifiers,
    Set<int>? weekdays,
  }) => StatisticsFilter(
    periodPreset: periodPreset ?? this.periodPreset,
    customPeriod: customPeriod == null ? this.customPeriod : customPeriod(),
    comparison: comparison ?? this.comparison,
    granularity: granularity ?? this.granularity,
    measure: measure ?? this.measure,
    activity: activity ?? this.activity,
    categoryIdentifiers: Set.unmodifiable(categoryIdentifiers ?? this.categoryIdentifiers),
    productIdentifiers: Set.unmodifiable(productIdentifiers ?? this.productIdentifiers),
    compartmentIdentifiers: Set.unmodifiable(compartmentIdentifiers ?? this.compartmentIdentifiers),
    weekdays: Set.unmodifiable(weekdays ?? this.weekdays),
  );

  @override
  bool operator ==(Object other) =>
      other is StatisticsFilter &&
      other.periodPreset == periodPreset &&
      other.customPeriod == customPeriod &&
      other.comparison == comparison &&
      other.granularity == granularity &&
      other.measure == measure &&
      other.activity == activity &&
      _haveSameElements(other.categoryIdentifiers, categoryIdentifiers) &&
      _haveSameElements(other.productIdentifiers, productIdentifiers) &&
      _haveSameElements(other.compartmentIdentifiers, compartmentIdentifiers) &&
      _haveSameElements(other.weekdays, weekdays);

  @override
  int get hashCode => Object.hash(
    periodPreset,
    customPeriod,
    comparison,
    granularity,
    measure,
    activity,
    Object.hashAllUnordered(categoryIdentifiers),
    Object.hashAllUnordered(productIdentifiers),
    Object.hashAllUnordered(compartmentIdentifiers),
    Object.hashAllUnordered(weekdays),
  );

  static bool _haveSameElements<TValue>(Set<TValue> first, Set<TValue> second) =>
      first.length == second.length && first.containsAll(second);
}

/// Whether a day falls on one of the filter's weekdays; all days when none is chosen.
extension StatisticsFilterWeekdays on StatisticsFilter {
  bool includesWeekdayOf(CalendarDate day) => weekdays.isEmpty || weekdays.contains(day.weekday);
}
