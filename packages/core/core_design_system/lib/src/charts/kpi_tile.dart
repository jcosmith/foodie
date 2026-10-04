import 'package:flutter/material.dart';

import '../theme/foodie_color_tokens.dart';
import '../theme/foodie_spacing.dart';

/// A key figure with its change against the comparison period and a small
/// chart (UI examples document, phone 7: Eaten, Added, Thrown away, Avg.
/// days stored).
class KpiTile extends StatelessWidget {
  const KpiTile({
    required this.label,
    required this.value,
    required this.deltaText,
    this.chart,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;

  /// Such as "▲ 12 % vs before" or "no comparison".
  final String deltaText;
  final Widget? chart;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = context.freezerColors.textMuted;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: onTap != null,
          label: '$label: $value, $deltaText',
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              FoodieSpacing.medium,
              FoodieSpacing.small,
              FoodieSpacing.medium,
              FoodieSpacing.small,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium?.copyWith(color: mutedColor)),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(deltaText, style: theme.textTheme.labelSmall?.copyWith(color: mutedColor)),
                if (chart != null) ...[const SizedBox(height: FoodieSpacing.extraSmall), chart!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
