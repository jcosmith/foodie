import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/saved_statistics_views.dart';
import '../domain/statistics_analysis.dart';
import '../domain/statistics_category_grouping.dart';
import '../domain/statistics_date_range.dart';
import '../domain/statistics_filter.dart';
import '../domain/statistics_movement_fact.dart';
import '../domain/statistics_periods.dart';
import '../domain/statistics_repository.dart';
import 'saved_statistics_view_store.dart';

/// Overridden by the statistics module with the database implementation.
final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) => throw UnimplementedError('statisticsRepositoryProvider must be overridden'),
);

/// Holds the shared filter (decision D15). It is the only state of the
/// Insights tab; everything else is derived from it.
final class StatisticsFilterNotifier extends Notifier<StatisticsFilter> {
  @override
  StatisticsFilter build() => StatisticsFilter.initial;

  void change(StatisticsFilter Function(StatisticsFilter current) change) => state = change(state);

  void reset() => state = StatisticsFilter.initial;

  /// Replaces the whole filter, as opening a saved view does.
  void apply(StatisticsFilter filter) => state = filter;
}

final statisticsFilterProvider = NotifierProvider<StatisticsFilterNotifier, StatisticsFilter>(
  StatisticsFilterNotifier.new,
);

/// The local day of the first movement; `null` while nothing was recorded.
final firstActivityDayProvider = StreamProvider<CalendarDate?>(
  (ref) => ref.watch(statisticsRepositoryProvider).watchFirstActivityDay(),
);

/// The period and comparison period the filter selects today. Only period
/// and comparison choices affect it, so toggling a category re-runs no query.
final statisticsPeriodsProvider = FutureProvider<StatisticsPeriods>((ref) async {
  final (periodPreset, customPeriod, comparison) = ref.watch(
    statisticsFilterProvider.select(
      (filter) => (filter.periodPreset, filter.customPeriod, filter.comparison),
    ),
  );
  final today = ref.watch(clockProvider).todayLocal();
  final firstActivityDay = await ref.watch(firstActivityDayProvider.future);
  return StatisticsPeriods.resolveChoice(
    periodPreset: periodPreset,
    customPeriod: customPeriod,
    comparison: comparison,
    today: today,
    firstActivityDay: firstActivityDay,
  );
});

/// Movement facts of one period, live. One query per period; the
/// comparison period is a second instance.
final statisticsFactsProvider =
    StreamProvider.family<List<StatisticsMovementFact>, StatisticsDateRange>(
      (ref, period) => ref.watch(statisticsRepositoryProvider).watchFacts(period),
    );

/// The colour slot of every category on every chart.
final statisticsCategoryGroupingProvider = FutureProvider<StatisticsCategoryGrouping>((ref) async {
  final catalog = await ref.watch(productCatalogProvider.future);
  return StatisticsCategoryGrouping.fromCategories(catalog.categories);
});

/// Everything the Insights charts show. While a new period loads, the
/// previous analysis stays visible (Riverpod keeps the last value).
final statisticsAnalysisProvider = FutureProvider<StatisticsAnalysis>((ref) async {
  final filter = ref.watch(statisticsFilterProvider);
  final periods = await ref.watch(statisticsPeriodsProvider.future);
  final categoryGrouping = await ref.watch(statisticsCategoryGroupingProvider.future);
  final periodFacts = await ref.watch(statisticsFactsProvider(periods.period).future);
  final comparisonPeriod = periods.comparisonPeriod;
  final comparisonFacts = comparisonPeriod == null
      ? const <StatisticsMovementFact>[]
      : await ref.watch(statisticsFactsProvider(comparisonPeriod).future);
  return StatisticsAnalysis(
    filter: filter,
    periods: periods,
    periodFacts: periodFacts,
    comparisonFacts: comparisonFacts,
    categoryGrouping: categoryGrouping,
  );
});

/// What contributed charts of other modules get to see of the filter.
final insightFilterSnapshotProvider = FutureProvider<InsightFilterSnapshot>((ref) async {
  final filter = ref.watch(statisticsFilterProvider);
  final periods = await ref.watch(statisticsPeriodsProvider.future);
  return InsightFilterSnapshot(
    periodStart: periods.period.firstDay.toLocalDateTime().toUtc(),
    periodEnd: periods.period.lastDay.addDays(1).toLocalDateTime().toUtc(),
    categoryIdentifiers: {for (final identifier in filter.categoryIdentifiers) identifier.value},
    productIdentifiers: {for (final identifier in filter.productIdentifiers) identifier.value},
    compartmentIdentifiers: {
      for (final identifier in filter.compartmentIdentifiers) identifier.value,
    },
  );
});

/// Charts other modules add to the Insights tab, in sort order.
final contributedInsightChartsProvider = Provider<List<InsightChartContribution>>(
  (ref) =>
      [for (final module in ref.watch(registeredFeatureModulesProvider)) ...module.insightCharts]
        ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder)),
);

final savedStatisticsViewStoreProvider = Provider<SavedStatisticsViewStore>(
  (ref) => SavedStatisticsViewStore(ref.watch(preferencesStoreProvider)),
);

/// The views the user saved, oldest first.
final savedStatisticsViewsProvider = StreamProvider<List<SavedStatisticsView>>(
  (ref) => ref.watch(savedStatisticsViewStoreProvider).watch(),
);
