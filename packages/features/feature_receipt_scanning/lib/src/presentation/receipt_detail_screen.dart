import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/receipt_review.dart';
import '../application/receipt_scanning_providers.dart';
import '../domain/receipt.dart';
import '../domain/receipt_parser.dart';
import '../domain/receipt_scanning_failure.dart';
import '../l10n/generated/receipt_scanning_localizations.dart';
import 'receipt_line_sheet.dart';
import 'receipt_texts.dart';

/// An archived receipt: its pages, its lines and what they added. Lines left
/// open can be added or ignored here, later.
class ReceiptDetailScreen extends ConsumerWidget {
  const ReceiptDetailScreen({required this.receiptIdentifier, this.highlightedLine, super.key});

  final ReceiptIdentifier receiptIdentifier;
  final ReceiptLineIdentifier? highlightedLine;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final localizations = ReceiptScanningLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(localizations.deleteReceiptQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.commonLocalizations.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref.read(deleteReceiptUseCaseProvider).execute(receiptIdentifier);
    messenger.showSnackBar(SnackBar(content: Text(localizations.receiptDeleted)));
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final receiptValue = ref.watch(receiptProvider(receiptIdentifier));
    final receipt = receiptValue.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(receipt?.storeName ?? localizations.segmentTitle),
        actions: [
          if (receipt != null)
            IconButton(
              tooltip: localizations.deleteReceipt,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref),
            ),
        ],
      ),
      body: switch (receiptValue) {
        AsyncData(value: final receipt?) => _ReceiptBody(
          receipt: receipt,
          highlightedLine: highlightedLine,
        ),
        AsyncData() => Center(child: Text(localizations.receiptGone)),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ReceiptBody extends ConsumerWidget {
  const _ReceiptBody({required this.receipt, required this.highlightedLine});

  final Receipt receipt;
  final ReceiptLineIdentifier? highlightedLine;

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    ReceiptLineDecision decision,
    ReceiptLine line,
  ) async {
    final localizations = ReceiptScanningLocalizations.of(context);
    final inventoryLocalizations = InventoryLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(resolveReceiptLineUseCaseProvider)
        .execute(line.identifier, decision);
    if (!context.mounted) return;
    ref.invalidate(receiptProvider(receipt.identifier));
    if (result case FailedResult(:final failure)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (failure) {
            final ReceiptScanningFailure failure => localizations.describeFailure(failure),
            final InventoryFailure failure => inventoryLocalizations.describeFailure(failure),
            _ => failure.debugDescription,
          }),
        ),
      );
    }
  }

  /// Lets the user fix a misread line; the correction is indexed instead.
  Future<void> _correct(BuildContext context, WidgetRef ref, ReceiptLine line) async {
    final corrected = await showDialog<String>(
      context: context,
      builder: (context) => _CorrectTextDialog(line: line),
    );
    if (corrected == null || !context.mounted) return;
    await ref.read(correctReceiptLineTextUseCaseProvider).execute(line.identifier, corrected);
    if (context.mounted) ref.invalidate(receiptProvider(receipt.identifier));
  }

  /// Adds the line with what the app would suggest for [product], asking for
  /// amount and place only when it cannot suggest them.
  Future<void> _add(BuildContext context, WidgetRef ref, ReceiptLine line, Product product) async {
    var suggestion = await ref
        .read(prepareReceiptReviewUseCaseProvider)
        .withProduct(ReceiptReviewLine(parsed: line.parsed, status: line.status), product);
    if (!context.mounted) return;
    if (!suggestion.canAddAsSuggested) {
      final details = await showReceiptLineSheet(
        context,
        product: product,
        quantity: suggestion.quantity,
        compartment: suggestion.compartment,
      );
      if (details == null || !context.mounted) return;
      suggestion = suggestion.copyWith(quantity: details.$1, compartment: details.$2);
    }
    await _resolve(context, ref, AddReceiptLine.suggested(suggestion), line);
  }

  Future<void> _pickAndAdd(BuildContext context, WidgetRef ref, ReceiptLine line) async {
    final productIdentifier = await showProductPickerSheet(context);
    if (productIdentifier == null || !context.mounted) return;
    final product = await ref
        .read(productCatalogQueryServiceProvider)
        .readProduct(productIdentifier);
    if (product == null || !context.mounted) return;
    await _add(context, ref, line, product);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = context.foodieColors;
    final catalog = ref.watch(productCatalogProvider).value;
    final names = context.productDisplayNameResolver;
    final openLines = receipt.openLines;
    final summary = [
      if (receipt.purchasedOn case final purchasedOn?)
        context.dateDisplayFormatter.formatMediumDate(purchasedOn),
      if (receipt.totalInCents case final total?)
        localizations.totalAmount(formatCents(context, total)),
    ].join(' · ');
    final pictures = receipt.pages.map((page) => page.pictureReference).nonNulls.toList();
    final otherLines = [
      for (final line in receipt.lines)
        if (!line.isOpen) line,
    ];
    return ListView(
      padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
      children: [
        if (summary.isNotEmpty) Text(summary, style: textTheme.titleMedium),
        const SizedBox(height: FoodieSpacing.extraSmall),
        Text(
          localizations.openLines(openLines.length),
          style: textTheme.bodyMedium?.copyWith(
            color: openLines.isEmpty ? colors.textMuted : colors.statusAging,
          ),
        ),
        if (pictures.isNotEmpty) ...[
          const SizedBox(height: FoodieSpacing.large),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pictures.length,
              separatorBuilder: (context, index) => const SizedBox(width: FoodieSpacing.small),
              itemBuilder: (context, index) =>
                  _PageImage(reference: pictures[index], number: index + 1),
            ),
          ),
        ],
        for (final line in openLines) ...[
          const SizedBox(height: FoodieSpacing.small),
          _OpenLineCard(
            line: line,
            product: switch (line.productIdentifier) {
              final identifier? => catalog?.productOf(identifier),
              null => null,
            },
            isHighlighted: line.identifier == highlightedLine,
            onAdd: (product) => _add(context, ref, line, product),
            onPickProduct: () => _pickAndAdd(context, ref, line),
            onIgnore: () => _resolve(context, ref, const IgnoreReceiptLine(), line),
            onCorrect: () => _correct(context, ref, line),
          ),
        ],
        const SizedBox(height: FoodieSpacing.large),
        for (final line in otherLines)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.small),
            tileColor: line.identifier == highlightedLine ? colors.primarySoft : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FoodieSpacing.tileRadius),
            ),
            leading: Icon(
              line.stockBatchIdentifier != null ? Icons.check_circle : Icons.remove_circle_outline,
              color: line.stockBatchIdentifier != null ? colors.statusFresh : colors.textMuted,
            ),
            onTap: () => _correct(context, ref, line),
            title: Text(line.text, style: receiptTextStyle(context)),
            subtitle: Text(switch ((line.stockBatchIdentifier, line.productIdentifier)) {
              (_?, final productIdentifier?) => switch (catalog?.productOf(productIdentifier)) {
                final product? => '${localizations.lineAdded} · ${names.productName(product)}',
                null => localizations.lineAdded,
              },
              _ => line.kind == ReceiptLineKind.item ? localizations.lineNotAdded : '',
            }),
            trailing: Text(formatCents(context, line.lineTotalInCents)),
          ),
      ],
    );
  }
}

class _OpenLineCard extends StatelessWidget {
  const _OpenLineCard({
    required this.line,
    required this.product,
    required this.isHighlighted,
    required this.onAdd,
    required this.onPickProduct,
    required this.onIgnore,
    required this.onCorrect,
  });

  final ReceiptLine line;

  /// The product it was matched or likely matched to, if any.
  final Product? product;
  final bool isHighlighted;
  final ValueChanged<Product> onAdd;
  final VoidCallback onPickProduct;
  final VoidCallback onIgnore;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final colors = context.foodieColors;
    final product = this.product;
    return Card(
      elevation: 0,
      color: colors.statusAgingSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FoodieSpacing.tileRadius),
        side: BorderSide(
          color: isHighlighted ? Theme.of(context).colorScheme.primary : colors.statusAging,
          width: isHighlighted ? 2 : 1,
        ),
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
                IconButton(
                  tooltip: localizations.correctText,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onCorrect,
                ),
              ],
            ),
            const SizedBox(height: FoodieSpacing.extraSmall),
            Text(
              product == null
                  ? localizations.unknownLine
                  : localizations.suggestedProduct(
                      context.productDisplayNameResolver.productName(product),
                    ),
            ),
            const SizedBox(height: FoodieSpacing.small),
            Wrap(
              spacing: FoodieSpacing.small,
              runSpacing: FoodieSpacing.extraSmall,
              children: [
                if (product != null)
                  FilledButton(
                    onPressed: () => onAdd(product),
                    child: Text(context.commonLocalizations.actionAdd),
                  ),
                OutlinedButton(onPressed: onPickProduct, child: Text(localizations.pickProduct)),
                TextButton(onPressed: onIgnore, child: Text(localizations.ignoreLine)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A page image, decrypted only now that the receipt is open; a tap shows
/// it full screen to zoom in.
class _PageImage extends ConsumerWidget {
  const _PageImage({required this.reference, required this.number});

  final String reference;
  final int number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = ReceiptScanningLocalizations.of(context).pageImageLabel(number);
    return switch (ref.watch(receiptPageImageProvider(reference))) {
      AsyncData(value: final bytes) => Semantics(
        label: label,
        button: true,
        child: GestureDetector(
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => Dialog.fullscreen(
              child: Stack(
                children: [
                  InteractiveViewer(maxScale: 6, child: Center(child: Image.memory(bytes))),
                  Positioned(
                    top: FoodieSpacing.small,
                    right: FoodieSpacing.small,
                    child: SafeArea(
                      child: IconButton.filledTonal(
                        tooltip: context.commonLocalizations.actionClose,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FoodieSpacing.tileRadius),
            child: Image.memory(bytes, height: 160, fit: BoxFit.cover, semanticLabel: label),
          ),
        ),
      ),
      AsyncError() => const SizedBox(width: 100, child: Icon(Icons.broken_image_outlined)),
      _ => const SizedBox(width: 100, child: Center(child: CircularProgressIndicator())),
    };
  }
}

/// Asks for the line as printed; returns `null` when cancelled.
class _CorrectTextDialog extends StatefulWidget {
  const _CorrectTextDialog({required this.line});

  final ReceiptLine line;

  @override
  State<_CorrectTextDialog> createState() => _CorrectTextDialogState();
}

class _CorrectTextDialogState extends State<_CorrectTextDialog> {
  late final TextEditingController _text = TextEditingController(text: widget.line.text);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    return AlertDialog(
      title: Text(localizations.correctText),
      content: TextField(
        controller: _text,
        autofocus: true,
        decoration: InputDecoration(
          hintText: localizations.correctTextHint,
          helperText: localizations.recognisedAs(widget.line.recognizedText),
        ),
        onSubmitted: (text) => Navigator.of(context).pop(text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.commonLocalizations.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_text.text),
          child: Text(context.commonLocalizations.actionSave),
        ),
      ],
    );
  }
}
