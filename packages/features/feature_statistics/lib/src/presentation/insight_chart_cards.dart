import 'package:core_design_system/core_design_system.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_providers.dart';
import '../domain/statistics_analysis.dart';
import '../domain/statistics_category_grouping.dart';
import '../domain/statistics_date_range.dart';
import '../domain/statistics_filter.dart';
import 'statistics_category_presentation.dart';
import 'statistics_formatting.dart';

void _changeFilter(WidgetRef ref, StatisticsFilter Function(StatisticsFilter current) change) =>
    ref.read(statisticsFilterProvider.notifier).change(change);

StatisticsFilter _withGroupToggled(StatisticsFilter filter, StatisticsCategoryGroup group) =>
    group.isOther
    ? filter.withCategoryGroupToggled(group.categoryIdentifiers)
    : filter.withCategoryToggled(group.categoryIdentifiers.single);

/// "Eaten vs added": both lines over the period, the eaten line of the
/// comparison period dashed; dragging picks a custom period.
class TrendChartCard extends ConsumerWidget {
  const TrendChartCard({required this.analysis, super.key});

  final StatisticsAnalysis analysis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final chartColors = context.chartColors;
    final measure = analysis.filter.measure;
    final buckets = analysis.buckets;
    final bucketLabels = [
      for (final bucket in buckets) formatting.bucketLabel(bucket, analysis.bucketSize),
    ];
    final eatenValues = analysis.bucketValuesOf(StatisticsActivity.consumed);
    final addedValues = analysis.bucketValuesOf(StatisticsActivity.added);
    final comparisonValues = analysis.comparisonBucketValuesOf(StatisticsActivity.consumed);
    String format(double value) => formatting.measureValue(value, measure);
    return ChartCard(
      title: localizations.trendTitle,
      subtitle: comparisonValues == null
          ? localizations.trendSubtitle
          : localizations.trendSubtitleWithComparison,
      notice: analysis.isThinData ? localizations.thinData(analysis.removalCount) : null,
      emptyMessage: analysis.hasAnyActivity ? null : localizations.noData,
      chart: TrendLineChart(
        bucketLabels: bucketLabels,
        series: [
          ChartSeries(
            label: localizations.seriesEaten,
            color: chartColors.seriesColorAt(0),
            values: eatenValues,
          ),
          ChartSeries(
            label: localizations.seriesAdded,
            color: chartColors.seriesColorAt(1),
            values: addedValues,
          ),
          if (comparisonValues != null)
            ChartSeries(
              label: localizations.seriesComparison,
              color: chartColors.comparisonSeries,
              values: comparisonValues,
              isComparison: true,
            ),
        ],
        formatValue: format,
        formatAxisValue: formatting.axisValue,
        onRangeSelected: (range) => _changeFilter(
          ref,
          (current) => current.withCustomPeriod(
            StatisticsDateRange(
              buckets[range.firstIndex].firstDay,
              buckets[range.lastIndex].lastDay,
            ),
          ),
        ),
      ),
      table: ChartTable(
        columnHeaders: [
          '',
          localizations.seriesEaten,
          localizations.seriesAdded,
          if (comparisonValues != null) localizations.seriesComparison,
        ],
        rows: [
          for (final (index, label) in bucketLabels.indexed)
            [
              label,
              format(eatenValues[index]),
              format(addedValues[index]),
              if (comparisonValues != null)
                index < comparisonValues.length ? format(comparisonValues[index]) : '–',
            ],
        ],
      ),
    );
  }
}

/// "Eaten by category": stacked bars per bucket; tapping a segment or a
/// legend entry filters that category.
class CategoryStackChartCard extends ConsumerWidget {
  const CategoryStackChartCard({required this.analysis, super.key});

  final StatisticsAnalysis analysis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(productCatalogProvider).value ?? ProductCatalog.empty;
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final categories = StatisticsCategoryPresentation.of(context, catalog: catalog);
    final measure = analysis.filter.measure;
    final bucketLabels = [
      for (final bucket in analysis.buckets) formatting.bucketLabel(bucket, analysis.bucketSize),
    ];
    final series = analysis.categorySeries;
    final allGroups = analysis.categoryGrouping.groups;
    String format(double value) => formatting.measureValue(value, measure);
    final hasValues = series.any((layer) => layer.total > 0);
    return ChartCard(
      title: localizations.stackedTitle(formatting.activityName(analysis.filter.activity)),
      emptyMessage: hasValues ? null : localizations.noData,
      chart: StackedBarChart(
        bucketLabels: bucketLabels,
        series: [
          for (final layer in series)
            ChartSeries(
              label: categories.labelOf(layer.group),
              color: categories.colorOf(layer.group),
              values: layer.bucketValues,
            ),
        ],
        legendEntries: [
          for (final group in allGroups)
            ChartLegendEntry(
              label: categories.labelOf(group),
              color: categories.colorOf(group),
              isDimmed: analysis.isGroupDimmed(group),
            ),
        ],
        formatValue: format,
        formatAxisValue: formatting.axisValue,
        onSeriesTapped: (seriesIndex) =>
            _changeFilter(ref, (current) => _withGroupToggled(current, series[seriesIndex].group)),
        onLegendEntryTapped: (groupIndex) =>
            _changeFilter(ref, (current) => _withGroupToggled(current, allGroups[groupIndex])),
      ),
      table: ChartTable(
        columnHeaders: ['', for (final layer in series) categories.labelOf(layer.group)],
        rows: [
          for (final (index, label) in bucketLabels.indexed)
            [label, for (final layer in series) format(layer.bucketValues[index])],
        ],
      ),
    );
  }
}

/// "Category share": a donut of the chosen activity per category.
class CategoryShareChartCard extends ConsumerWidget {
  const CategoryShareChartCard({required this.analysis, super.key});

  final StatisticsAnalysis analysis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(productCatalogProvider).value ?? ProductCatalog.empty;
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final categories = StatisticsCategoryPresentation.of(context, catalog: catalog);
    final measure = analysis.filter.measure;
    final shares = [
      for (final layer in analysis.categorySeries)
        if (layer.total > 0) layer,
    ];
    final total = shares.fold<double>(0, (sum, layer) => sum + layer.total);
    String format(double value) => formatting.measureValue(value, measure);
    return ChartCard(
      title: localizations.donutTitle,
      subtitle: formatting.activityName(analysis.filter.activity),
      emptyMessage: shares.isEmpty ? localizations.noData : null,
      chart: DonutChart(
        slices: [
          for (final layer in shares)
            ChartSlice(
              label: categories.labelOf(layer.group),
              value: layer.total,
              color: categories.colorOf(layer.group),
            ),
        ],
        centerLabel: localizations.total,
        formatValue: format,
        formatShare: formatting.percent,
        onSliceTapped: (sliceIndex) =>
            _changeFilter(ref, (current) => _withGroupToggled(current, shares[sliceIndex].group)),
      ),
      table: ChartTable(
        columnHeaders: ['', localizations.total, '%'],
        rows: [
          for (final layer in shares)
            [
              categories.labelOf(layer.group),
              format(layer.total),
              formatting.percent(total == 0 ? 0 : layer.total / total),
            ],
        ],
      ),
    );
  }
}

/// "Top products", eaten or thrown away; tapping a product filters it.
class TopProductsChartCard extends ConsumerStatefulWidget {
  const TopProductsChartCard({required this.analysis, super.key});

  final StatisticsAnalysis analysis;

  @override
  ConsumerState<TopProductsChartCard> createState() => _TopProductsChartCardState();
}

class _TopProductsChartCardState extends ConsumerState<TopProductsChartCard> {
  StatisticsActivity _rankedActivity = StatisticsActivity.consumed;

  @override
  Widget build(BuildContext context) {
    final analysis = widget.analysis;
    final catalog = ref.watch(productCatalogProvider).value ?? ProductCatalog.empty;
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final productNames = context.productDisplayNameResolver;
    final measure = analysis.filter.measure;
    final ranking = [
      for (final (productIdentifier, value) in analysis.topProducts(_rankedActivity))
        if (catalog.productOf(productIdentifier) case final product?) (product, value),
    ];
    return ChartCard(
      title: localizations.topProductsTitle,
      headerControl: Padding(
        padding: const EdgeInsets.only(bottom: FreezerSpacing.small),
        child: Wrap(
          spacing: FreezerSpacing.small,
          children: [
            for (final activity in [StatisticsActivity.consumed, StatisticsActivity.discarded])
              ChoiceChip(
                label: Text(formatting.activityName(activity)),
                selected: _rankedActivity == activity,
                onSelected: (_) => setState(() => _rankedActivity = activity),
              ),
          ],
        ),
      ),
      emptyMessage: ranking.isEmpty ? localizations.noData : null,
      chart: RankingBarList(
        rows: [
          for (final (product, value) in ranking)
            RankingBarRow(
              label: productNames.productName(product),
              leading: catalog.iconEmojiOf(product),
              value: value,
              formattedValue: formatting.measureValue(value, measure),
              isSelected: analysis.filter.productIdentifiers.contains(product.identifier),
            ),
        ],
        onRowTapped: (rowIndex) => _changeFilter(
          ref,
          (current) => current.withProductToggled(ranking[rowIndex].$1.identifier),
        ),
      ),
      table: ChartTable(
        columnHeaders: ['', localizations.total],
        rows: [
          for (final (product, value) in ranking)
            [productNames.productName(product), formatting.measureValue(value, measure)],
        ],
      ),
    );
  }
}

/// "Thrown away, by reason": number of items per reason.
class WasteByReasonChartCard extends StatelessWidget {
  const WasteByReasonChartCard({required this.analysis, super.key});

  final StatisticsAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final counts = analysis.discardedItemsByReason;
    return ChartCard(
      title: localizations.wasteTitle,
      subtitle: localizations.wasteSubtitle,
      emptyMessage: counts.every((entry) => entry.$2 == 0) ? localizations.noData : null,
      chart: RankingBarList(
        rows: [
          for (final (reason, count) in counts)
            RankingBarRow(
              label: formatting.discardReasonName(reason),
              value: count.toDouble(),
              formattedValue: '$count',
            ),
        ],
      ),
      table: ChartTable(
        columnHeaders: const ['', '#'],
        rows: [
          for (final (reason, count) in counts) [formatting.discardReasonName(reason), '$count'],
        ],
      ),
    );
  }
}
