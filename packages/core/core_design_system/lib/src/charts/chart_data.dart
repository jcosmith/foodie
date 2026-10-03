import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Formats a chart value for tooltips, tables and axis labels.
typedef ChartValueFormatter = String Function(double value);

/// One line or one stack layer: a value per bucket, in bucket order.
@immutable
final class ChartSeries {
  const ChartSeries({
    required this.label,
    required this.color,
    required this.values,
    this.isComparison = false,
  });

  final String label;
  final Color color;
  final List<double> values;

  /// Drawn dashed and thin, as the "Before" line of a comparison.
  final bool isComparison;
}

/// One slice of a donut, or one row of a ranking.
@immutable
final class ChartSlice {
  const ChartSlice({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;
}

/// The exact values behind a chart, shown by the "Table" switch for screen
/// readers and people who want numbers.
@immutable
final class ChartTable {
  const ChartTable({required this.columnHeaders, required this.rows});

  final List<String> columnHeaders;
  final List<List<String>> rows;
}

/// An inclusive range of bucket indexes, such as a range picked by dragging
/// across a trend chart.
@immutable
final class ChartIndexRange {
  const ChartIndexRange(int firstIndex, int lastIndex)
    : firstIndex = firstIndex < lastIndex ? firstIndex : lastIndex,
      lastIndex = firstIndex < lastIndex ? lastIndex : firstIndex;

  final int firstIndex;
  final int lastIndex;

  @override
  bool operator ==(Object other) =>
      other is ChartIndexRange && other.firstIndex == firstIndex && other.lastIndex == lastIndex;

  @override
  int get hashCode => Object.hash(firstIndex, lastIndex);

  @override
  String toString() => 'ChartIndexRange($firstIndex–$lastIndex)';
}

/// Axis helpers shared by the charts.
abstract final class ChartScale {
  /// The smallest "round" number (1, 2, 2.5 or 5 times a power of ten) at or
  /// above [value], so axes end on readable numbers. Never below 1.
  static double niceMaximum(double value) {
    if (value <= 1) return 1;
    var magnitude = 1.0;
    while (magnitude * 10 <= value) {
      magnitude *= 10;
    }
    final normalized = value / magnitude;
    final niceNormalized = normalized <= 1
        ? 1.0
        : normalized <= 2
        ? 2.0
        : normalized <= 2.5
        ? 2.5
        : normalized <= 5
        ? 5.0
        : 10.0;
    return niceNormalized * magnitude;
  }

  /// Every how many buckets to print a label so about [maximumLabels] fit.
  static int labelStep(int bucketCount, {int maximumLabels = 5}) =>
      bucketCount <= maximumLabels ? 1 : (bucketCount / maximumLabels).ceil();
}
