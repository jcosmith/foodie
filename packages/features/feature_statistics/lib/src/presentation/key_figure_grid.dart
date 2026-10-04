import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_providers.dart';
import '../domain/statistics_analysis.dart';
import '../domain/statistics_filter.dart';
import 'statistics_formatting.dart';

/// Used, added, thrown away and average days stored, each with its change
/// against the comparison period and a small chart (UI examples document,
/// phone 7). Tapping one of the first three shows that activity in the
/// category charts.
class KeyFigureGrid extends ConsumerWidget {
  const KeyFigureGrid({required this.analysis, required this.onActivityChosen, super.key});

  final StatisticsAnalysis analysis;

  /// Called after a tile switched the filter's activity, to bring the
  /// matching chart into view.
  final VoidCallback onActivityChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final measure = analysis.filter.measure;
    final eaten = analysis.totalOf(StatisticsActivity.consumed);
    final added = analysis.totalOf(StatisticsActivity.added);
    final wasteShare = analysis.wasteShare;
    final storedDays = analysis.averageStoredDaysBeforeEaten;

    void chooseActivity(StatisticsActivity activity) {
      ref
          .read(statisticsFilterProvider.notifier)
          .change((current) => current.withActivity(activity));
      onActivityChosen();
    }

    final tiles = [
      KpiTile(
        label: localizations.kpiEaten,
        value: formatting.measureValue(eaten.current ?? 0, measure),
        deltaText: formatting.delta(eaten.relativeChange),
        chart: Sparkline(values: analysis.bucketValuesOf(StatisticsActivity.consumed)),
        onTap: () => chooseActivity(StatisticsActivity.consumed),
      ),
      KpiTile(
        label: localizations.kpiAdded,
        value: formatting.measureValue(added.current ?? 0, measure),
        deltaText: formatting.delta(added.relativeChange),
        chart: Sparkline(values: analysis.bucketValuesOf(StatisticsActivity.added)),
        onTap: () => chooseActivity(StatisticsActivity.added),
      ),
      KpiTile(
        label: localizations.kpiWasted,
        value: formatting.percent(wasteShare.current ?? 0, maximumFractionDigits: 1),
        deltaText: formatting.delta(wasteShare.relativeChange),
        chart: Sparkline(values: analysis.bucketValuesOf(StatisticsActivity.discarded)),
        onTap: () => chooseActivity(StatisticsActivity.discarded),
      ),
      KpiTile(
        label: localizations.kpiStored,
        value: storedDays.current == null ? '–' : formatting.days(storedDays.current!),
        deltaText: formatting.delta(storedDays.relativeChange),
        chart: MiniHistogram(values: analysis.storedDaysHistogram),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 720 ? 4 : 2;
        const gap = FoodieSpacing.small;
        final tileWidth = (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final tile in tiles) SizedBox(width: tileWidth, child: tile)],
        );
      },
    );
  }
}
