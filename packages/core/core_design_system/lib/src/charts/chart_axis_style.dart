import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/freezer_color_tokens.dart';
import 'chart_data.dart';

/// Grid, axis labels and tooltip styling shared by the axis charts, so
/// every chart in the app looks the same.
final class ChartAxisStyle {
  ChartAxisStyle.of(BuildContext context)
    : _tokens = context.freezerColors,
      _theme = Theme.of(context);

  final FreezerColorTokens _tokens;
  final ThemeData _theme;

  TextStyle get axisLabelStyle =>
      _theme.textTheme.labelSmall!.copyWith(color: _tokens.textMuted, fontSize: 10);

  TextStyle get tooltipTextStyle => _theme.textTheme.bodySmall!.copyWith(
    color: _theme.colorScheme.surface,
    fontWeight: FontWeight.w500,
  );

  Color get tooltipBackground => _theme.colorScheme.onSurface;

  Color get crosshairColor => _tokens.textMuted;

  FlGridData horizontalGrid(double maximum) => FlGridData(
    drawVerticalLine: false,
    horizontalInterval: maximum / 4,
    getDrawingHorizontalLine: (value) => FlLine(color: _tokens.chartGrid, strokeWidth: 1),
  );

  FlTitlesData titles({
    required List<String> bucketLabels,
    required double maximum,
    required ChartValueFormatter formatAxisValue,
  }) {
    final labelStep = ChartScale.labelStep(bucketLabels.length);
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          interval: maximum / 4,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            space: 4,
            child: Text(formatAxisValue(value), style: axisLabelStyle),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            if (value != index ||
                index < 0 ||
                index >= bucketLabels.length ||
                index % labelStep != 0) {
              return const SizedBox.shrink();
            }
            return SideTitleWidget(
              meta: meta,
              space: 4,
              child: Text(bucketLabels[index], style: axisLabelStyle),
            );
          },
        ),
      ),
    );
  }
}
