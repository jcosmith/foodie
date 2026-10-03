import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'insight_chart_cards.dart';
import 'insight_screen_layout.dart';
import 'key_figure_grid.dart';
import 'statistics_formatting.dart';
import 'statistics_routes.dart';

/// The Insights tab (UI examples document, phone 7): the pinned filter row,
/// key figures and the overview charts, all reading the one shared filter.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final GlobalKey _categoryChartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final localizations = StatisticsFormatting.of(context).localizations;
    return InsightScreenScaffold(
      title: localizations.insightsTitle,
      buildCharts: (context, analysis) => [
        InsightFullWidth(
          child: Padding(
            padding: const EdgeInsets.only(bottom: FreezerSpacing.medium),
            child: KeyFigureGrid(analysis: analysis, onActivityChosen: _showCategoryChart),
          ),
        ),
        TrendChartCard(analysis: analysis),
        KeyedSubtree(
          key: _categoryChartKey,
          child: CategoryStackChartCard(analysis: analysis),
        ),
        CategoryShareChartCard(analysis: analysis),
        TopProductsChartCard(analysis: analysis),
        WasteByReasonChartCard(analysis: analysis),
        InsightFullWidth(
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(localizations.detailsButton),
              subtitle: Text(localizations.detailsButtonSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(StatisticsRoutes.details),
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryChart() {
    final categoryChartContext = _categoryChartKey.currentContext;
    if (categoryChartContext != null) {
      Scrollable.ensureVisible(categoryChartContext, duration: const Duration(milliseconds: 300));
    }
  }
}
