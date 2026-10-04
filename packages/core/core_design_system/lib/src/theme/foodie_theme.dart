import 'package:flutter/material.dart';

import 'foodie_chart_colors.dart';
import 'foodie_color_tokens.dart';
import 'foodie_spacing.dart';

/// The light and dark themes of the app, built from the colour tokens of the
/// UI examples document. Text size follows the system setting.
abstract final class FoodieTheme {
  static ThemeData light() => _buildTheme(
    brightness: Brightness.light,
    tokens: FoodieColorTokens.light,
    chartColors: FoodieChartColors.light,
    primary: const Color(0xFF1769C2),
    onPrimary: const Color(0xFFFFFFFF),
    background: const Color(0xFFF6F8FB),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF17202E),
  );

  static ThemeData dark() => _buildTheme(
    brightness: Brightness.dark,
    tokens: FoodieColorTokens.dark,
    chartColors: FoodieChartColors.dark,
    primary: const Color(0xFF7DB3F0),
    onPrimary: const Color(0xFF0B1422),
    background: const Color(0xFF10151D),
    surface: const Color(0xFF19202B),
    onSurface: const Color(0xFFE6EBF2),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required FoodieColorTokens tokens,
    required FoodieChartColors chartColors,
    required Color primary,
    required Color onPrimary,
    required Color background,
    required Color surface,
    required Color onSurface,
  }) {
    final colorScheme = ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: tokens.primarySoft,
      onPrimaryContainer: primary,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: tokens.textMuted,
      surfaceContainerHighest: tokens.surfaceMuted,
      outline: tokens.border,
      outlineVariant: tokens.border,
      error: tokens.statusUrgent,
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FoodieSpacing.cardRadius),
      side: BorderSide(color: tokens.border),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      extensions: [tokens, chartColors],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsetsDirectional.only(bottom: FoodieSpacing.medium),
        shape: cardShape,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: tokens.primarySoft,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
            color: states.contains(WidgetState.selected) ? onSurface : tokens.textMuted,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: StadiumBorder(side: BorderSide(color: tokens.border)),
        selectedColor: tokens.primarySoft,
        backgroundColor: surface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: BorderSide(color: tokens.border),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(FoodieSpacing.sheetRadius)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme: DividerThemeData(color: tokens.border, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FoodieSpacing.tileRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
