import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../domain/saved_statistics_views.dart';
import '../domain/statistics_analysis.dart';
import '../domain/statistics_buckets.dart';
import '../domain/statistics_date_range.dart';
import '../domain/statistics_filter.dart';
import '../domain/statistics_movement_fact.dart';
import '../l10n/generated/statistics_localizations.dart';

/// Numbers, dates and names of the Insights tab in the app language.
final class StatisticsFormatting {
  StatisticsFormatting.of(BuildContext context)
    : localizations = StatisticsLocalizations.of(context),
      _commonLocalizations = context.commonLocalizations;

  final StatisticsLocalizations localizations;
  final CommonLocalizations _commonLocalizations;

  String get _localeName => localizations.localeName;

  /// "12 kg", "1.5 l", "8 pcs" or "14×"; one decimal below ten.
  String measureValue(double value, StatisticsMeasure measure) {
    final number = NumberFormat.decimalPatternDigits(
      locale: _localeName,
      decimalDigits: value >= 10 || value == value.roundToDouble() ? 0 : 1,
    ).format(value);
    return switch (measure) {
      StatisticsMeasure.weight => _commonLocalizations.quantityKilograms(number),
      StatisticsMeasure.volume => _commonLocalizations.quantityLiters(number),
      StatisticsMeasure.pieces => _commonLocalizations.quantityPieces(number),
      StatisticsMeasure.count => localizations.countValue(number),
    };
  }

  /// Axis labels: plain numbers with at most one decimal.
  String axisValue(double value) => NumberFormat('#,##0.#', _localeName).format(value);

  String percent(double share, {int maximumFractionDigits = 0}) => (NumberFormat.percentPattern(
    _localeName,
  )..maximumFractionDigits = maximumFractionDigits).format(share);

  String days(double value) => localizations.daysValue(value.round());

  String date(CalendarDate day) => DateFormat.yMMMd(_localeName).format(day.toLocalDateTime());

  String periodLabel(StatisticsDateRange period) =>
      localizations.periodLabel(date(period.firstDay), date(period.lastDay));

  /// "2 Oct" for days and weeks, "Oct '26" for months.
  String bucketLabel(StatisticsDateRange bucket, StatisticsBucketSize bucketSize) =>
      switch (bucketSize) {
        StatisticsBucketSize.day || StatisticsBucketSize.week => DateFormat.MMMd(
          _localeName,
        ).format(bucket.firstDay.toLocalDateTime()),
        StatisticsBucketSize.month => DateFormat(
          "MMM ''yy",
          _localeName,
        ).format(bucket.firstDay.toLocalDateTime()),
      };

  /// "Mon" for 1 ([DateTime.monday]) to "Sun" for 7.
  String weekdayShort(int weekday) =>
      DateFormat.E(_localeName).format(DateTime(2026, 9, 27 + weekday));

  /// "+12 %" style change for the key figures.
  String delta(double? relativeChange) {
    if (relativeChange == null) return localizations.deltaNone;
    if (relativeChange.abs() < 0.005) return localizations.deltaSame;
    final changeText = percent(relativeChange.abs());
    return relativeChange > 0
        ? localizations.deltaUp(changeText)
        : localizations.deltaDown(changeText);
  }

  String suggestedViewName(SuggestedStatisticsView view) => switch (view) {
    SuggestedStatisticsView.weekendMeals => localizations.viewWeekendMeals,
    SuggestedStatisticsView.wasteCheck => localizations.viewWasteCheck,
    SuggestedStatisticsView.fruitSeason => localizations.viewFruitSeason,
  };

  String activityName(StatisticsActivity activity) => switch (activity) {
    StatisticsActivity.consumed => localizations.activityConsumed,
    StatisticsActivity.added => localizations.activityAdded,
    StatisticsActivity.discarded => localizations.activityDiscarded,
    StatisticsActivity.moved => localizations.activityMoved,
  };

  /// "items eaten", for "Number of items eaten per day".
  String activityItemsName(StatisticsActivity activity) => switch (activity) {
    StatisticsActivity.consumed => localizations.activityItemsConsumed,
    StatisticsActivity.added => localizations.activityItemsAdded,
    StatisticsActivity.discarded => localizations.activityItemsDiscarded,
    StatisticsActivity.moved => localizations.activityItemsMoved,
  };

  /// Labels of [StatisticsAnalysis.eatenItemsByStorageDuration]'s columns.
  List<String> get storageDurationLabels => [
    localizations.durationUnderOneMonth,
    localizations.durationOneToThreeMonths,
    localizations.durationThreeToSixMonths,
    localizations.durationSixToNineMonths,
    localizations.durationNineToTwelveMonths,
    localizations.durationOverTwelveMonths,
  ];

  /// "M" for Monday to "S" for Sunday.
  String weekdayNarrow(int weekday) =>
      DateFormat.EEEEE(_localeName).format(DateTime(2026, 9, 27 + weekday));

  String month(CalendarDate firstDayOfMonth) =>
      DateFormat.MMM(_localeName).format(firstDayOfMonth.toLocalDateTime());

  String measureName(StatisticsMeasure measure) => switch (measure) {
    StatisticsMeasure.weight => localizations.measureWeight,
    StatisticsMeasure.volume => localizations.measureVolume,
    StatisticsMeasure.pieces => localizations.measurePieces,
    StatisticsMeasure.count => localizations.measureCount,
  };

  String comparisonName(StatisticsComparison comparison) => switch (comparison) {
    StatisticsComparison.off => localizations.compareOff,
    StatisticsComparison.previousPeriod => localizations.comparePrevious,
    StatisticsComparison.samePeriodLastYear => localizations.compareLastYear,
  };

  String granularityName(StatisticsGranularity granularity) => switch (granularity) {
    StatisticsGranularity.automatic => localizations.granularityAuto,
    StatisticsGranularity.day => localizations.granularityDay,
    StatisticsGranularity.week => localizations.granularityWeek,
    StatisticsGranularity.month => localizations.granularityMonth,
  };

  String periodPresetName(StatisticsPeriodPreset preset) => switch (preset) {
    StatisticsPeriodPreset.last30Days => localizations.period30Days,
    StatisticsPeriodPreset.last3Months => localizations.period3Months,
    StatisticsPeriodPreset.last12Months => localizations.period12Months,
    StatisticsPeriodPreset.thisYear => localizations.periodThisYear,
    StatisticsPeriodPreset.allTime => localizations.periodAllTime,
    StatisticsPeriodPreset.custom => localizations.periodCustom,
  };

  String discardReasonName(StatisticsDiscardReason reason) => switch (reason) {
    StatisticsDiscardReason.tooOld => localizations.reasonTooOld,
    StatisticsDiscardReason.freezerBurn => localizations.reasonFreezerBurn,
    StatisticsDiscardReason.expired => localizations.reasonExpired,
    StatisticsDiscardReason.spoiled => localizations.reasonSpoiled,
    StatisticsDiscardReason.unwanted => localizations.reasonUnwanted,
    StatisticsDiscardReason.other => localizations.reasonOther,
    StatisticsDiscardReason.notGiven => localizations.reasonNotGiven,
  };
}
