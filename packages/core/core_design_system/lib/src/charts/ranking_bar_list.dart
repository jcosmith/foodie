import 'package:flutter/material.dart';

import '../theme/freezer_chart_colors.dart';
import '../theme/freezer_color_tokens.dart';
import '../theme/freezer_spacing.dart';

/// One row of a [RankingBarList].
@immutable
final class RankingBarRow {
  const RankingBarRow({
    required this.label,
    required this.value,
    required this.formattedValue,
    this.leading,
    this.isSelected = false,
    this.barColor,
  });

  final String label;
  final double value;
  final String formattedValue;

  /// Shown before the label, such as a product emoji.
  final String? leading;
  final bool isSelected;

  /// Overrides the list's bar colour, such as the urgent colour for a
  /// product that runs out soon.
  final Color? barColor;
}

/// Horizontal bars with a label and value per row, largest first: top
/// products, waste by reason (UI examples document, phone 9).
class RankingBarList extends StatelessWidget {
  const RankingBarList({required this.rows, this.onRowTapped, this.maximumValue, super.key});

  final List<RankingBarRow> rows;
  final ValueChanged<int>? onRowTapped;

  /// The value of a full bar; the largest row's value when not given.
  final double? maximumValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.freezerColors;
    final barColor = context.chartColors.singleSeries;
    final maximum =
        maximumValue ??
        rows.fold<double>(0, (largest, row) => row.value > largest ? row.value : largest);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in rows.indexed)
          Semantics(
            button: onRowTapped != null,
            selected: row.isSelected,
            label: '${row.label}: ${row.formattedValue}',
            excludeSemantics: true,
            child: InkWell(
              onTap: onRowTapped == null ? null : () => onRowTapped!(index),
              borderRadius: BorderRadius.circular(FreezerSpacing.small),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: FreezerSpacing.extraSmall,
                  horizontal: FreezerSpacing.extraSmall,
                ),
                decoration: row.isSelected
                    ? BoxDecoration(
                        color: tokens.primarySoft,
                        borderRadius: BorderRadius.circular(FreezerSpacing.small),
                      )
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        row.leading == null ? row.label : '${row.leading} ${row.label}',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: FreezerSpacing.small),
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                        child: Container(
                          height: 10,
                          color: tokens.surfaceMuted,
                          alignment: AlignmentDirectional.centerStart,
                          child: FractionallySizedBox(
                            widthFactor: maximum <= 0 ? 0 : (row.value / maximum).clamp(0, 1),
                            child: Container(color: row.barColor ?? barColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FreezerSpacing.small),
                    SizedBox(
                      width: 64,
                      child: Text(
                        row.formattedValue,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
