import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/barcode_use_cases.dart';
import '../l10n/generated/barcode_scanning_localizations.dart';

/// The review list of the continuous mode (unpacking groceries, section
/// 10.3): every scanned item with its amount and drawer, to correct or
/// remove before everything goes into the freezer at once.
class UnpackingListCard extends ConsumerWidget {
  const UnpackingListCard({
    required this.entries,
    required this.isPuttingAway,
    required this.onQuantityChanged,
    required this.onRemoved,
    required this.onPutAway,
    super.key,
  });

  final List<ScanToAddSuggestion> entries;
  final bool isPuttingAway;
  final void Function(int index, Quantity quantity) onQuantityChanged;
  final void Function(int index) onRemoved;
  final VoidCallback onPutAway;

  Future<void> _changeQuantity(BuildContext context, int index) async {
    final entry = entries[index];
    final quantity = await showDialog<Quantity>(
      context: context,
      builder: (dialogContext) =>
          _AmountDialog(unit: entry.product.canonicalUnit, initialQuantity: entry.quantity),
    );
    if (quantity != null) onQuantityChanged(index, quantity);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = BarcodeScanningLocalizations.of(context);
    final quantityFormatter = context.quantityFormatter;
    final catalog = ref.watch(productCatalogProvider).value;
    final layout = ref.watch(storageLayoutProvider).value;
    final nameResolver = layout == null ? null : context.compartmentDisplayNameResolver(layout);
    final canPutAway =
        entries.isNotEmpty && entries.every((entry) => entry.canAddWithOneTap) && !isPuttingAway;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FreezerSpacing.small),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FreezerSpacing.medium),
              child: Text(
                localizations.unpackingListTitle(entries.length),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final (index, entry) in entries.indexed)
              ListTile(
                onTap: () => _changeQuantity(context, index),
                leading: catalog == null
                    ? null
                    : ProductVisual(product: entry.product, catalog: catalog, size: 32),
                title: Text(context.productDisplayNameResolver.productName(entry.product)),
                subtitle: Text(switch ((entry.quantity, entry.compartment)) {
                  (_, null) => localizations.noFreezerYet,
                  (null, _) => localizations.amountNeeded,
                  (final quantity?, final compartment?) =>
                    '${quantityFormatter.format(quantity)} · '
                        '${nameResolver?.compartmentNameWithFreezer(compartment) ?? ''}',
                }),
                trailing: IconButton(
                  tooltip: localizations.removeFromList,
                  icon: const Icon(Icons.close),
                  onPressed: () => onRemoved(index),
                ),
              ),
            if (entries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  FreezerSpacing.medium,
                  FreezerSpacing.small,
                  FreezerSpacing.medium,
                  FreezerSpacing.small,
                ),
                child: FilledButton(
                  onPressed: canPutAway ? onPutAway : null,
                  child: Text(localizations.putAwayButton(entries.length)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.unit, required this.initialQuantity});

  final QuantityUnit unit;
  final Quantity? initialQuantity;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final TextEditingController _amountController = TextEditingController();
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_amountController.text.isEmpty && widget.initialQuantity != null) {
      _amountController.text = context.quantityFormatter.formatAmountForInput(
        widget.initialQuantity!,
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final quantity = QuantityFormatter.parseDisplayAmount(_amountController.text, widget.unit);
    if (quantity == null || !quantity.isPositive) {
      setState(() => _error = BarcodeScanningLocalizations.of(context).invalidAmount);
      return;
    }
    Navigator.of(context).pop(quantity);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(BarcodeScanningLocalizations.of(context).amountDialogTitle),
    content: TextField(
      controller: _amountController,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        suffixText: context.quantityFormatter.unitSymbol(widget.unit),
        errorText: _error,
      ),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.commonLocalizations.actionCancel),
      ),
      FilledButton(onPressed: _submit, child: Text(context.commonLocalizations.actionSave)),
    ],
  );
}
