import 'package:flutter/material.dart';

import '../theme/foodie_spacing.dart';

/// A card with a title row and an optional trailing action, such as the
/// "Use soon · See all" card on the home dashboard.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.child,
    this.trailingActionLabel,
    this.onTrailingActionPressed,
    super.key,
  });

  final String title;
  final Widget child;
  final String? trailingActionLabel;
  final VoidCallback? onTrailingActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          FoodieSpacing.large,
          FoodieSpacing.medium,
          FoodieSpacing.large,
          FoodieSpacing.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (trailingActionLabel != null)
                  TextButton(
                    onPressed: onTrailingActionPressed,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.small),
                    ),
                    child: Text(trailingActionLabel!),
                  ),
              ],
            ),
            const SizedBox(height: FoodieSpacing.small),
            child,
          ],
        ),
      ),
    );
  }
}
