import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/inventory_overview.dart';
import '../l10n/generated/inventory_localizations.dart';
import 'inventory_texts.dart';

/// A batch in a list (UI example phone 2): picture or icon, name, age badge
/// with "frozen 3 months ago", the amount left and a thin bar of how much of
/// the package is left.
class StockItemTile extends StatelessWidget {
  const StockItemTile({required this.item, required this.today, this.onTap, super.key});

  final InventoryItem item;
  final CalendarDate today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = InventoryLocalizations.of(context);
    final quantityFormatter = context.quantityFormatter;
    final textTheme = Theme.of(context).textTheme;
    final batch = item.batch;
    final remainingPercent = (batch.remainingShare * 100).round();
    return ListTile(
      onTap: onTap,
      leading: StockItemVisual(item: item),
      title: Text(context.productDisplayNameResolver.productName(item.product)),
      subtitle: Wrap(
        spacing: FoodieSpacing.small,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          StorageAgeBadge(
            level: item.useByStatus.level,
            label: localizations.useByBadgeLabel(item, today),
          ),
          Text(switch (batch.openedOn) {
            final openedOn? => localizations.openedAgo(
              context.storageAgeFormatter.formatRelativeAge(since: openedOn, today: today),
            ),
            null => localizations.frozenAgo(
              context.storageAgeFormatter.formatRelativeAge(since: batch.storedOn, today: today),
            ),
          }),
        ],
      ),
      trailing: Semantics(
        label: localizations.remainingShare(remainingPercent),
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                quantityFormatter.format(batch.quantityRemaining),
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: FoodieSpacing.extraSmall),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: batch.remainingShare,
                  minHeight: 4,
                  backgroundColor: context.foodieColors.border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The picture of a batch from an enabled item visual provider (item
/// pictures), falling back to the product's emoji.
class StockItemVisual extends ConsumerWidget {
  const StockItemVisual({required this.item, this.size = 40, super.key});

  final InventoryItem item;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = ProductIcon(emoji: item.iconEmoji, image: item.product.iconImage, size: size);
    final itemVisualProvider = ref.watch(enabledItemVisualProvider);
    if (itemVisualProvider == null) return fallback;
    return itemVisualProvider.buildItemVisual(
      context,
      StockBatchItemVisualSubject(
        stockBatchIdentifier: item.batch.identifier.value,
        productIdentifier: item.product.identifier.value,
      ),
      size: size,
      fallback: fallback,
    );
  }
}
