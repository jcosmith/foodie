import 'package:core_foundation/core_foundation.dart';

import 'statistics_date_range.dart';
import 'statistics_filter.dart';

/// The granularity actually used, never [StatisticsGranularity.automatic].
enum StatisticsBucketSize { day, week, month }

/// Splits a period into the buckets of the time axis.
abstract final class StatisticsBucketing {
  /// Automatic keeps the axis readable: days up to a month, weeks up to
  /// about half a year, months beyond (as in the UI examples document).
  static StatisticsBucketSize bucketSizeFor(
    StatisticsGranularity granularity,
    StatisticsDateRange period,
  ) => switch (granularity) {
    StatisticsGranularity.day => StatisticsBucketSize.day,
    StatisticsGranularity.week => StatisticsBucketSize.week,
    StatisticsGranularity.month => StatisticsBucketSize.month,
    StatisticsGranularity.automatic =>
      period.lengthInDays <= 31
          ? StatisticsBucketSize.day
          : period.lengthInDays <= 200
          ? StatisticsBucketSize.week
          : StatisticsBucketSize.month,
  };

  /// Consecutive buckets covering [period]: single days; weeks of seven
  /// days counted from the period's first day; or calendar months, the first
  /// and last cut to the period.
  static List<StatisticsDateRange> buildBuckets(
    StatisticsDateRange period,
    StatisticsBucketSize bucketSize,
  ) {
    final buckets = <StatisticsDateRange>[];
    var bucketStart = period.firstDay;
    while (!bucketStart.isAfter(period.lastDay)) {
      final naturalEnd = switch (bucketSize) {
        StatisticsBucketSize.day => bucketStart,
        StatisticsBucketSize.week => bucketStart.addDays(6),
        StatisticsBucketSize.month => CalendarDate.fromDateTime(
          DateTime.utc(bucketStart.year, bucketStart.month + 1, 0),
        ),
      };
      final bucketEnd = naturalEnd.isAfter(period.lastDay) ? period.lastDay : naturalEnd;
      buckets.add(StatisticsDateRange(bucketStart, bucketEnd));
      bucketStart = bucketEnd.addDays(1);
    }
    return buckets;
  }
}

/// Finds the bucket of a day in constant time.
final class StatisticsBucketIndex {
  StatisticsBucketIndex(this.buckets)
    : _firstDayNumber = buckets.isEmpty ? 0 : buckets.first.firstDay.daysSinceEpoch,
      _bucketIndexByDayOffset = [
        for (final (index, bucket) in buckets.indexed)
          for (var day = 0; day < bucket.lengthInDays; day++) index,
      ];

  final List<StatisticsDateRange> buckets;
  final int _firstDayNumber;
  final List<int> _bucketIndexByDayOffset;

  /// `null` when [day] is outside every bucket.
  int? indexOf(CalendarDate day) {
    final offset = day.daysSinceEpoch - _firstDayNumber;
    return offset < 0 || offset >= _bucketIndexByDayOffset.length
        ? null
        : _bucketIndexByDayOffset[offset];
  }
}
