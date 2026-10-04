import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/inventory_overview.dart';
import '../application/inventory_providers.dart';
import '../domain/inventory_movement.dart';
import '../domain/removal_amount_policy.dart';
import '../l10n/generated/inventory_localizations.dart';
import 'inventory_texts.dart';
import 'removal_amount_picker.dart';
import 'stock_item_tile.dart';

/// Opens the sheet for taking food out of [item]'s batch, with links to
/// throwing away, moving and correcting it.
Future<void> showTakeStockSheet(BuildContext context, InventoryItem item) =>
    _showSheet(context, (sheetContext) => _TakeOrDiscardSheet(item: item, isDiscarding: false));

Future<void> _showSheet(BuildContext context, WidgetBuilder builder) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (sheetContext) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
    child: SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        FoodieSpacing.screenGutter,
        0,
        FoodieSpacing.screenGutter,
        FoodieSpacing.large,
      ),
      child: builder(sheetContext),
    ),
  ),
);

/// The product, how much is left of how much, when it was frozen and where.
class _SheetHeader extends ConsumerWidget {
  const _SheetHeader({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = InventoryLocalizations.of(context);
    final quantityFormatter = context.quantityFormatter;
    final batch = item.batch;
    final layout = ref.watch(storageLayoutProvider).value ?? StorageLayout.empty;
    final details = [
      localizations.ofInitial(
        quantityFormatter.format(batch.quantityRemaining),
        quantityFormatter.format(batch.initialQuantity),
      ),
      context.dateDisplayFormatter.formatMediumDate(batch.storedOn),
      context.compartmentDisplayNameResolver(layout).compartmentNameOf(batch.compartmentIdentifier),
    ].where((detail) => detail.isNotEmpty);
    final itemVisualProvider = ref.watch(enabledItemVisualProvider);
    return Row(
      children: [
        if (itemVisualProvider == null)
          StockItemVisual(item: item, size: 48)
        else
          // The batch's own photo, such as the label of a homemade meal.
          Tooltip(
            message: localizations.batchPhotoButton,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showSheet(
                context,
                (sheetContext) =>
                    itemVisualProvider.buildPictureEditor(
                      sheetContext,
                      StockBatchItemVisualSubject(
                        stockBatchIdentifier: batch.identifier.value,
                        productIdentifier: item.product.identifier.value,
                      ),
                    ) ??
                    const SizedBox.shrink(),
              ),
              child: StockItemVisual(item: item, size: 48),
            ),
          ),
        const SizedBox(width: FoodieSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.productDisplayNameResolver.productName(item.product),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(details.join(' · '), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _TakeOrDiscardSheet extends ConsumerStatefulWidget {
  const _TakeOrDiscardSheet({required this.item, required this.isDiscarding});

  final InventoryItem item;
  final bool isDiscarding;

  @override
  ConsumerState<_TakeOrDiscardSheet> createState() => _TakeOrDiscardSheetState();
}

class _TakeOrDiscardSheetState extends ConsumerState<_TakeOrDiscardSheet> {
  late Quantity _amount = widget.isDiscarding
      ? widget.item.batch.quantityRemaining
      : RemovalAmountPolicy.suggestedAmount(widget.item.batch.quantityRemaining);
  DiscardReason _discardReason = DiscardReason.tooOld;
  bool _isSaving = false;

  Future<void> _confirm() async {
    setState(() => _isSaving = true);
    final localizations = InventoryLocalizations.of(context);
    final quantityFormatter = context.quantityFormatter;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final undoStockRemoval = ref.read(undoStockRemovalUseCaseProvider);
    final productName = context.productDisplayNameResolver.productName(widget.item.product);
    final batchIdentifier = widget.item.batch.identifier;
    final result = widget.isDiscarding
        ? await ref
              .read(discardStockUseCaseProvider)
              .execute(
                stockBatchIdentifier: batchIdentifier,
                quantity: _amount,
                discardReason: _discardReason,
              )
        : await ref
              .read(consumeStockUseCaseProvider)
              .execute(stockBatchIdentifier: batchIdentifier, quantity: _amount);
    if (!mounted) return;
    switch (result) {
      case SuccessfulResult(value: final recordedRemoval):
        navigator.pop();
        final amountText = quantityFormatter.format(recordedRemoval.quantity);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.isDiscarding
                  ? localizations.discardedSnackbar(amountText, productName)
                  : localizations.tookSnackbar(amountText, productName),
            ),
            action: SnackBarAction(
              label: context.commonLocalizations.actionUndo,
              onPressed: () => undoStockRemoval.execute(recordedRemoval.movementIdentifier),
            ),
          ),
        );
      case FailedResult(:final failure):
        setState(() => _isSaving = false);
        messenger.showSnackBar(SnackBar(content: Text(localizations.describeFailure(failure))));
    }
  }

  /// "Mark as opened" (or not opened again): one tap, with undo.
  Future<void> _toggleOpened() async {
    final localizations = InventoryLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final markOpened = ref.read(markStockBatchOpenedUseCaseProvider);
    final batch = widget.item.batch;
    final productName = context.productDisplayNameResolver.productName(widget.item.product);
    final undoLabel = context.commonLocalizations.actionUndo;
    final isOpening = !batch.isOpened;
    final result = await markOpened.execute(batch.identifier, isOpened: isOpening);
    if (!mounted) return;
    switch (result) {
      case SuccessfulResult():
        navigator.pop();
        if (isOpening) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(localizations.markedOpenedSnackbar(productName)),
              action: SnackBarAction(
                label: undoLabel,
                onPressed: () => markOpened.execute(batch.identifier, isOpened: false),
              ),
            ),
          );
        }
      case FailedResult(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(localizations.describeFailure(failure))));
    }
  }

  void _switchTo(Future<void> Function(BuildContext context, InventoryItem item) openOtherSheet) {
    final parentContext = Navigator.of(context).context;
    Navigator.of(context).pop();
    openOtherSheet(parentContext, widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = InventoryLocalizations.of(context);
    final amountText = context.quantityFormatter.format(_amount);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(item: widget.item),
        const SizedBox(height: FoodieSpacing.large),
        Text(
          widget.isDiscarding ? localizations.discardTitle : localizations.takeTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: FoodieSpacing.small),
        RemovalAmountPicker(
          batch: widget.item.batch,
          amount: _amount,
          onAmountChanged: (amount) => setState(() => _amount = amount),
        ),
        if (widget.isDiscarding) ...[
          const SizedBox(height: FoodieSpacing.medium),
          Text(localizations.discardReasonLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: FoodieSpacing.small),
          Wrap(
            spacing: FoodieSpacing.small,
            children: [
              for (final discardReason in DiscardReason.values)
                ChoiceChip(
                  label: Text(localizations.discardReasonName(discardReason)),
                  selected: discardReason == _discardReason,
                  onSelected: (_) => setState(() => _discardReason = discardReason),
                ),
            ],
          ),
        ],
        const SizedBox(height: FoodieSpacing.large),
        FilledButton(
          style: widget.isDiscarding
              ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error)
              : null,
          onPressed: _isSaving ? null : _confirm,
          child: Text(
            widget.isDiscarding
                ? localizations.discardAmountButton(amountText)
                : localizations.takeAmountButton(amountText),
          ),
        ),
        if (!widget.isDiscarding) ...[
          const SizedBox(height: FoodieSpacing.small),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _switchTo(
                  (context, item) => _showSheet(
                    context,
                    (sheetContext) => _TakeOrDiscardSheet(item: item, isDiscarding: true),
                  ),
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text(localizations.discardAction),
              ),
              TextButton.icon(
                onPressed: () => _switchTo(
                  (context, item) => _showSheet(context, (sheetContext) => _MoveSheet(item: item)),
                ),
                icon: const Icon(Icons.drive_file_move_outline),
                label: Text(localizations.moveAction),
              ),
              TextButton.icon(
                onPressed: () => _switchTo(
                  (context, item) =>
                      _showSheet(context, (sheetContext) => _CorrectSheet(item: item)),
                ),
                icon: const Icon(Icons.edit_outlined),
                label: Text(localizations.correctAction),
              ),
              TextButton.icon(
                onPressed: _toggleOpened,
                icon: Icon(
                  widget.item.batch.isOpened
                      ? Icons.inventory_2_outlined
                      : Icons.lock_open_outlined,
                ),
                label: Text(
                  widget.item.batch.isOpened
                      ? localizations.markNotOpenedAction
                      : localizations.markOpenedAction,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MoveSheet extends ConsumerStatefulWidget {
  const _MoveSheet({required this.item});

  final InventoryItem item;

  @override
  ConsumerState<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends ConsumerState<_MoveSheet> {
  late Quantity _amount = widget.item.batch.quantityRemaining;
  CompartmentIdentifier? _destination;
  bool _startsFreshToday = true;
  bool _isSaving = false;

  Future<void> _confirm(
    CompartmentIdentifier destination,
    String destinationName, {
    required bool startsFreshToday,
  }) async {
    setState(() => _isSaving = true);
    final localizations = InventoryLocalizations.of(context);
    final amountText = context.quantityFormatter.format(_amount);
    final productName = context.productDisplayNameResolver.productName(widget.item.product);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final result = await ref
        .read(moveStockBatchUseCaseProvider)
        .execute(
          stockBatchIdentifier: widget.item.batch.identifier,
          destinationCompartmentIdentifier: destination,
          quantity: _amount,
          startsFreshToday: startsFreshToday,
        );
    if (!mounted) return;
    switch (result) {
      case SuccessfulResult():
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(localizations.movedSnackbar(amountText, productName, destinationName)),
          ),
        );
      case FailedResult(:final failure):
        setState(() => _isSaving = false);
        messenger.showSnackBar(SnackBar(content: Text(localizations.describeFailure(failure))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = InventoryLocalizations.of(context);
    // Places of switched-off domains are no destination.
    final layout = ref.watch(storageLayoutOfEnabledDomainsProvider).value ?? StorageLayout.empty;
    final nameResolver = context.compartmentDisplayNameResolver(layout);
    // The batch's own domain first, so a move to the next shelf is one tap.
    final sourceDomain = layout.domainOfCompartment(widget.item.batch.compartmentIdentifier);
    final otherCompartments = [
      for (final compartment in layout.activeCompartments)
        if (compartment.identifier != widget.item.batch.compartmentIdentifier) compartment,
    ];
    final destinations = [
      ...otherCompartments.where(
        (compartment) => layout.domainOfCompartment(compartment.identifier) == sourceDomain,
      ),
      ...otherCompartments.where(
        (compartment) => layout.domainOfCompartment(compartment.identifier) != sourceDomain,
      ),
    ];
    final selectedDestination = _destination ?? destinations.firstOrNull?.identifier;
    // Into another domain that resets the clock, such as the freezer.
    final destinationDomain = selectedDestination == null
        ? null
        : layout.domainOfCompartment(selectedDestination);
    final storedTodayLabel = destinationDomain == null || destinationDomain == sourceDomain
        ? null
        : ref
              .watch(registeredStorageDomainsProvider)
              .where((domain) => domain.identifier == destinationDomain)
              .firstOrNull
              ?.storedTodayLabelBuilder
              ?.call(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(item: widget.item),
        const SizedBox(height: FoodieSpacing.large),
        Text(localizations.moveTitle, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: FoodieSpacing.small),
        if (destinations.isEmpty)
          Text(localizations.noOtherCompartment)
        else ...[
          Wrap(
            spacing: FoodieSpacing.small,
            runSpacing: FoodieSpacing.small,
            children: [
              for (final compartment in destinations)
                ChoiceChip(
                  avatar: Icon(
                    Icons.circle,
                    size: 12,
                    color: CompartmentColorPalette.colorAt(compartment.colorTagIndex),
                  ),
                  label: Text(nameResolver.compartmentNameWithStoragePlace(compartment)),
                  selected: compartment.identifier == selectedDestination,
                  onSelected: (_) => setState(() => _destination = compartment.identifier),
                ),
            ],
          ),
          const SizedBox(height: FoodieSpacing.large),
          Text(localizations.moveAmountLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: FoodieSpacing.small),
          RemovalAmountPicker(
            batch: widget.item.batch,
            amount: _amount,
            onAmountChanged: (amount) => setState(() => _amount = amount),
          ),
          if (storedTodayLabel != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(storedTodayLabel),
              value: _startsFreshToday,
              onChanged: (value) => setState(() => _startsFreshToday = value),
            ),
          const SizedBox(height: FoodieSpacing.large),
          FilledButton(
            onPressed: _isSaving || selectedDestination == null
                ? null
                : () => _confirm(
                    selectedDestination,
                    nameResolver.compartmentNameOf(selectedDestination),
                    startsFreshToday: storedTodayLabel != null && _startsFreshToday,
                  ),
            child: Text(localizations.moveAmountButton(context.quantityFormatter.format(_amount))),
          ),
        ],
      ],
    );
  }
}

class _CorrectSheet extends ConsumerStatefulWidget {
  const _CorrectSheet({required this.item});

  final InventoryItem item;

  @override
  ConsumerState<_CorrectSheet> createState() => _CorrectSheetState();
}

class _CorrectSheetState extends ConsumerState<_CorrectSheet> {
  final TextEditingController _amountController = TextEditingController();
  String? _amountError;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_amountController.text.isEmpty) {
      _amountController.text = context.quantityFormatter.formatAmountForInput(
        widget.item.batch.quantityRemaining,
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final localizations = InventoryLocalizations.of(context);
    final actualRemaining = QuantityFormatter.parseDisplayAmount(
      _amountController.text,
      widget.item.batch.unit,
    );
    if (actualRemaining == null) {
      setState(() => _amountError = localizations.invalidAmount);
      return;
    }
    if (actualRemaining == widget.item.batch.quantityRemaining) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final productName = context.productDisplayNameResolver.productName(widget.item.product);
    final amountText = context.quantityFormatter.format(actualRemaining);
    final result = await ref
        .read(correctRemainingQuantityUseCaseProvider)
        .execute(
          stockBatchIdentifier: widget.item.batch.identifier,
          actualRemainingQuantity: actualRemaining,
        );
    if (!mounted) return;
    switch (result) {
      case SuccessfulResult():
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(content: Text(localizations.correctedSnackbar(productName, amountText))),
        );
      case FailedResult(:final failure):
        setState(() {
          _isSaving = false;
          _amountError = localizations.describeFailure(failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = InventoryLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(item: widget.item),
        const SizedBox(height: FoodieSpacing.large),
        Text(localizations.correctTitle, style: Theme.of(context).textTheme.titleSmall),
        Text(localizations.correctHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: FoodieSpacing.medium),
        TextField(
          controller: _amountController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: localizations.quantityLabel,
            suffixText: context.quantityFormatter.unitSymbol(widget.item.batch.unit),
            errorText: _amountError,
          ),
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: FoodieSpacing.large),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(context.commonLocalizations.actionSave),
        ),
      ],
    );
  }
}
