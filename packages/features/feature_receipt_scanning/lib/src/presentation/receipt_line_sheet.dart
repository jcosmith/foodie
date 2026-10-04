import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/receipt_scanning_localizations.dart';

/// Asks how much of [product] the line stands for and where it goes.
Future<(Quantity, Compartment)?> showReceiptLineSheet(
  BuildContext context, {
  required Product product,
  Quantity? quantity,
  Compartment? compartment,
}) => showModalBottomSheet<(Quantity, Compartment)>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) =>
      _ReceiptLineSheet(product: product, quantity: quantity, compartment: compartment),
);

class _ReceiptLineSheet extends ConsumerStatefulWidget {
  const _ReceiptLineSheet({required this.product, this.quantity, this.compartment});

  final Product product;
  final Quantity? quantity;
  final Compartment? compartment;

  @override
  ConsumerState<_ReceiptLineSheet> createState() => _ReceiptLineSheetState();
}

class _ReceiptLineSheetState extends ConsumerState<_ReceiptLineSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: switch (widget.quantity) {
      final quantity? => context.quantityFormatter.formatAmountForInput(quantity),
      null => '',
    },
  );
  late CompartmentIdentifier? _compartmentIdentifier = widget.compartment?.identifier;
  String? _amountError;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save(List<Compartment> compartments) {
    final quantity = QuantityFormatter.parseDisplayAmount(
      _amount.text,
      widget.product.canonicalUnit,
    );
    final compartment = compartments
        .where((compartment) => compartment.identifier == _compartmentIdentifier)
        .firstOrNull;
    if (quantity == null || !quantity.isPositive) {
      setState(() => _amountError = ReceiptScanningLocalizations.of(context).invalidAmount);
      return;
    }
    if (compartment == null) return;
    Navigator.of(context).pop((quantity, compartment));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final common = context.commonLocalizations;
    final layout = ref.watch(storageLayoutOfEnabledDomainsProvider).value ?? StorageLayout.empty;
    final compartments = layout.activeCompartments;
    final names = context.compartmentDisplayNameResolver(layout);
    final selected =
        compartments.any((compartment) => compartment.identifier == _compartmentIdentifier)
        ? _compartmentIdentifier
        : compartments.firstOrNull?.identifier;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        FoodieSpacing.large,
        0,
        FoodieSpacing.large,
        FoodieSpacing.large + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.productDisplayNameResolver.productName(widget.product),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: FoodieSpacing.large),
          TextField(
            controller: _amount,
            autofocus: widget.quantity == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: localizations.amountLabel(
                context.quantityFormatter.unitSymbol(widget.product.canonicalUnit),
              ),
              errorText: _amountError,
            ),
          ),
          const SizedBox(height: FoodieSpacing.medium),
          DropdownButtonFormField<CompartmentIdentifier>(
            initialValue: selected,
            decoration: InputDecoration(labelText: localizations.compartmentLabel),
            items: [
              for (final compartment in compartments)
                DropdownMenuItem(
                  value: compartment.identifier,
                  child: Text(names.compartmentNameWithStoragePlace(compartment)),
                ),
            ],
            onChanged: (identifier) => setState(() => _compartmentIdentifier = identifier),
          ),
          const SizedBox(height: FoodieSpacing.large),
          FilledButton(
            onPressed: compartments.isEmpty
                ? null
                : () {
                    _compartmentIdentifier = selected;
                    _save(compartments);
                  },
            child: Text(common.actionSave),
          ),
        ],
      ),
    );
  }
}
