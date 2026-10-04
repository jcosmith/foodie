import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/barcode_scanning_providers.dart';
import '../application/barcode_use_cases.dart';
import '../domain/barcode_normalization.dart';
import '../l10n/generated/barcode_scanning_localizations.dart';

/// Asks which product a code belongs to (search, or create a new one) and
/// learns it.
Future<void> _chooseProductAndLearn(
  BuildContext context,
  WidgetRef ref, {
  required NormalizedBarcode barcode,
  required ValueChanged<RecognizedBarcode> onLearned,
}) async {
  final productIdentifier = await showProductPickerSheet(context);
  if (productIdentifier == null || !context.mounted) return;
  final result = await ref
      .read(learnBarcodeUseCaseProvider)
      .execute(barcode: barcode, productIdentifier: productIdentifier);
  if (!context.mounted) return;
  switch (result) {
    case SuccessfulResult(value: final recognizedBarcode):
      onLearned(recognizedBarcode);
    case FailedResult():
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(BarcodeScanningLocalizations.of(context).productUnavailable)),
      );
  }
}

/// "New code … Which product is this?"
class UnknownCodePanel extends ConsumerWidget {
  const UnknownCodePanel({
    required this.unrecognizedBarcode,
    required this.onLearned,
    required this.onScanNext,
    super.key,
  });

  final UnrecognizedBarcode unrecognizedBarcode;
  final ValueChanged<RecognizedBarcode> onLearned;
  final VoidCallback onScanNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = BarcodeScanningLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(localizations.unknownCode(unrecognizedBarcode.barcode.scannedValue)),
        const SizedBox(height: FoodieSpacing.medium),
        FilledButton.icon(
          onPressed: () => _chooseProductAndLearn(
            context,
            ref,
            barcode: unrecognizedBarcode.barcode,
            onLearned: onLearned,
          ),
          icon: const Icon(Icons.search),
          label: Text(localizations.chooseProduct),
        ),
        TextButton(onPressed: onScanNext, child: Text(localizations.scanNext)),
      ],
    );
  }
}

/// The recognised product, with a note when its code was just learned.
class _RecognizedProductHeader extends ConsumerWidget {
  const _RecognizedProductHeader({
    required this.recognizedBarcode,
    required this.isCodeJustLearned,
    required this.detail,
  });

  final RecognizedBarcode recognizedBarcode;
  final bool isCodeJustLearned;
  final String? detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = BarcodeScanningLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final catalog = ref.watch(productCatalogProvider).value;
    final product = recognizedBarcode.product;
    final detail = this.detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCodeJustLearned) ...[
          Text(localizations.learnedCode, style: textTheme.bodySmall),
          const SizedBox(height: FoodieSpacing.small),
        ],
        Row(
          children: [
            if (catalog != null) ...[
              ProductVisual(product: product, catalog: catalog),
              const SizedBox(width: FoodieSpacing.medium),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.productDisplayNameResolver.productName(product),
                    style: textTheme.titleMedium,
                  ),
                  if (detail != null) Text(detail, style: textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WrongProductButton extends ConsumerWidget {
  const _WrongProductButton({required this.recognizedBarcode, required this.onLearned});

  final RecognizedBarcode recognizedBarcode;
  final ValueChanged<RecognizedBarcode> onLearned;

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton(
    onPressed: () => _chooseProductAndLearn(
      context,
      ref,
      barcode: recognizedBarcode.barcode,
      onLearned: onLearned,
    ),
    child: Text(BarcodeScanningLocalizations.of(context).wrongProduct),
  );
}

/// Scan to add (section 10.3): one tap puts the package size, or the weight
/// in a weighed-goods code, into the compartment used last time; "Change
/// details" opens the add form pre-filled instead.
class ScanToAddPanel extends ConsumerStatefulWidget {
  const ScanToAddPanel({
    required this.recognizedBarcode,
    required this.isCodeJustLearned,
    required this.onLearned,
    required this.onDone,
    super.key,
  });

  final RecognizedBarcode recognizedBarcode;
  final bool isCodeJustLearned;
  final ValueChanged<RecognizedBarcode> onLearned;
  final VoidCallback onDone;

  @override
  ConsumerState<ScanToAddPanel> createState() => _ScanToAddPanelState();
}

class _ScanToAddPanelState extends ConsumerState<ScanToAddPanel> {
  late final Future<ScanToAddSuggestion> _suggestion = ref
      .read(scanToAddUseCaseProvider)
      .suggest(widget.recognizedBarcode);
  bool _isAdding = false;

  Future<void> _add(ScanToAddSuggestion suggestion, {required String drawerName}) async {
    final localizations = BarcodeScanningLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final quantityFormatter = context.quantityFormatter;
    final productName = context.productDisplayNameResolver.productName(suggestion.product);
    setState(() => _isAdding = true);
    final result = await ref.read(scanToAddUseCaseProvider).add(suggestion);
    if (!mounted) return;
    setState(() => _isAdding = false);
    switch (result) {
      case SuccessfulResult():
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              localizations.addedSnackbar(
                quantityFormatter.format(suggestion.quantity!),
                productName,
                drawerName,
              ),
            ),
          ),
        );
        widget.onDone();
      case FailedResult(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(InventoryLocalizations.of(context).describeFailure(failure))),
        );
    }
  }

  Future<void> _openAddForm() async {
    final product = widget.recognizedBarcode.product;
    final embeddedWeight = widget.recognizedBarcode.barcode.embeddedWeightFor(
      product.canonicalUnit,
    );
    await context.push(
      InventoryRoutes.addStockBatch(
        productIdentifier: product.identifier,
        amountInBaseUnits: embeddedWeight?.amountInBaseUnits,
      ),
    );
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = BarcodeScanningLocalizations.of(context);
    final quantityFormatter = context.quantityFormatter;
    final product = widget.recognizedBarcode.product;
    final overview = ref.watch(inventoryOverviewProvider).value;
    final layout = ref.watch(storageLayoutProvider).value;
    final stock = overview
        ?.itemsOfProduct(product.identifier)
        .map((item) => item.batch.quantityRemaining)
        .fold(Quantity.zero(product.canonicalUnit), (total, quantity) => total + quantity);
    final embeddedWeight = widget.recognizedBarcode.barcode.embeddedWeightFor(
      product.canonicalUnit,
    );
    return FutureBuilder<ScanToAddSuggestion>(
      future: _suggestion,
      builder: (context, snapshot) {
        final suggestion = snapshot.data;
        final quantity = suggestion?.quantity;
        final compartment = suggestion?.compartment;
        final drawerName = compartment == null || layout == null
            ? null
            : context
                  .compartmentDisplayNameResolver(layout)
                  .compartmentNameWithStoragePlace(compartment);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(localizations.recognized, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: FoodieSpacing.small),
            _RecognizedProductHeader(
              recognizedBarcode: widget.recognizedBarcode,
              isCodeJustLearned: widget.isCodeJustLearned,
              detail: stock == null
                  ? null
                  : localizations.amountInStoragePlace(quantityFormatter.format(stock)),
            ),
            if (embeddedWeight != null) ...[
              const SizedBox(height: FoodieSpacing.small),
              Text(localizations.weightInCode(quantityFormatter.format(embeddedWeight))),
            ],
            const SizedBox(height: FoodieSpacing.medium),
            if (suggestion == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (quantity != null && drawerName != null && suggestion.canAddWithOneTap)
                FilledButton(
                  onPressed: _isAdding ? null : () => _add(suggestion, drawerName: drawerName),
                  child: Text(
                    localizations.addToDrawer(quantityFormatter.format(quantity), drawerName),
                  ),
                ),
              OutlinedButton(
                onPressed: _isAdding ? null : _openAddForm,
                child: Text(
                  suggestion.canAddWithOneTap
                      ? localizations.changeDetails
                      : localizations.chooseAmount,
                ),
              ),
            ],
            _WrongProductButton(
              recognizedBarcode: widget.recognizedBarcode,
              onLearned: widget.onLearned,
            ),
          ],
        );
      },
    );
  }
}

/// Scan to remove (section 10.3): a code names a product, not a bag, so the
/// oldest bag is suggested (first in, first out) and handed to the
/// inventory's own take sheet; another bag can be picked instead.
class ScanToRemovePanel extends ConsumerWidget {
  const ScanToRemovePanel({
    required this.recognizedBarcode,
    required this.isCodeJustLearned,
    required this.onLearned,
    required this.onDone,
    super.key,
  });

  final RecognizedBarcode recognizedBarcode;
  final bool isCodeJustLearned;
  final ValueChanged<RecognizedBarcode> onLearned;
  final VoidCallback onDone;

  Future<void> _take(BuildContext context, InventoryItem item) async {
    await showTakeStockSheet(context, item);
    onDone();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = BarcodeScanningLocalizations.of(context);
    final overview = ref.watch(inventoryOverviewProvider).value;
    if (overview == null) return const Center(child: CircularProgressIndicator());
    final items = overview.itemsOfProduct(recognizedBarcode.product.identifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecognizedProductHeader(
          recognizedBarcode: recognizedBarcode,
          isCodeJustLearned: isCodeJustLearned,
          detail: items.isEmpty ? localizations.notInStoragePlace : null,
        ),
        if (items.isEmpty)
          TextButton(onPressed: onDone, child: Text(localizations.scanNext))
        else ...[
          const SizedBox(height: FoodieSpacing.medium),
          Text(localizations.bagsInStoragePlace(items.length)),
          StockItemTile(item: items.first, today: overview.today),
          FilledButton(
            onPressed: () => _take(context, items.first),
            child: Text(localizations.chooseAmount),
          ),
          if (items.length > 1) ...[
            const SizedBox(height: FoodieSpacing.medium),
            Text(localizations.otherBags, style: Theme.of(context).textTheme.labelLarge),
            for (final item in items.skip(1))
              StockItemTile(item: item, today: overview.today, onTap: () => _take(context, item)),
          ],
        ],
        _WrongProductButton(recognizedBarcode: recognizedBarcode, onLearned: onLearned),
      ],
    );
  }
}
