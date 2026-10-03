import 'dart:math' as math;

import 'package:core_foundation/core_foundation.dart';
import 'package:flutter/material.dart';

import '../theme/freezer_chart_colors.dart';
import '../theme/freezer_color_tokens.dart';
import '../theme/freezer_spacing.dart';
import 'chart_legend.dart';

/// A GitHub-style calendar: one column per week (Monday on top), one cell
/// per day, darker the more happened (UI examples document, phone 9:
/// "Freezer days"). Drawn with a custom painter because fl_chart has no
/// heatmap (decision D7). Tapping a day reports it.
class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({
    required this.firstDay,
    required this.lastDay,
    required this.countsByDay,
    required this.weekdayLabels,
    required this.formatMonth,
    this.selectedDay,
    this.onDayTapped,
    super.key,
  });

  final CalendarDate firstDay;
  final CalendarDate lastDay;

  /// Days without an entry count as zero.
  final Map<CalendarDate, int> countsByDay;

  /// Seven narrow names, Monday first.
  final List<String> weekdayLabels;
  final String Function(CalendarDate firstDayOfMonth) formatMonth;
  final CalendarDate? selectedDay;
  final ValueChanged<CalendarDate>? onDayTapped;

  static const double _weekdayLabelWidth = 18;
  static const double _monthLabelHeight = 14;
  static const double _cellGap = 2;

  @override
  Widget build(BuildContext context) {
    final chartColors = context.chartColors;
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: context.freezerColors.textMuted,
      fontSize: 9.5,
    );
    final maximumCount = countsByDay.values.fold(0, math.max);
    final layout = _CalendarLayout(firstDay: firstDay, lastDay: lastDay);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = math.min(
              16.0,
              (constraints.maxWidth - _weekdayLabelWidth) / layout.weekCount - _cellGap,
            );
            final height = _monthLabelHeight + 7 * (cellSize + _cellGap);
            return GestureDetector(
              onTapUp: onDayTapped == null
                  ? null
                  : (details) {
                      final day = layout.dayAt(
                        details.localPosition,
                        cellSize: cellSize,
                        origin: const Offset(_weekdayLabelWidth, _monthLabelHeight),
                        cellGap: _cellGap,
                      );
                      if (day != null) onDayTapped!(day);
                    },
              child: CustomPaint(
                size: Size(constraints.maxWidth, height),
                painter: _CalendarHeatmapPainter(
                  layout: layout,
                  countsByDay: countsByDay,
                  maximumCount: maximumCount,
                  heatLevels: chartColors.heatLevels,
                  selectedDay: selectedDay,
                  selectionColor: theme.colorScheme.onSurface,
                  cellSize: cellSize,
                  weekdayLabels: weekdayLabels,
                  formatMonth: formatMonth,
                  labelStyle: labelStyle,
                  textDirection: Directionality.of(context),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: FreezerSpacing.small),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('0', style: labelStyle),
              const SizedBox(width: FreezerSpacing.extraSmall),
              for (final color in chartColors.heatLevels.skip(1)) ...[
                ChartColorSwatch(color: color),
                const SizedBox(width: 2),
              ],
              const SizedBox(width: FreezerSpacing.extraSmall),
              Text('$maximumCount', style: labelStyle),
            ],
          ),
        ),
      ],
    );
  }
}

/// Where each day sits: columns are Monday-based weeks, the last one
/// holding [lastDay].
final class _CalendarLayout {
  _CalendarLayout({required this.firstDay, required this.lastDay})
    : _firstMonday = firstDay.addDays(1 - firstDay.weekday),
      weekCount = (firstDay.addDays(1 - firstDay.weekday).daysUntil(lastDay) ~/ 7) + 1;

  final CalendarDate firstDay;
  final CalendarDate lastDay;
  final CalendarDate _firstMonday;
  final int weekCount;

  int columnOf(CalendarDate day) => _firstMonday.daysUntil(day) ~/ 7;

  CalendarDate? dayAt(
    Offset position, {
    required double cellSize,
    required Offset origin,
    required double cellGap,
  }) {
    final column = ((position.dx - origin.dx) / (cellSize + cellGap)).floor();
    final row = ((position.dy - origin.dy) / (cellSize + cellGap)).floor();
    if (column < 0 || column >= weekCount || row < 0 || row > 6) return null;
    final day = _firstMonday.addDays(column * 7 + row);
    return day.isBefore(firstDay) || day.isAfter(lastDay) ? null : day;
  }
}

class _CalendarHeatmapPainter extends CustomPainter {
  _CalendarHeatmapPainter({
    required this.layout,
    required this.countsByDay,
    required this.maximumCount,
    required this.heatLevels,
    required this.selectedDay,
    required this.selectionColor,
    required this.cellSize,
    required this.weekdayLabels,
    required this.formatMonth,
    required this.labelStyle,
    required this.textDirection,
  });

  final _CalendarLayout layout;
  final Map<CalendarDate, int> countsByDay;
  final int maximumCount;
  final List<Color> heatLevels;
  final CalendarDate? selectedDay;
  final Color selectionColor;
  final double cellSize;
  final List<String> weekdayLabels;
  final String Function(CalendarDate firstDayOfMonth) formatMonth;
  final TextStyle labelStyle;
  final TextDirection textDirection;

  static const double _left = CalendarHeatmap._weekdayLabelWidth;
  static const double _top = CalendarHeatmap._monthLabelHeight;
  static const double _gap = CalendarHeatmap._cellGap;

  @override
  void paint(Canvas canvas, Size size) {
    // Weekday labels on Monday, Wednesday and Friday, as calendars usually do.
    for (final row in [0, 2, 4]) {
      _paintText(canvas, weekdayLabels[row], Offset(0, _top + row * (cellSize + _gap)));
    }
    final cellPaint = Paint();
    final levelCount = heatLevels.length - 1;
    var lastLabelledMonth = -1;
    for (var day = layout.firstDay; !day.isAfter(layout.lastDay); day = day.addDays(1)) {
      final column = layout.columnOf(day);
      final row = day.weekday - 1;
      final cellOrigin = Offset(_left + column * (cellSize + _gap), _top + row * (cellSize + _gap));
      if (row == 0 && day.day <= 7 && day.month != lastLabelledMonth) {
        lastLabelledMonth = day.month;
        _paintText(
          canvas,
          formatMonth(CalendarDate(day.year, day.month, 1)),
          Offset(cellOrigin.dx, 0),
        );
      }
      final count = countsByDay[day] ?? 0;
      final level = count <= 0 || maximumCount <= 0
          ? 0
          : math.max(1, (count / maximumCount * levelCount).ceil());
      cellPaint.color = heatLevels[level];
      final cell = RRect.fromRectAndRadius(
        cellOrigin & Size.square(cellSize),
        const Radius.circular(2),
      );
      canvas.drawRRect(cell, cellPaint);
      if (day == selectedDay) {
        canvas.drawRRect(
          cell,
          Paint()
            ..color = selectionColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  void _paintText(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, offset);
    painter.dispose();
  }

  @override
  bool shouldRepaint(_CalendarHeatmapPainter oldDelegate) =>
      oldDelegate.countsByDay != countsByDay ||
      oldDelegate.selectedDay != selectedDay ||
      oldDelegate.cellSize != cellSize ||
      oldDelegate.heatLevels != heatLevels ||
      oldDelegate.layout.firstDay != layout.firstDay ||
      oldDelegate.layout.lastDay != layout.lastDay;
}
