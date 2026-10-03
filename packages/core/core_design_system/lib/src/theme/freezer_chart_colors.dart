import 'package:flutter/material.dart';

/// Colours of the chart kit (decision D7), from the UI examples document.
///
/// [seriesPalette] holds the six colours that entities such as categories
/// keep on every chart; everything beyond six shares [otherSeries].
@immutable
final class FreezerChartColors extends ThemeExtension<FreezerChartColors> {
  const FreezerChartColors({
    required this.seriesPalette,
    required this.otherSeries,
    required this.comparisonSeries,
    required this.singleSeries,
    required this.heatLevels,
  });

  static const FreezerChartColors light = FreezerChartColors(
    seriesPalette: [
      Color(0xFF2A78D6),
      Color(0xFFEB6834),
      Color(0xFF1BAF7A),
      Color(0xFFEDA100),
      Color(0xFFE87BA4),
      Color(0xFF008300),
    ],
    otherSeries: Color(0xFF8A94A6),
    comparisonSeries: Color(0xFF9AA3B0),
    singleSeries: Color(0xFF1769C2),
    heatLevels: [
      Color(0xFFEDF1F6),
      Color(0xFFCDE2FB),
      Color(0xFF9EC5F4),
      Color(0xFF6DA7EC),
      Color(0xFF3987E5),
      Color(0xFF1C5CAB),
    ],
  );

  static const FreezerChartColors dark = FreezerChartColors(
    seriesPalette: [
      Color(0xFF3987E5),
      Color(0xFFD95926),
      Color(0xFF199E70),
      Color(0xFFC98500),
      Color(0xFFD55181),
      Color(0xFF008300),
    ],
    otherSeries: Color(0xFF6B7586),
    comparisonSeries: Color(0xFF5D6879),
    singleSeries: Color(0xFF7DB3F0),
    heatLevels: [
      Color(0xFF222B38),
      Color(0xFF193457),
      Color(0xFF184F95),
      Color(0xFF256ABF),
      Color(0xFF3987E5),
      Color(0xFF86B6EF),
    ],
  );

  /// How many entities get a colour of their own.
  static const int distinctSeriesColorCount = 6;

  final List<Color> seriesPalette;

  /// The shared colour of everything beyond the palette ("Other").
  final Color otherSeries;

  /// The dashed comparison line ("Before").
  final Color comparisonSeries;

  /// Bars and lines of charts with one series.
  final Color singleSeries;

  /// From "nothing" to "most" in calendar heatmaps.
  final List<Color> heatLevels;

  /// The palette colour at [paletteIndex], or [otherSeries] for `null` or an
  /// index beyond the palette.
  Color seriesColorAt(int? paletteIndex) =>
      paletteIndex == null || paletteIndex < 0 || paletteIndex >= seriesPalette.length
      ? otherSeries
      : seriesPalette[paletteIndex];

  @override
  FreezerChartColors copyWith({
    List<Color>? seriesPalette,
    Color? otherSeries,
    Color? comparisonSeries,
    Color? singleSeries,
    List<Color>? heatLevels,
  }) => FreezerChartColors(
    seriesPalette: seriesPalette ?? this.seriesPalette,
    otherSeries: otherSeries ?? this.otherSeries,
    comparisonSeries: comparisonSeries ?? this.comparisonSeries,
    singleSeries: singleSeries ?? this.singleSeries,
    heatLevels: heatLevels ?? this.heatLevels,
  );

  @override
  FreezerChartColors lerp(covariant FreezerChartColors? other, double t) {
    if (other == null) return this;
    List<Color> lerpList(List<Color> from, List<Color> to) => [
      for (var index = 0; index < from.length; index++)
        Color.lerp(from[index], to[index % to.length], t)!,
    ];
    return FreezerChartColors(
      seriesPalette: lerpList(seriesPalette, other.seriesPalette),
      otherSeries: Color.lerp(otherSeries, other.otherSeries, t)!,
      comparisonSeries: Color.lerp(comparisonSeries, other.comparisonSeries, t)!,
      singleSeries: Color.lerp(singleSeries, other.singleSeries, t)!,
      heatLevels: lerpList(heatLevels, other.heatLevels),
    );
  }
}

extension FreezerChartColorsContext on BuildContext {
  FreezerChartColors get chartColors =>
      Theme.of(this).extension<FreezerChartColors>() ?? FreezerChartColors.light;
}
