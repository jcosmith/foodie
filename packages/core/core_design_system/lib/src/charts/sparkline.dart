import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/freezer_chart_colors.dart';

/// A tiny line without axes for KPI tiles; decorative, so screen readers skip it.
class Sparkline extends StatelessWidget {
  const Sparkline({required this.values, this.color, this.height = 22, super.key});

  final List<double> values;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maximum = values.fold<double>(0, math.max);
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        child: values.length < 2
            ? null
            : LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (values.length - 1).toDouble(),
                  minY: 0,
                  maxY: maximum <= 0 ? 1 : maximum * 1.15,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (final (index, value) in values.indexed)
                          FlSpot(index.toDouble(), value),
                      ],
                      color: color ?? context.chartColors.singleSeries,
                      barWidth: 1.6,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Tiny bars without axes for KPI tiles, such as how long items were stored.
class MiniHistogram extends StatelessWidget {
  const MiniHistogram({required this.values, this.color, this.height = 22, super.key});

  final List<double> values;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maximum = values.fold<double>(0, math.max);
    final barColor = (color ?? context.chartColors.singleSeries).withValues(alpha: 0.75);
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final value in values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: FractionallySizedBox(
                    heightFactor: maximum <= 0 ? 0 : value / maximum,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
