import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_providers.dart';
import '../domain/statistics_analysis.dart';
import 'statistics_filter_bar.dart';
import 'statistics_formatting.dart';

/// The frame shared by the Insights screens: title with the period, the
/// pinned filter row, and an explanation instead of charts while nothing
/// has been recorded.
class InsightScreenScaffold extends ConsumerWidget {
  const InsightScreenScaffold({
    required this.title,
    required this.buildCharts,
    this.subtitleSuffix,
    super.key,
  });

  final String title;

  /// Added after the period in the subtitle, such as the activity.
  final String? subtitleSuffix;
  final List<Widget> Function(BuildContext context, StatisticsAnalysis analysis) buildCharts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final period = ref.watch(statisticsPeriodsProvider).value?.period;
    final firstActivityDay = ref.watch(firstActivityDayProvider);
    final hasNoHistory = firstActivityDay.hasValue && firstActivityDay.value == null;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (period != null && !hasNoHistory)
              Text(
                [formatting.periodLabel(period), ?subtitleSuffix].join(' · '),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.freezerColors.textMuted),
              ),
          ],
        ),
      ),
      body: hasNoHistory
          ? EmptyStateView(
              icon: Icons.insights_outlined,
              title: localizations.noHistoryTitle,
              message: localizations.noHistoryMessage,
            )
          : Column(
              children: [
                const StatisticsFilterBar(),
                Expanded(child: _InsightCharts(buildCharts: buildCharts)),
              ],
            ),
    );
  }
}

class _InsightCharts extends ConsumerWidget {
  const _InsightCharts({required this.buildCharts});

  final List<Widget> Function(BuildContext context, StatisticsAnalysis analysis) buildCharts;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(statisticsAnalysisProvider)) {
        AsyncValue(value: final analysis?) => InsightChartList(
          children: buildCharts(context, analysis),
        ),
        AsyncValue(error: final error?) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FreezerSpacing.extraLarge),
            child: Text('$error', textAlign: TextAlign.center),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      };
}

/// Charts in one scrolling column on phones and two columns on tablets.
/// A child marked [InsightFullWidth] always spans the whole width.
class InsightChartList extends StatelessWidget {
  const InsightChartList({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 720;
      const gutter = FreezerSpacing.screenGutter;
      final contentWidth = constraints.maxWidth - gutter * 2;
      final halfWidth = isWide ? (contentWidth - FreezerSpacing.medium) / 2 : contentWidth;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(gutter, FreezerSpacing.small, gutter, 96),
        child: Wrap(
          spacing: FreezerSpacing.medium,
          children: [
            for (final child in children)
              SizedBox(width: child is InsightFullWidth ? contentWidth : halfWidth, child: child),
          ],
        ),
      );
    },
  );
}

/// Spans the whole width of an [InsightChartList], such as the key figures.
class InsightFullWidth extends StatelessWidget {
  const InsightFullWidth({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// The charts other modules contribute, given the shared filter.
List<Widget> buildContributedInsightCharts(WidgetRef ref) {
  final snapshot = ref.watch(insightFilterSnapshotProvider).value;
  if (snapshot == null) return const [];
  return [
    for (final contribution in ref.watch(contributedInsightChartsProvider))
      Builder(
        key: ValueKey(contribution.identifier),
        builder: (context) => contribution.builder(context, snapshot),
      ),
  ];
}
