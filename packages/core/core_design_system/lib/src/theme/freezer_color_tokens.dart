import 'package:flutter/material.dart';

/// App-specific colours that Material's [ColorScheme] has no slot for:
/// the storage age statuses and muted surfaces.
///
/// Read them with `Theme.of(context).extension<FreezerColorTokens>()!` or the
/// `context.freezerColors` shortcut.
@immutable
final class FreezerColorTokens extends ThemeExtension<FreezerColorTokens> {
  const FreezerColorTokens({
    required this.surfaceMuted,
    required this.textMuted,
    required this.border,
    required this.primarySoft,
    required this.statusFresh,
    required this.statusFreshSoft,
    required this.statusAging,
    required this.statusAgingSoft,
    required this.statusUrgent,
    required this.statusUrgentSoft,
    required this.chartGrid,
  });

  static const FreezerColorTokens light = FreezerColorTokens(
    surfaceMuted: Color(0xFFEDF1F6),
    textMuted: Color(0xFF5D6879),
    border: Color(0xFFDFE4EB),
    primarySoft: Color(0xFFDCEBFB),
    statusFresh: Color(0xFF157F3B),
    statusFreshSoft: Color(0xFFE0F3E6),
    statusAging: Color(0xFF8A5A00),
    statusAgingSoft: Color(0xFFFBEFD5),
    statusUrgent: Color(0xFFB42318),
    statusUrgentSoft: Color(0xFFFDE6E4),
    chartGrid: Color(0xFFE3E8EF),
  );

  static const FreezerColorTokens dark = FreezerColorTokens(
    surfaceMuted: Color(0xFF222B38),
    textMuted: Color(0xFF9BA6B7),
    border: Color(0xFF2C3646),
    primarySoft: Color(0xFF1D3150),
    statusFresh: Color(0xFF72D495),
    statusFreshSoft: Color(0xFF16321F),
    statusAging: Color(0xFFF0C060),
    statusAgingSoft: Color(0xFF3A2C10),
    statusUrgent: Color(0xFFFF8F84),
    statusUrgentSoft: Color(0xFF401B18),
    chartGrid: Color(0xFF263041),
  );

  final Color surfaceMuted;
  final Color textMuted;
  final Color border;
  final Color primarySoft;
  final Color statusFresh;
  final Color statusFreshSoft;
  final Color statusAging;
  final Color statusAgingSoft;
  final Color statusUrgent;
  final Color statusUrgentSoft;
  final Color chartGrid;

  @override
  FreezerColorTokens copyWith({
    Color? surfaceMuted,
    Color? textMuted,
    Color? border,
    Color? primarySoft,
    Color? statusFresh,
    Color? statusFreshSoft,
    Color? statusAging,
    Color? statusAgingSoft,
    Color? statusUrgent,
    Color? statusUrgentSoft,
    Color? chartGrid,
  }) => FreezerColorTokens(
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    textMuted: textMuted ?? this.textMuted,
    border: border ?? this.border,
    primarySoft: primarySoft ?? this.primarySoft,
    statusFresh: statusFresh ?? this.statusFresh,
    statusFreshSoft: statusFreshSoft ?? this.statusFreshSoft,
    statusAging: statusAging ?? this.statusAging,
    statusAgingSoft: statusAgingSoft ?? this.statusAgingSoft,
    statusUrgent: statusUrgent ?? this.statusUrgent,
    statusUrgentSoft: statusUrgentSoft ?? this.statusUrgentSoft,
    chartGrid: chartGrid ?? this.chartGrid,
  );

  @override
  FreezerColorTokens lerp(covariant FreezerColorTokens? other, double t) {
    if (other == null) return this;
    return FreezerColorTokens(
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      statusFresh: Color.lerp(statusFresh, other.statusFresh, t)!,
      statusFreshSoft: Color.lerp(statusFreshSoft, other.statusFreshSoft, t)!,
      statusAging: Color.lerp(statusAging, other.statusAging, t)!,
      statusAgingSoft: Color.lerp(statusAgingSoft, other.statusAgingSoft, t)!,
      statusUrgent: Color.lerp(statusUrgent, other.statusUrgent, t)!,
      statusUrgentSoft: Color.lerp(statusUrgentSoft, other.statusUrgentSoft, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
    );
  }
}

extension FreezerColorTokensContext on BuildContext {
  FreezerColorTokens get freezerColors =>
      Theme.of(this).extension<FreezerColorTokens>() ?? FreezerColorTokens.light;
}
