import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/receipt_review.dart';
import '../application/receipt_scanning_providers.dart';
import '../domain/receipt_line_matcher.dart';
import '../l10n/generated/receipt_scanning_localizations.dart';
import 'receipt_line_sheet.dart';
import 'receipt_scan_screen.dart';
import 'receipt_texts.dart';

/// The review list (architecture 10.10, step 5; UI examples, phone 14):
/// what needs the user on top, then the recognised lines, ticked, then what
/// is not added. Nothing is added before the button at the bottom.
class ReceiptReviewList extends ConsumerWidget {
  const ReceiptReviewList({
    required this.draft,
    required this.onChanged,
    required this.onConfirm,
    super.key,
  });

  final ReceiptReviewDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onConfirm;

  /// Picks a product for [line]; asks for amount and place when they cannot
  /// be suggested.
  Future<void> _pickProduct(BuildContext context, WidgetRef ref, ReceiptReviewLine line) async {
    final productIdentifier = await showProductPickerSheet(context);
    if (productIdentifier == null || !context.mounted) return;
    final product = await ref
        .read(productCatalogQueryServiceProvider)
        .readProduct(productIdentifier);
    if (product == null || !context.mounted) return;
    final suggested = await ref
        .read(prepareReceiptReviewUseCaseProvider)
        .withProduct(line, product);
    if (!context.mounted) return;
    draft.replace(suggested);
    onChanged();
    if (!suggested.canAddAsSuggested) await _editDetails(context, suggested);
  }

  Future<void> _editDetails(BuildContext context, ReceiptReviewLine line) async {
    final product = line.product;
    if (product == null) return;
    final details = await showReceiptLineSheet(
      context,
      product: product,
      quantity: line.quantity,
      compartment: line.compartment,
    );
    if (details == null) return;
    final (quantity, compartment) = details;
    draft.replace(line.copyWith(quantity: quantity, compartment: compartment));
    onChanged();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final review = draft.review;
    final flagged = draft.flaggedLines;
    final recognised = draft.recognisedLines;
    final notAdded = draft.notAddedLines;
    final layout = ref.watch(storageLayoutProvider).value;
    final textTheme = Theme.of(context).textTheme;
    final summary = [
      review.storeName ?? localizations.unknownStore,
      if (review.purchasedOn case final purchasedOn?)
        context.dateDisplayFormatter.formatMediumDate(purchasedOn),
      if (review.totalInCents case final total?) formatCents(context, total),
    ].join(' · ');
    final ticked = draft.tickedCount;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
            children: [
              Text(summary, style: textTheme.titleMedium),
              if (review.lines.isEmpty) ...[
                const SizedBox(height: FoodieSpacing.large),
                Text(localizations.noItemsFound),
              ],
              if (flagged.isNotEmpty) ...[
                _SectionTitle(localizations.needsYou(flagged.length)),
                for (final line in flagged)
                  _FlaggedLineCard(
                    line: line,
                    canRememberForStore: review.storeName != null,
                    onConfirm: () {
                      draft.replace(line.copyWith(status: ReceiptLineStatus.matched));
                      onChanged();
                    },
                    onPickProduct: () => _pickProduct(context, ref, line),
                    onIgnore: ({required remember}) {
                      draft.ignore(line, remember: remember);
                      onChanged();
                    },
                  ),
              ],
              if (recognised.isNotEmpty) ...[
                _SectionTitle(localizations.recognisedSection(recognised.length)),
                for (final line in recognised)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: draft.isTicked(line),
                    onChanged: line.canAddAsSuggested
                        ? (ticked) {
                            draft.setTicked(line, ticked: ticked ?? false);
                            onChanged();
                          }
                        : null,
                    title: Text(describeSuggestion(context, line)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.lineWithPrice(
                            line.text,
                            formatCents(context, line.lineTotalInCents),
                          ),
                          style: receiptTextStyle(context).copyWith(fontSize: 12),
                        ),
                        Text(switch ((line.compartment, layout)) {
                          (final compartment?, final layout?) when line.quantity != null =>
                            context
                                .compartmentDisplayNameResolver(layout)
                                .compartmentNameWithStoragePlace(compartment),
                          _ => localizations.setAmountAndPlace,
                        }),
                      ],
                    ),
                    secondary: IconButton(
                      tooltip: localizations.editLineTitle,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editDetails(context, line),
                    ),
                  ),
              ],
              if (notAdded.isNotEmpty) ...[
                _SectionTitle(localizations.notAddedSection(notAdded.length)),
                for (final line in notAdded)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.remove_circle_outline),
                    title: Text(line.text, style: receiptTextStyle(context)),
                    subtitle: Text(formatCents(context, line.lineTotalInCents)),
                    trailing: draft.isIgnoredByUser(line)
                        ? TextButton(
                            onPressed: () {
                              draft.undoIgnore(line);
                              onChanged();
                            },
                            child: Text(context.commonLocalizations.actionUndo),
                          )
                        : null,
                  ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onConfirm,
                child: Text(
                  ticked == 0 ? localizations.keepReceipt : localizations.addItems(ticked),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: FoodieSpacing.extraLarge, bottom: FoodieSpacing.small),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// A line the app does not know, or only guesses: flagged and explained.
class _FlaggedLineCard extends StatelessWidget {
  const _FlaggedLineCard({
    required this.line,
    required this.canRememberForStore,
    required this.onConfirm,
    required this.onPickProduct,
    required this.onIgnore,
  });

  final ReceiptReviewLine line;

  /// Only with a store name can an ignored line be remembered.
  final bool canRememberForStore;
  final VoidCallback onConfirm;
  final VoidCallback onPickProduct;
  final void Function({required bool remember}) onIgnore;

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final colors = context.foodieColors;
    final product = line.product;
    final isSuggestion = line.status == ReceiptLineStatus.suggested && product != null;
    return Card(
      elevation: 0,
      color: colors.statusAgingSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FoodieSpacing.tileRadius),
        side: BorderSide(color: colors.statusAging),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FoodieSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(line.text, style: receiptTextStyle(context))),
                Text(formatCents(context, line.lineTotalInCents), style: receiptTextStyle(context)),
              ],
            ),
            const SizedBox(height: FoodieSpacing.extraSmall),
            Text(
              isSuggestion
                  ? localizations.suggestedProduct(
                      context.productDisplayNameResolver.productName(product),
                    )
                  : localizations.unknownLine,
            ),
            const SizedBox(height: FoodieSpacing.small),
            Wrap(
              spacing: FoodieSpacing.small,
              runSpacing: FoodieSpacing.extraSmall,
              children: [
                if (isSuggestion)
                  FilledButton(onPressed: onConfirm, child: Text(localizations.confirmSuggestion)),
                OutlinedButton(onPressed: onPickProduct, child: Text(localizations.pickProduct)),
                TextButton(
                  onPressed: () => onIgnore(remember: false),
                  child: Text(localizations.ignoreLine),
                ),
                if (canRememberForStore)
                  TextButton(
                    onPressed: () => onIgnore(remember: true),
                    child: Text(localizations.ignoreAtStore),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Minced meat · 500 g", or the receipt text without a product.
String describeSuggestion(BuildContext context, ReceiptReviewLine line) {
  final product = line.product;
  if (product == null) return line.text;
  final name = context.productDisplayNameResolver.productName(product);
  final quantity = line.quantity;
  return quantity == null ? name : '$name · ${context.quantityFormatter.format(quantity)}';
}
