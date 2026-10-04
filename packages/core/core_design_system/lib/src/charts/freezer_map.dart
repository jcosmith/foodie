import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';

import '../theme/foodie_color_tokens.dart';
import '../theme/foodie_spacing.dart';
import '../widgets/storage_age_badge.dart';

/// One drawer of a [FreezerMap].
@immutable
final class FreezerMapDrawer {
  const FreezerMapDrawer({
    required this.label,
    required this.tagColor,
    required this.itemCountLabel,
    required this.itemAgeLevels,
    this.isSelected = false,
  });

  final String label;
  final Color tagColor;

  /// Such as "4 items".
  final String itemCountLabel;

  /// One entry per item, oldest first.
  final List<StorageAgeLevel> itemAgeLevels;
  final bool isSelected;
}

/// The freezer's current contents per drawer, each item a symbol coloured by
/// its age (UI examples document, phone 9: "Where is the old stuff?").
/// The items are drawn with a custom painter (decision D7); every drawer is
/// one tap target.
class FreezerMap extends StatelessWidget {
  const FreezerMap({required this.drawers, this.onDrawerTapped, super.key});

  final List<FreezerMapDrawer> drawers;
  final ValueChanged<int>? onDrawerTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.freezerColors;
    final ageLevelNames = {
      StorageAgeLevel.fresh: context.commonLocalizations.storageAgeFresh,
      StorageAgeLevel.aging: context.commonLocalizations.storageAgeAging,
      StorageAgeLevel.urgent: context.commonLocalizations.storageAgeUrgent,
      StorageAgeLevel.overdue: context.commonLocalizations.storageAgeOverdue,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, drawer) in drawers.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: FoodieSpacing.small),
            child: Semantics(
              button: onDrawerTapped != null,
              selected: drawer.isSelected,
              label: [
                drawer.label,
                drawer.itemCountLabel,
                for (final level in StorageAgeLevel.values)
                  if (drawer.itemAgeLevels.contains(level))
                    '${ageLevelNames[level]}: '
                        '${drawer.itemAgeLevels.where((itemLevel) => itemLevel == level).length}',
              ].join(', '),
              excludeSemantics: true,
              child: Material(
                color: drawer.isSelected ? tokens.primarySoft : tokens.surfaceMuted,
                borderRadius: BorderRadius.circular(FoodieSpacing.tileRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(FoodieSpacing.tileRadius),
                  onTap: onDrawerTapped == null ? null : () => onDrawerTapped!(index),
                  child: Padding(
                    padding: const EdgeInsets.all(FoodieSpacing.small),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text('● ', style: TextStyle(color: drawer.tagColor)),
                            Expanded(child: Text(drawer.label, style: theme.textTheme.bodySmall)),
                            Text(
                              drawer.itemCountLabel,
                              style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: FoodieSpacing.extraSmall),
                        _AgeSymbolRow(levels: drawer.itemAgeLevels, tokens: tokens),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        Wrap(
          spacing: FoodieSpacing.small,
          runSpacing: FoodieSpacing.extraSmall,
          children: [for (final level in StorageAgeLevel.values) StorageAgeBadge(level: level)],
        ),
      ],
    );
  }
}

class _AgeSymbolRow extends StatelessWidget {
  const _AgeSymbolRow({required this.levels, required this.tokens});

  final List<StorageAgeLevel> levels;
  final FoodieColorTokens tokens;

  static const double _symbolSize = 16;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final perRow = (constraints.maxWidth / _symbolSize).floor().clamp(1, 1000);
      final rowCount = levels.isEmpty ? 1 : (levels.length / perRow).ceil();
      return CustomPaint(
        size: Size(constraints.maxWidth, rowCount * _symbolSize),
        painter: _AgeSymbolPainter(
          levels: levels,
          perRow: perRow,
          symbolSize: _symbolSize,
          colors: {
            StorageAgeLevel.fresh: tokens.statusFresh,
            StorageAgeLevel.aging: tokens.statusAging,
            StorageAgeLevel.urgent: tokens.statusUrgent,
            StorageAgeLevel.overdue: tokens.statusUrgent,
          },
          textDirection: Directionality.of(context),
        ),
      );
    },
  );
}

class _AgeSymbolPainter extends CustomPainter {
  _AgeSymbolPainter({
    required this.levels,
    required this.perRow,
    required this.symbolSize,
    required this.colors,
    required this.textDirection,
  });

  final List<StorageAgeLevel> levels;
  final int perRow;
  final double symbolSize;
  final Map<StorageAgeLevel, Color> colors;
  final TextDirection textDirection;

  static const Map<StorageAgeLevel, String> _symbols = {
    StorageAgeLevel.fresh: '●',
    StorageAgeLevel.aging: '◐',
    StorageAgeLevel.urgent: '▲',
    StorageAgeLevel.overdue: '✕',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final painters = {
      for (final level in StorageAgeLevel.values)
        level: TextPainter(
          text: TextSpan(
            text: _symbols[level],
            style: TextStyle(color: colors[level], fontSize: symbolSize * 0.75, height: 1),
          ),
          textDirection: textDirection,
        )..layout(),
    };
    for (final (index, level) in levels.indexed) {
      final column = index % perRow;
      final row = index ~/ perRow;
      final x = textDirection == TextDirection.rtl
          ? size.width - (column + 1) * symbolSize
          : column * symbolSize;
      painters[level]!.paint(canvas, Offset(x + 2, row * symbolSize + 2));
    }
    for (final painter in painters.values) {
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(_AgeSymbolPainter oldDelegate) =>
      oldDelegate.levels != levels || oldDelegate.perRow != perRow || oldDelegate.colors != colors;
}
