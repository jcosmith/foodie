import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'statistics_date_range.dart';
import 'statistics_filter.dart';

/// The period the filter selects and the one it is compared with.
@immutable
final class StatisticsPeriods {
  const StatisticsPeriods({required this.period, required this.comparisonPeriod});

  /// Resolves the period choices of [filter] on [today]. [firstActivityDay]
  /// is the day of the first movement, `null` while there is none.
  factory StatisticsPeriods.resolve({
    required StatisticsFilter filter,
    required CalendarDate today,
    required CalendarDate? firstActivityDay,
  }) => StatisticsPeriods.resolveChoice(
    periodPreset: filter.periodPreset,
    customPeriod: filter.customPeriod,
    comparison: filter.comparison,
    today: today,
    firstActivityDay: firstActivityDay,
  );

  /// Like [StatisticsPeriods.resolve], from the period choices alone.
  factory StatisticsPeriods.resolveChoice({
    required StatisticsPeriodPreset periodPreset,
    required StatisticsDateRange? customPeriod,
    required StatisticsComparison comparison,
    required CalendarDate today,
    required CalendarDate? firstActivityDay,
  }) {
    final period = switch (periodPreset) {
      StatisticsPeriodPreset.last30Days => _lastDays(today, 30),
      StatisticsPeriodPreset.last3Months => _lastDays(today, 90),
      StatisticsPeriodPreset.last12Months => _lastDays(today, 365),
      StatisticsPeriodPreset.thisYear => StatisticsDateRange(CalendarDate(today.year, 1, 1), today),
      StatisticsPeriodPreset.allTime => StatisticsDateRange(
        firstActivityDay == null || firstActivityDay.isAfter(today) ? today : firstActivityDay,
        today,
      ),
      StatisticsPeriodPreset.custom => customPeriod!,
    };
    final comparisonPeriod = switch (comparison) {
      StatisticsComparison.off => null,
      StatisticsComparison.previousPeriod => period.shiftedByDays(-period.lengthInDays),
      StatisticsComparison.samePeriodLastYear => StatisticsDateRange(
        _sameDayLastYear(period.firstDay),
        _sameDayLastYear(period.lastDay),
      ),
    };
    final hasHistoryForComparison =
        comparisonPeriod != null &&
        firstActivityDay != null &&
        !comparisonPeriod.firstDay.isBefore(firstActivityDay);
    return StatisticsPeriods(
      period: period,
      comparisonPeriod: hasHistoryForComparison ? comparisonPeriod : null,
    );
  }

  final StatisticsDateRange period;

  /// `null` when comparison is off, or when the comparison period starts
  /// before the first recorded movement (a half-empty period would make
  /// every figure look like growth).
  final StatisticsDateRange? comparisonPeriod;

  static StatisticsDateRange _lastDays(CalendarDate today, int numberOfDays) =>
      StatisticsDateRange(today.addDays(1 - numberOfDays), today);

  /// 29 February becomes 28 February.
  static CalendarDate _sameDayLastYear(CalendarDate day) {
    final lastDayOfMonth = DateTime.utc(day.year - 1, day.month + 1, 0).day;
    return CalendarDate(
      day.year - 1,
      day.month,
      day.day > lastDayOfMonth ? lastDayOfMonth : day.day,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StatisticsPeriods &&
      other.period == period &&
      other.comparisonPeriod == comparisonPeriod;

  @override
  int get hashCode => Object.hash(period, comparisonPeriod);
}
