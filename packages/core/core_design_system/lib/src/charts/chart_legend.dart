import 'package:flutter/material.dart';

import '../theme/freezer_spacing.dart';

/// One entry of a [ChartLegend].
@immutable
final class ChartLegendEntry {
  const ChartLegendEntry({required this.label, required this.color, this.isDimmed = false});

  final String label;
  final Color color;

  /// Shown faded and struck through, for a series the filter leaves out.
  final bool isDimmed;
}

/// Colour swatches with labels below a chart; tappable when [onEntryTapped] is set.
class ChartLegend extends StatelessWidget {
  const ChartLegend({required this.entries, this.onEntryTapped, super.key});

  final List<ChartLegendEntry> entries;
  final ValueChanged<int>? onEntryTapped;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(top: FreezerSpacing.small),
      child: Wrap(
        spacing: FreezerSpacing.medium,
        runSpacing: FreezerSpacing.extraSmall,
        children: [
          for (final (index, entry) in entries.indexed)
            _LegendItem(
              entry: entry,
              textStyle: textStyle,
              onTap: onEntryTapped == null ? null : () => onEntryTapped!(index),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.entry, required this.textStyle, required this.onTap});

  final ChartLegendEntry entry;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Opacity(
      opacity: entry.isDimmed ? 0.4 : 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChartColorSwatch(color: entry.color),
          const SizedBox(width: FreezerSpacing.extraSmall),
          Text(
            entry.label,
            style: entry.isDimmed
                ? textStyle?.copyWith(decoration: TextDecoration.lineThrough)
                : textStyle,
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      selected: !entry.isDimmed,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FreezerSpacing.extraSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: FreezerSpacing.extraSmall),
          child: content,
        ),
      ),
    );
  }
}

/// The small rounded colour square of legends and filter chips.
class ChartColorSwatch extends StatelessWidget {
  const ChartColorSwatch({required this.color, this.size = 10, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size / 4)),
  );
}
