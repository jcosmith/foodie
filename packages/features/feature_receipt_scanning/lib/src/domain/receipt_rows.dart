import 'package:meta/meta.dart';

/// One line of text as on-device text recognition returns it, with its box
/// on the page in pixels (decision D16).
@immutable
final class RecognizedTextLine {
  const RecognizedTextLine({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  double get height => bottom - top;
  double get verticalCenter => (top + bottom) / 2;
}

/// The pieces of one printed row, left to right. Recognition often splits a
/// row into the description and the price, far apart on the paper.
@immutable
final class ReceiptRow {
  const ReceiptRow(this.pieces);

  final List<RecognizedTextLine> pieces;

  String get text => pieces.map((piece) => piece.text.trim()).join(' ').trim();
}

/// Groups recognised lines into printed rows.
abstract final class ReceiptRows {
  /// Lines whose vertical centres are closer than half a line height belong
  /// to the same row; rows come top to bottom, pieces left to right.
  static List<ReceiptRow> fromLines(List<RecognizedTextLine> lines) {
    final sorted = [
      for (final line in lines)
        if (line.text.trim().isNotEmpty) line,
    ]..sort((first, second) => first.verticalCenter.compareTo(second.verticalCenter));
    final rows = <List<RecognizedTextLine>>[];
    for (final line in sorted) {
      final current = rows.lastOrNull;
      if (current != null && _isSameRow(current, line)) {
        current.add(line);
      } else {
        rows.add([line]);
      }
    }
    return [
      for (final row in rows)
        ReceiptRow(List.unmodifiable(row..sort((a, b) => a.left.compareTo(b.left)))),
    ];
  }

  static bool _isSameRow(List<RecognizedTextLine> row, RecognizedTextLine line) {
    final rowCenter = row.fold<double>(0, (sum, piece) => sum + piece.verticalCenter) / row.length;
    final rowHeight = row.fold<double>(0, (sum, piece) => sum + piece.height) / row.length;
    final tolerance = (rowHeight < line.height ? rowHeight : line.height) / 2;
    return (line.verticalCenter - rowCenter).abs() <= tolerance;
  }
}
