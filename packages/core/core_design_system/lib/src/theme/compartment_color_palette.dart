import 'package:flutter/painting.dart';

/// The colour tags a drawer can carry, in the order the layout editor cycles
/// through them. Stored as an index, so the palette can be retuned without a
/// migration.
abstract final class CompartmentColorPalette {
  static const List<Color> colors = [
    Color(0xFF2A78D6),
    Color(0xFF1BAF7A),
    Color(0xFFEDA100),
    Color(0xFFE87BA4),
    Color(0xFF7C6FE0),
    Color(0xFF8A94A6),
  ];

  static int get length => colors.length;

  /// The colour for a stored index; out-of-range indexes wrap around.
  static Color colorAt(int colorTagIndex) => colors[colorTagIndex % colors.length];

  /// The tag a newly added drawer gets, so neighbours differ.
  static int defaultIndexForPosition(int zeroBasedPosition) => zeroBasedPosition % colors.length;

  static int nextIndexAfter(int colorTagIndex) => (colorTagIndex + 1) % colors.length;
}
