import 'package:flutter/material.dart';

import '../theme/foodie_chart_colors.dart';
import '../theme/foodie_color_tokens.dart';
import '../theme/foodie_spacing.dart';
import 'chart_data.dart';

/// A dashed vertical marker between columns, such as a recommended
/// storage limit.
@immutable
final class ColumnBarMarker {
  const ColumnBarMarker({required this.position, required this.label});

  /// In columns from the start: 3 is the boundary after the third column.
  final double position;
  final String label;
}

/// A few labelled columns with their value on top: weekday pattern, storage
/// duration (UI examples document, phone 9). Plain widgets rather than
/// fl_chart, so every column carries its label, value and tap target for
/// screen readers.
class ColumnBarChart extends StatelessWidget {
  const ColumnBarChart({
    required this.labels,
    required this.values,
    required this.formatValue,
    this.selectedIndexes = const {},
    this.fadedIndexes = const {},
    this.marker,
    this.onColumnTapped,
    this.height = 140,
    super.key,
  });

  final List<String> labels;
  final List<double> values;
  final ChartValueFormatter formatValue;

  /// When not empty, the other columns are dimmed.
  final Set<int> selectedIndexes;

  /// Drawn lighter, such as durations beyond the recommendation.
  final Set<int> fadedIndexes;
  final ColumnBarMarker? marker;
  final ValueChanged<int>? onColumnTapped;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.foodieColors;
    final barColor = context.chartColors.singleSeries;
    final maximum = ChartScale.niceMaximum(
      values.fold(0, (largest, value) {
        return value > largest ? value : largest;
      }),
    );
    final labelStyle = theme.textTheme.labelSmall?.copyWith(color: tokens.textMuted);
    final valueStyle = theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700);
    const labelHeight = 18.0;
    const valueHeight = 16.0;
    final barAreaHeight = height - labelHeight - valueHeight;
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnWidth = constraints.maxWidth / (labels.isEmpty ? 1 : labels.length);
          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (index, label) in labels.indexed)
                    Expanded(
                      child: Semantics(
                        button: onColumnTapped != null,
                        selected: selectedIndexes.contains(index),
                        label: '$label: ${formatValue(values[index])}',
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: onColumnTapped == null ? null : () => onColumnTapped!(index),
                          borderRadius: BorderRadius.circular(FoodieSpacing.extraSmall),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: valueHeight,
                                child: Text(formatValue(values[index]), style: valueStyle),
                              ),
                              Container(
                                height: barAreaHeight * (values[index] / maximum).clamp(0, 1),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: barColor.withValues(
                                    alpha:
                                        selectedIndexes.isNotEmpty &&
                                            !selectedIndexes.contains(index)
                                        ? 0.3
                                        : fadedIndexes.contains(index)
                                        ? 0.55
                                        : 1,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: labelHeight,
                                child: Center(
                                  child: Text(
                                    label,
                                    style: labelStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (marker case final marker?)
                PositionedDirectional(
                  start: marker.position * columnWidth,
                  top: 0,
                  bottom: labelHeight,
                  child: IgnorePointer(
                    child: _ColumnMarker(label: marker.label, color: tokens.statusAging),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ColumnMarker extends StatelessWidget {
  const _ColumnMarker({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomPaint(size: const Size(1, double.infinity), painter: _DashedLinePainter(color)),
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 3),
        child: Text(
          '▲ $label',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ),
    ],
  );
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var top = 0.0; top < size.height; top += 6) {
      canvas.drawLine(Offset(0, top), Offset(0, (top + 3).clamp(0, size.height)), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
