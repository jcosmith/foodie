import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_reminders_providers.dart';
import '../l10n/generated/storage_reminders_localizations.dart';
import '../storage_reminders_routes.dart';

/// "Use soon" on Home (UI example phone 1): the three most urgent items.
class EatSoonCard extends ConsumerWidget {
  const EatSoonCard({super.key});

  static const int shownItemCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = StorageRemindersLocalizations.of(context);
    final eatSoonItems = ref.watch(eatSoonItemsProvider) ?? const [];
    final today = ref.watch(inventoryOverviewProvider).value?.today;
    return SectionCard(
      title: localizations.eatSoonTitle,
      trailingActionLabel: eatSoonItems.length > shownItemCount
          ? context.commonLocalizations.actionSeeAll
          : null,
      onTrailingActionPressed: () => context.push(StorageRemindersRoutes.eatSoon),
      child: eatSoonItems.isEmpty || today == null
          ? Text(localizations.eatSoonEmpty)
          : Column(
              children: [
                for (final item in eatSoonItems.take(shownItemCount))
                  StockItemTile(
                    item: item,
                    today: today,
                    onTap: () => showTakeStockSheet(context, item),
                  ),
              ],
            ),
    );
  }
}

/// Everything that should be used soon; the digest notification opens it.
class EatSoonScreen extends ConsumerWidget {
  const EatSoonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = StorageRemindersLocalizations.of(context);
    final eatSoonItems = ref.watch(eatSoonItemsProvider);
    final today = ref.watch(inventoryOverviewProvider).value?.today;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.eatSoonTitle)),
      body: switch ((eatSoonItems, today)) {
        (null, _) || (_, null) => const Center(child: CircularProgressIndicator()),
        (final items?, _) when items.isEmpty => EmptyStateView(
          icon: Icons.check_circle_outline,
          title: localizations.eatSoonScreenEmptyTitle,
          message: localizations.eatSoonScreenEmptyMessage,
        ),
        (final items?, final today?) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FoodieSpacing.screenGutter,
                FoodieSpacing.small,
                FoodieSpacing.screenGutter,
                FoodieSpacing.small,
              ),
              child: Text(
                localizations.eatSoonScreenExplanation,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            for (final item in items)
              StockItemTile(
                item: item,
                today: today,
                onTap: () => showTakeStockSheet(context, item),
              ),
          ],
        ),
      },
    );
  }
}
