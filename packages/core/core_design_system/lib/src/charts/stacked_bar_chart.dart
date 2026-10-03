import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chart_axis_style.dart';
import 'chart_data.dart';
import 'chart_legend.dart';

/// One bar per bucket, stacked by series (UI examples document, phone 7:
/// "Eaten per category over time"). Tapping a segment or a legend entry
/// reports its series.
class StackedBarChart extends StatelessWidget {
  const StackedBarChart({
    required this.bucketLabels,
    required this.series,
    required this.formatValue,
    required this.formatAxisValue,
    this.legendEntries,
    this.onSeriesTapped,
    this.onLegendEntryTapped,
    this.height = 180,
    super.key,
  });

  final List<String> bucketLabels;
  final List<ChartSeries> series;
  final ChartValueFormatter formatValue;
  final ChartValueFormatter formatAxisValue;

  /// Defaults to one entry per series; pass more to offer entries for series
  /// that are currently filtered out.
  final List<ChartLegendEntry>? legendEntries;
  final ValueChanged<int>? onSeriesTapped;
  final ValueChanged<int>? onLegendEntryTapped;
  final double height;

  @override
  Widget build(BuildContext context) {
    final style = ChartAxisStyle.of(context);
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final totals = [
      for (var bucketIndex = 0; bucketIndex < bucketLabels.length; bucketIndex++)
        series.fold<double>(0, (sum, layer) => sum + _valueAt(layer, bucketIndex)),
    ];
    final maximum = ChartScale.niceMaximum(totals.fold(0, math.max));
    // fl_chart reports the touched stack item; remember which series each is.
    final seriesIndexesPerBucket = <List<int>>[];
    final barWidth = bucketLabels.isEmpty
        ? 18.0
        : (240 / bucketLabels.length - 2).clamp(2.0, 18.0).toDouble();
    final groups = <BarChartGroupData>[];
    for (var bucketIndex = 0; bucketIndex < bucketLabels.length; bucketIndex++) {
      final stackItems = <BarChartRodStackItem>[];
      final seriesIndexes = <int>[];
      var stackTop = 0.0;
      for (final (seriesIndex, layer) in series.indexed) {
        final value = _valueAt(layer, bucketIndex);
        if (value <= 0) continue;
        stackItems.add(
          BarChartRodStackItem(
            stackTop,
            stackTop + value,
            layer.color,
            borderSide: BorderSide(color: surfaceColor, width: 0.5),
          ),
        );
        seriesIndexes.add(seriesIndex);
        stackTop += value;
      }
      seriesIndexesPerBucket.add(seriesIndexes);
      groups.add(
        BarChartGroupData(
          x: bucketIndex,
          barRods: [
            BarChartRodData(
              toY: stackTop,
              width: barWidth,
              rodStackItems: stackItems,
              color: Colors.transparent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maximum,
              alignment: BarChartAlignment.spaceAround,
              gridData: style.horizontalGrid(maximum),
              borderData: FlBorderData(show: false),
              titlesData: style.titles(
                bucketLabels: bucketLabels,
                maximum: maximum,
                formatAxisValue: formatAxisValue,
              ),
              barGroups: groups,
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  if (event is! FlTapUpEvent || onSeriesTapped == null) return;
                  final spot = response?.spot;
                  if (spot == null || spot.touchedStackItemIndex < 0) return;
                  final seriesIndexes = seriesIndexesPerBucket[spot.touchedBarGroupIndex];
                  if (spot.touchedStackItemIndex < seriesIndexes.length) {
                    onSeriesTapped!(seriesIndexes[spot.touchedStackItemIndex]);
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => style.tooltipBackground,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  maxContentWidth: 220,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    [
                      bucketLabels[groupIndex],
                      for (final seriesIndex in seriesIndexesPerBucket[groupIndex].reversed)
                        '${series[seriesIndex].label}: '
                            '${formatValue(_valueAt(series[seriesIndex], groupIndex))}',
                    ].join('\n'),
                    style.tooltipTextStyle,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),
          ),
        ),
        ChartLegend(
          entries:
              legendEntries ??
              [
                for (final layer in series)
                  ChartLegendEntry(label: layer.label, color: layer.color),
              ],
          onEntryTapped: onLegendEntryTapped,
        ),
      ],
    );
  }

  static double _valueAt(ChartSeries series, int index) =>
      index < series.values.length ? series.values[index] : 0;
}
