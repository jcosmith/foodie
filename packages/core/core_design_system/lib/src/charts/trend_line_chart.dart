import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chart_axis_style.dart';
import 'chart_data.dart';
import 'chart_legend.dart';

/// Lines over time with a crosshair tooltip, an optional dashed comparison
/// line, and brushing: dragging across the chart picks a range of buckets
/// (UI examples document, phone 7).
class TrendLineChart extends StatefulWidget {
  const TrendLineChart({
    required this.bucketLabels,
    required this.series,
    required this.formatValue,
    required this.formatAxisValue,
    this.onRangeSelected,
    this.height = 180,
    super.key,
  });

  final List<String> bucketLabels;

  /// Comparison series may have fewer values than there are buckets.
  final List<ChartSeries> series;
  final ChartValueFormatter formatValue;
  final ChartValueFormatter formatAxisValue;

  /// Called with the dragged range once the finger lifts; dragging needs at
  /// least two buckets.
  final ValueChanged<ChartIndexRange>? onRangeSelected;
  final double height;

  @override
  State<TrendLineChart> createState() => _TrendLineChartState();
}

class _TrendLineChartState extends State<TrendLineChart> {
  int? _brushStartIndex;
  int? _brushCurrentIndex;

  int get _lastIndex => math.max(0, widget.bucketLabels.length - 1);

  @override
  Widget build(BuildContext context) {
    final style = ChartAxisStyle.of(context);
    final maximum = ChartScale.niceMaximum(
      widget.series.expand((series) => series.values).fold(0, math.max),
    );
    final brushStart = _brushStartIndex;
    final brushCurrent = _brushCurrentIndex;
    final isBrushing = brushStart != null && brushCurrent != null && brushStart != brushCurrent;
    // Comparison lines are drawn first so the current period stays on top.
    final orderedSeries = [
      ...widget.series.where((series) => series.isComparison),
      ...widget.series.where((series) => !series.isComparison),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.height,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: _lastIndex.toDouble(),
              minY: 0,
              maxY: maximum,
              gridData: style.horizontalGrid(maximum),
              borderData: FlBorderData(show: false),
              titlesData: style.titles(
                bucketLabels: widget.bucketLabels,
                maximum: maximum,
                formatAxisValue: widget.formatAxisValue,
              ),
              rangeAnnotations: RangeAnnotations(
                verticalRangeAnnotations: [
                  if (isBrushing)
                    VerticalRangeAnnotation(
                      x1: math.min(brushStart, brushCurrent).toDouble(),
                      x2: math.max(brushStart, brushCurrent).toDouble(),
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    ),
                ],
              ),
              lineBarsData: [
                for (final series in orderedSeries)
                  LineChartBarData(
                    spots: [
                      for (final (index, value) in series.values.indexed)
                        if (index <= _lastIndex) FlSpot(index.toDouble(), value),
                    ],
                    color: series.color,
                    barWidth: series.isComparison ? 1.5 : 2,
                    dashArray: series.isComparison ? const [4, 3] : null,
                    dotData: FlDotData(show: widget.bucketLabels.length == 1),
                  ),
              ],
              lineTouchData: LineTouchData(
                // Always report the nearest bucket, wherever the finger is.
                touchSpotThreshold: double.infinity,
                touchCallback: _handleTouch,
                getTouchedSpotIndicator: (barData, spotIndexes) => [
                  for (final _ in spotIndexes)
                    TouchedSpotIndicatorData(
                      FlLine(color: style.crosshairColor, strokeWidth: 1),
                      FlDotData(
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 3.5,
                          color: bar.color ?? style.crosshairColor,
                          strokeWidth: 1.5,
                          strokeColor: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                ],
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => style.tooltipBackground,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  maxContentWidth: 220,
                  getTooltipItems: (touchedSpots) => [
                    for (final (position, touchedSpot) in touchedSpots.indexed)
                      LineTooltipItem(
                        [
                          if (position == 0) '${widget.bucketLabels[touchedSpot.x.round()]}\n',
                          '${orderedSeries[touchedSpot.barIndex].label}: '
                              '${widget.formatValue(touchedSpot.y)}',
                        ].join(),
                        style.tooltipTextStyle,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ChartLegend(
          entries: [
            for (final series in widget.series)
              ChartLegendEntry(label: series.label, color: series.color),
          ],
        ),
      ],
    );
  }

  void _handleTouch(FlTouchEvent event, LineTouchResponse? response) {
    if (widget.onRangeSelected == null || widget.bucketLabels.length < 2) return;
    final touchedIndex = response?.lineBarSpots?.firstOrNull?.x.round();
    switch (event) {
      // The range starts where the finger went down, not where the drag
      // was recognised a few pixels later.
      case FlPanDownEvent() || FlLongPressStart():
        setState(() {
          _brushStartIndex = touchedIndex;
          _brushCurrentIndex = touchedIndex;
        });
      case FlPanUpdateEvent() || FlLongPressMoveUpdate():
        if (touchedIndex != null && _brushStartIndex != null) {
          setState(() => _brushCurrentIndex = touchedIndex);
        }
      case FlPanEndEvent() || FlLongPressEnd():
        final start = _brushStartIndex;
        final end = _brushCurrentIndex;
        setState(() {
          _brushStartIndex = null;
          _brushCurrentIndex = null;
        });
        if (start != null && end != null && start != end) {
          widget.onRangeSelected!(ChartIndexRange(start, end));
        }
      case FlPanCancelEvent():
        setState(() {
          _brushStartIndex = null;
          _brushCurrentIndex = null;
        });
      default:
        break;
    }
  }
}
