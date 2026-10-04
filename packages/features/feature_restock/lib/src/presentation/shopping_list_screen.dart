import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/restock_providers.dart';
import '../domain/shopping_list_entry.dart';
import '../l10n/generated/restock_localizations.dart';
import 'restock_texts.dart';

/// The "List" tab (UI example phone 6): running-low products and what the
/// user added; ticked items go into the freezer in one step.
class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = RestockLocalizations.of(context);
    final entries = ref.watch(shoppingListEntriesProvider).value;
    final catalog = ref.watch(productCatalogProvider).value;
    final tickedCount = entries?.where((entry) => entry.isChecked).length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.shoppingListTitle),
            Text(localizations.shoppingListSubtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addProduct(context, ref),
        icon: const Icon(Icons.add),
        label: Text(localizations.addToListButton),
      ),
      body: switch ((entries, catalog)) {
        (null, _) || (_, null) => const Center(child: CircularProgressIndicator()),
        (final entries?, _) when entries.isEmpty => EmptyStateView(
          icon: Icons.checklist,
          title: localizations.emptyListTitle,
          message: localizations.emptyListMessage,
        ),
        (final entries?, final catalog?) => ListView(
          padding: const EdgeInsets.only(bottom: 160),
          children: [
            for (final entry in entries) _ShoppingListEntryTile(entry: entry, catalog: catalog),
            Padding(
              padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
              child: FilledButton.icon(
                onPressed: tickedCount == 0 ? null : () => _putTickedItemsInFreezer(context, ref),
                icon: const Icon(Icons.kitchen_outlined),
                label: Text(
                  tickedCount == 0
                      ? localizations.nothingTicked
                      : localizations.putTickedInFreezer(tickedCount),
                ),
              ),
            ),
          ],
        ),
      },
    );
  }

  Future<void> _addProduct(BuildContext context, WidgetRef ref) async {
    final productIdentifier = await showProductPickerSheet(context);
    if (productIdentifier == null) return;
    await ref.read(addProductToShoppingListUseCaseProvider).execute(productIdentifier);
  }

  Future<void> _putTickedItemsInFreezer(BuildContext context, WidgetRef ref) async {
    final localizations = RestockLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(putTickedItemsInFreezerUseCaseProvider).execute();
    final message = switch (result) {
      SuccessfulResult(value: final addedBatchCount) => localizations.itemsPutInFreezer(
        addedBatchCount,
      ),
      FailedResult(:final failure) => localizations.describeFailure(failure),
    };
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ShoppingListEntryTile extends ConsumerWidget {
  const _ShoppingListEntryTile({required this.entry, required this.catalog});

  final ShoppingListEntry entry;
  final ProductCatalog catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = RestockLocalizations.of(context);
    final product = switch (entry.productIdentifier) {
      final productIdentifier? => catalog.productOf(productIdentifier),
      null => null,
    };
    final name = product == null
        ? entry.freeTextName ?? ''
        : context.productDisplayNameResolver.productName(product);
    final origin = entry.isAutomatic ? localizations.originRestock : localizations.originManual;
    final detail = switch (entry.requestedQuantity) {
      final quantity? => '${context.quantityFormatter.format(quantity)} · $origin',
      null => origin,
    };
    final textTheme = Theme.of(context).textTheme;

    final tile = CheckboxListTile(
      value: entry.isChecked,
      onChanged: (isChecked) => ref
          .read(tickShoppingListEntryUseCaseProvider)
          .execute(entry.identifier, isChecked: isChecked ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      secondary: product == null
          ? const Icon(Icons.shopping_basket_outlined)
          : ProductIcon.ofProduct(product, catalog, size: 28),
      title: Text(
        name,
        style: entry.isChecked
            ? textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
      ),
      subtitle: Text(detail),
    );
    if (entry.isAutomatic && !entry.isChecked) return tile;
    return Dismissible(
      key: ValueKey(entry.identifier.value),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: FoodieSpacing.screenGutter),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      onDismissed: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(removeShoppingListEntryUseCaseProvider).execute(entry.identifier);
        messenger.showSnackBar(SnackBar(content: Text(localizations.entryRemoved)));
      },
      child: tile,
    );
  }
}
