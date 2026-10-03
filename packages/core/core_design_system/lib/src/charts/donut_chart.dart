import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/freezer_color_tokens.dart';
import '../theme/freezer_spacing.dart';
import 'chart_data.dart';
import 'chart_legend.dart';

/// Shares of a whole as a ring with the total in its centre and a legend
/// with percentages (UI examples document, phone 7: "Category share").
class DonutChart extends StatelessWidget {
  const DonutChart({
    required this.slices,
    required this.centerLabel,
    required this.formatValue,
    required this.formatShare,
    this.onSliceTapped,
    this.diameter = 140,
    super.key,
  });

  final List<ChartSlice> slices;

  /// Above the total in the centre, such as "Total".
  final String centerLabel;
  final ChartValueFormatter formatValue;

  /// Formats a share between 0 and 1, such as "42 %".
  final ChartValueFormatter formatShare;
  final ValueChanged<int>? onSliceTapped;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    final ringWidth = diameter * 0.17;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 2,
                  centerSpaceRadius: diameter / 2 - ringWidth,
                  sections: [
                    for (final slice in slices)
                      PieChartSectionData(
                        value: slice.value,
                        color: slice.color,
                        radius: ringWidth,
                        showTitle: false,
                      ),
                  ],
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent || onSliceTapped == null) return;
                      final sliceIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                      if (sliceIndex >= 0 && sliceIndex < slices.length) {
                        onSliceTapped!(sliceIndex);
                      }
                    },
                  ),
                ),
              ),
              ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.freezerColors.textMuted,
                      ),
                    ),
                    Text(
                      formatValue(total),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: FreezerSpacing.large),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, slice) in slices.indexed)
                InkWell(
                  onTap: onSliceTapped == null ? null : () => onSliceTapped!(index),
                  borderRadius: BorderRadius.circular(FreezerSpacing.extraSmall),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        ChartColorSwatch(color: slice.color),
                        const SizedBox(width: FreezerSpacing.small),
                        Expanded(child: Text(slice.label, style: theme.textTheme.bodySmall)),
                        Text(
                          formatShare(total == 0 ? 0 : slice.value / total),
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
