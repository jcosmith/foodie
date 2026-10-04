import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

import 'statistics_buckets.dart';
import 'statistics_category_grouping.dart';
import 'statistics_date_range.dart';
import 'statistics_filter.dart';
import 'statistics_measure_policy.dart';
import 'statistics_movement_fact.dart';
import 'statistics_periods.dart';

/// A figure for the current period and, when there is one, the comparison period.
@immutable
final class StatisticsComparedFigure {
  const StatisticsComparedFigure({required this.current, required this.previous});

  /// `null` when there is nothing to compute it from, such as a waste share
  /// without removals.
  final double? current;
  final double? previous;

  /// The relative change, or `null` when there is nothing to compare with.
  double? get relativeChange {
    final currentValue = current;
    final previousValue = previous;
    if (currentValue == null || previousValue == null || previousValue <= 0) return null;
    return (currentValue - previousValue) / previousValue;
  }
}

/// One coloured layer of the category charts.
@immutable
final class StatisticsCategorySeries {
  const StatisticsCategorySeries({required this.group, required this.bucketValues});

  final StatisticsCategoryGroup group;
  final List<double> bucketValues;

  double get total => bucketValues.fold(0, (sum, value) => sum + value);
}

/// How the storage-time columns are cut: [days] and weeks when everything
/// eaten was kept for a month at most, as with fridge food, else [months].
enum StatisticsDurationScale { days, months }

/// Everything the Insights charts show, computed from the movement facts of
/// the period (and the comparison period) and the shared filter. Pure and
/// synchronous: a filter change other than the period recomputes this in
/// memory without querying the database again.
final class StatisticsAnalysis {
  StatisticsAnalysis({
    required this.filter,
    required this.periods,
    required List<StatisticsMovementFact> periodFacts,
    required List<StatisticsMovementFact> comparisonFacts,
    required this.categoryGrouping,
    this.domainsWithoutWaste = const {},
  }) : bucketSize = StatisticsBucketing.bucketSizeFor(filter.granularity, periods.period),
       _periodFacts = periodFacts,
       _comparisonFacts = comparisonFacts {
    buckets = StatisticsBucketing.buildBuckets(periods.period, bucketSize);
    _bucketIndex = StatisticsBucketIndex(buckets);
    final comparisonPeriod = periods.comparisonPeriod;
    _comparisonBucketIndex = comparisonPeriod == null
        ? null
        : StatisticsBucketIndex(
            StatisticsBucketing.buildBuckets(
              comparisonPeriod,
              bucketSize,
            ).take(buckets.length).toList(),
          );
  }

  /// Fewer removals than this in a period makes trends unreliable.
  static const int thinDataRemovalCount = 5;

  static const int storedDaysHistogramBinCount = 8;

  /// Rows in the top products ranking.
  static const int topProductsLimit = 6;

  /// The calendar shows at most this many weeks, ending with the period.
  static const int calendarWeekLimit = 26;

  /// Upper limits (exclusive) of the storage-duration columns in days on the
  /// [StatisticsDurationScale.months] scale: under a month, 1–3, 3–6, 6–9,
  /// 9–12 months, and longer.
  static const List<int> monthStorageDurationLimitsInDays = [30, 91, 182, 273, 365];

  /// The same on the [StatisticsDurationScale.days] scale: under 2 days, 2–3
  /// days, 4–7 days, 1–2 weeks, 2–4 weeks, and longer.
  static const List<int> dayStorageDurationLimitsInDays = [2, 4, 8, 15, 31];

  final StatisticsFilter filter;
  final StatisticsPeriods periods;
  final StatisticsCategoryGrouping categoryGrouping;

  /// Domains whose discards are not waste, such as household supplies
  /// (architecture 10.7, "Waste is a domain property"). Throwing away from
  /// them counts nowhere as thrown away.
  final Set<StorageDomainIdentifier> domainsWithoutWaste;
  final StatisticsBucketSize bucketSize;
  late final List<StatisticsDateRange> buckets;
  late final StatisticsBucketIndex _bucketIndex;
  late final StatisticsBucketIndex? _comparisonBucketIndex;
  final List<StatisticsMovementFact> _periodFacts;
  final List<StatisticsMovementFact> _comparisonFacts;

  bool get hasComparison => periods.comparisonPeriod != null;

  /// Whether anything at all happened in the period with the current filter.
  bool get hasAnyActivity => _selectedFacts(_periodFacts).isNotEmpty;

  /// Items used or thrown away in the period.
  int get removalCount => _selectedFacts(_periodFacts)
      .where(
        (fact) =>
            fact.activity == StatisticsActivity.consumed ||
            fact.activity == StatisticsActivity.discarded,
      )
      .fold(0, (sum, fact) => sum + fact.movementCount);

  /// Whether to say "trends need more data" above the charts.
  bool get isThinData => removalCount > 0 && removalCount < thinDataRemovalCount;

  /// Products of the chosen activity that the measure leaves out because
  /// they are kept in another unit; always 0 for counts.
  int get productsLeftOutByMeasure => {
    for (final fact in _selectedFacts(_periodFacts, activity: filter.activity))
      if (StatisticsMeasurePolicy.valueOf(fact, filter.measure) == null) fact.productIdentifier,
  }.length;

  StatisticsComparedFigure totalOf(StatisticsActivity activity) => StatisticsComparedFigure(
    current: _sum(_selectedFacts(_periodFacts, activity: activity)),
    previous: hasComparison ? _sum(_selectedFacts(_comparisonFacts, activity: activity)) : null,
  );

  /// Thrown away divided by eaten plus thrown away.
  StatisticsComparedFigure get wasteShare => StatisticsComparedFigure(
    current: _wasteShareOf(_periodFacts),
    previous: hasComparison ? _wasteShareOf(_comparisonFacts) : null,
  );

  /// How long eaten items had been frozen, on average per item.
  StatisticsComparedFigure get averageStoredDaysBeforeEaten => StatisticsComparedFigure(
    current: _averageStoredDaysOf(_periodFacts),
    previous: hasComparison ? _averageStoredDaysOf(_comparisonFacts) : null,
  );

  /// Eaten items per storage-duration bin, the last bin open-ended: bins of
  /// 45 days, or of 4 days on the [StatisticsDurationScale.days] scale.
  List<double> get storedDaysHistogram {
    final binWidth = storageDurationScale == StatisticsDurationScale.days ? 4 : 45;
    final bins = List<double>.filled(storedDaysHistogramBinCount, 0);
    for (final fact in _selectedFacts(_periodFacts, activity: StatisticsActivity.consumed)) {
      final bin = (fact.storedDays ~/ binWidth).clamp(0, storedDaysHistogramBinCount - 1);
      bins[bin] += fact.movementCount;
    }
    return bins;
  }

  /// The scale of the storage-time charts, from what was eaten.
  late final StatisticsDurationScale storageDurationScale =
      _selectedFacts(
        _periodFacts,
        activity: StatisticsActivity.consumed,
      ).any((fact) => fact.storedDays >= dayStorageDurationLimitsInDays.last)
      ? StatisticsDurationScale.months
      : StatisticsDurationScale.days;

  /// The column limits of [storageDurationScale].
  List<int> get storageDurationLimitsInDays => switch (storageDurationScale) {
    StatisticsDurationScale.days => dayStorageDurationLimitsInDays,
    StatisticsDurationScale.months => monthStorageDurationLimitsInDays,
  };

  /// The measure per bucket of the period.
  List<double> bucketValuesOf(StatisticsActivity activity) =>
      _bucketValues(_selectedFacts(_periodFacts, activity: activity), _bucketIndex);

  /// The measure per bucket of the comparison period, aligned with the
  /// period's buckets by position; `null` without comparison.
  List<double>? comparisonBucketValuesOf(StatisticsActivity activity) {
    final comparisonBucketIndex = _comparisonBucketIndex;
    if (comparisonBucketIndex == null) return null;
    return _bucketValues(
      _selectedFacts(_comparisonFacts, activity: activity),
      comparisonBucketIndex,
    );
  }

  /// One series per category group for the chosen activity. With a category
  /// filter only the selected groups appear.
  List<StatisticsCategorySeries> get categorySeries {
    final facts = _selectedFacts(_periodFacts, activity: filter.activity);
    return [
      for (final group in categoryGrouping.groups)
        if (_isGroupSelected(group))
          StatisticsCategorySeries(
            group: group,
            bucketValues: _bucketValues(
              facts.where((fact) => group.contains(fact.categoryIdentifier)),
              _bucketIndex,
            ),
          ),
    ];
  }

  bool isGroupDimmed(StatisticsCategoryGroup group) => !_isGroupSelected(group);

  bool _isGroupSelected(StatisticsCategoryGroup group) =>
      filter.categoryIdentifiers.isEmpty ||
      group.categoryIdentifiers.any(filter.categoryIdentifiers.contains);

  /// The days the calendar shows: the period's last [calendarWeekLimit] weeks.
  StatisticsDateRange get calendarPeriod {
    final period = periods.period;
    final earliestDay = period.lastDay.addDays(1 - calendarWeekLimit * 7);
    return StatisticsDateRange(
      period.firstDay.isBefore(earliestDay) ? earliestDay : period.firstDay,
      period.lastDay,
    );
  }

  /// Items of the chosen activity per day of [calendarPeriod]; days without
  /// any are left out.
  Map<CalendarDate, int> get dailyItemCounts {
    final calendar = calendarPeriod;
    final counts = <CalendarDate, int>{};
    for (final fact in _selectedFacts(_periodFacts, activity: filter.activity)) {
      if (!calendar.contains(fact.day)) continue;
      counts[fact.day] = (counts[fact.day] ?? 0) + fact.movementCount;
    }
    counts.removeWhere((day, count) => count <= 0);
    return counts;
  }

  /// The measure of the chosen activity per weekday, Monday first. Ignores
  /// the weekday filter, so the chart can show which weekdays are selected.
  List<double> get weekdayTotals {
    final totals = List<double>.filled(7, 0);
    for (final fact in _selectedFacts(
      _periodFacts,
      activity: filter.activity,
      ignoreWeekdays: true,
    )) {
      totals[fact.day.weekday - 1] += StatisticsMeasurePolicy.valueOf(fact, filter.measure) ?? 0;
    }
    return totals;
  }

  /// Eaten items per column of [storageDurationLimitsInDays], the last
  /// column open-ended.
  List<int> get eatenItemsByStorageDuration {
    final limits = storageDurationLimitsInDays;
    final counts = List<int>.filled(limits.length + 1, 0);
    for (final fact in _selectedFacts(_periodFacts, activity: StatisticsActivity.consumed)) {
      final column = limits.indexWhere((limit) => fact.storedDays < limit);
      counts[column < 0 ? limits.length : column] += fact.movementCount;
    }
    return counts;
  }

  /// Products with the largest totals for [activity], largest first.
  List<(ProductIdentifier, double)> topProducts(StatisticsActivity activity) {
    final totals = <ProductIdentifier, double>{};
    for (final fact in _selectedFacts(_periodFacts, activity: activity, ignoreProducts: true)) {
      final value = StatisticsMeasurePolicy.valueOf(fact, filter.measure);
      if (value == null) continue;
      totals[fact.productIdentifier] = (totals[fact.productIdentifier] ?? 0) + value;
    }
    final ranking = totals.entries.where((entry) => entry.value > 0).toList()
      ..sort((first, second) => second.value.compareTo(first.value));
    return [for (final entry in ranking.take(topProductsLimit)) (entry.key, entry.value)];
  }

  /// Movements of any activity per product in the period, with the category,
  /// drawer and weekday filters applied but not the product or activity
  /// choice, so selecting a product does not hide the others. Products
  /// without movements are left out; the filter sheet lists these first.
  Map<ProductIdentifier, int> get movementCountsByProduct {
    final counts = <ProductIdentifier, int>{};
    for (final fact in _selectedFacts(_periodFacts, ignoreProducts: true)) {
      counts[fact.productIdentifier] = (counts[fact.productIdentifier] ?? 0) + fact.movementCount;
    }
    counts.removeWhere((productIdentifier, count) => count <= 0);
    return counts;
  }

  /// Items thrown away per reason, in a fixed order; reasons without items
  /// are kept so the chart's rows do not jump.
  List<(StatisticsDiscardReason, int)> get discardedItemsByReason {
    final counts = {for (final reason in StatisticsDiscardReason.values) reason: 0};
    for (final fact in _selectedFacts(_periodFacts, activity: StatisticsActivity.discarded)) {
      counts[fact.discardReason] = counts[fact.discardReason]! + fact.movementCount;
    }
    return [
      for (final MapEntry(key: reason, value: count) in counts.entries)
        if (reason != StatisticsDiscardReason.notGiven || count > 0) (reason, count),
    ];
  }

  Iterable<StatisticsMovementFact> _selectedFacts(
    List<StatisticsMovementFact> facts, {
    StatisticsActivity? activity,
    bool ignoreProducts = false,
    bool ignoreWeekdays = false,
  }) => facts.where(
    (fact) =>
        (activity == null || fact.activity == activity) &&
        !(fact.activity == StatisticsActivity.discarded &&
            domainsWithoutWaste.contains(fact.domainIdentifier)) &&
        (filter.domainIdentifiers.isEmpty ||
            filter.domainIdentifiers.contains(fact.domainIdentifier)) &&
        (filter.categoryIdentifiers.isEmpty ||
            filter.categoryIdentifiers.contains(fact.categoryIdentifier)) &&
        (ignoreProducts ||
            filter.productIdentifiers.isEmpty ||
            filter.productIdentifiers.contains(fact.productIdentifier)) &&
        (filter.compartmentIdentifiers.isEmpty ||
            filter.compartmentIdentifiers.contains(fact.compartmentIdentifier)) &&
        (ignoreWeekdays || filter.includesWeekdayOf(fact.day)),
  );

  double _sum(Iterable<StatisticsMovementFact> facts) => facts.fold(
    0,
    (sum, fact) => sum + (StatisticsMeasurePolicy.valueOf(fact, filter.measure) ?? 0),
  );

  List<double> _bucketValues(
    Iterable<StatisticsMovementFact> facts,
    StatisticsBucketIndex bucketIndex,
  ) {
    final values = List<double>.filled(bucketIndex.buckets.length, 0);
    for (final fact in facts) {
      final index = bucketIndex.indexOf(fact.day);
      final value = StatisticsMeasurePolicy.valueOf(fact, filter.measure);
      if (index != null && value != null) values[index] += value;
    }
    return values;
  }

  double? _wasteShareOf(List<StatisticsMovementFact> facts) {
    final wasted = _sum(_selectedFacts(facts, activity: StatisticsActivity.discarded));
    final eaten = _sum(_selectedFacts(facts, activity: StatisticsActivity.consumed));
    return wasted + eaten == 0 ? null : wasted / (wasted + eaten);
  }

  double? _averageStoredDaysOf(List<StatisticsMovementFact> facts) {
    var itemCount = 0;
    var storedDaysTotal = 0;
    for (final fact in _selectedFacts(facts, activity: StatisticsActivity.consumed)) {
      itemCount += fact.movementCount;
      storedDaysTotal += fact.storedDays * fact.movementCount;
    }
    return itemCount <= 0 ? null : storedDaysTotal / itemCount;
  }
}
