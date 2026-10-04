import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_providers.dart';
import 'insight_detail_chart_cards.dart';
import 'insight_screen_layout.dart';
import 'statistics_formatting.dart';

/// "Statistics · details" (UI examples document, phone 9): when and where the
/// storage is used, and charts other modules contribute, under the same filter.
class InsightDetailsScreen extends ConsumerWidget {
  const InsightDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatting = StatisticsFormatting.of(context);
    final activity = ref.watch(statisticsFilterProvider.select((filter) => filter.activity));
    return InsightScreenScaffold(
      title: formatting.localizations.detailsTitle,
      subtitleSuffix: formatting.activityName(activity),
      buildCharts: (context, analysis) => [
        ActivityCalendarChartCard(analysis: analysis),
        WeekdayPatternChartCard(analysis: analysis),
        StorageDurationChartCard(analysis: analysis),
        StorageMapChartCard(filter: analysis.filter),
        ...buildContributedInsightCharts(ref),
      ],
    );
  }
}
