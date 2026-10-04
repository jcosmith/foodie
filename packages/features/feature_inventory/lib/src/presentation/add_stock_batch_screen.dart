import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/inventory_providers.dart';
import '../application/use_cases/add_stock_batch_use_case.dart';
import '../domain/inventory_failure.dart';
import '../l10n/generated/inventory_localizations.dart';
import 'inventory_texts.dart';

/// The add form (UI example phones 3 and 13): product, amount pre-filled from
/// the package size, the day it was put away, a best-before date where the
/// domain asks for one, the compartment it goes into and a note. Opened in a domain tab, it offers only that domain's
/// compartments and speaks its words ("Add to the freezer", "Frozen on").
class AddStockBatchScreen extends ConsumerStatefulWidget {
  const AddStockBatchScreen({
    this.initialProductIdentifier,
    this.initialAmountInBaseUnits,
    this.domainIdentifier,
    super.key,
  });

  /// The domain whose tab opened the form; `null` offers every place.
  final StorageDomainIdentifier? domainIdentifier;

  /// Chosen already, for example by a barcode scan.
  final ProductIdentifier? initialProductIdentifier;

  /// Replaces the package size, for example the weight printed into a
  /// weighed-goods barcode; in the product's base unit.
  final int? initialAmountInBaseUnits;

  @override
  ConsumerState<AddStockBatchScreen> createState() => _AddStockBatchScreenState();
}

class _AddStockBatchScreenState extends ConsumerState<AddStockBatchScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  ProductIdentifier? _productIdentifier;
  CompartmentIdentifier? _compartmentIdentifier;
  late CalendarDate _storedOn = ref.read(clockProvider).todayLocal();

  /// Whether the user picked a best-before date (or none); until then it
  /// follows the product's shelf life.
  bool _isBestBeforeChosen = false;
  CalendarDate? _chosenBestBeforeOn;
  String? _amountError;
  String? _productError;
  bool _isSaving = false;

  /// A photo taken in the form, attached to the batch once it is saved.
  final ItemPictureDraft _pictureDraft = ItemPictureDraft();

  @override
  void initState() {
    super.initState();
    if (widget.initialProductIdentifier case final initialProductIdentifier?) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _selectProduct(
          initialProductIdentifier,
          amountInBaseUnits: widget.initialAmountInBaseUnits,
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _pictureDraft.dispose();
    super.dispose();
  }

  Future<void> _chooseProduct() async {
    final productIdentifier = await showProductPickerSheet(context);
    if (productIdentifier != null && mounted) await _selectProduct(productIdentifier);
  }

  /// The layout the form offers: one domain's places, or all of them.
  StorageLayout? _offeredLayout(StorageLayout? layout) =>
      switch ((layout, widget.domainIdentifier)) {
        (final layout?, final domainIdentifier?) => layout.restrictedTo(domainIdentifier),
        (final layout, null) => layout,
        (null, _) => null,
      };

  StorageDomainContribution? _domainOf(StorageDomainIdentifier? domainIdentifier) => ref
      .read(registeredStorageDomainsProvider)
      .where((domain) => domain.identifier == domainIdentifier)
      .firstOrNull;

  /// Takes the product's package size (or [amountInBaseUnits]) as the amount
  /// and its default compartment, or else the one it went into last time.
  Future<void> _selectProduct(ProductIdentifier productIdentifier, {int? amountInBaseUnits}) async {
    final product = await ref
        .read(productCatalogQueryServiceProvider)
        .readProduct(productIdentifier);
    final lastCompartment = await ref
        .read(inventoryQueryServiceProvider)
        .readLastCompartmentOfProduct(productIdentifier);
    if (product == null || !mounted) return;
    final layout = _offeredLayout(ref.read(storageLayoutProvider).value) ?? StorageLayout.empty;
    bool isActive(CompartmentIdentifier? compartmentIdentifier) =>
        compartmentIdentifier != null &&
        layout.activeCompartments.any(
          (compartment) => compartment.identifier == compartmentIdentifier,
        );
    final suggestedCompartment = [
      product.defaultCompartmentIdentifier,
      lastCompartment,
    ].firstWhere(isActive, orElse: () => null);
    setState(() {
      _productIdentifier = productIdentifier;
      _productError = null;
      _amountError = null;
      final initialQuantity = switch (amountInBaseUnits) {
        final amount? when amount > 0 => Quantity(
          amountInBaseUnits: amount,
          unit: product.canonicalUnit,
        ),
        _ => product.defaultPackageQuantity,
      };
      _amountController.text = switch (initialQuantity) {
        final quantity? => context.quantityFormatter.formatAmountForInput(quantity),
        null => '',
      };
      if (suggestedCompartment != null) _compartmentIdentifier = suggestedCompartment;
    });
  }

  Future<void> _chooseStoredOn() async {
    final today = ref.read(clockProvider).todayLocal();
    final chosenDate = await showDatePicker(
      context: context,
      initialDate: _storedOn.toLocalDateTime(),
      firstDate: today.addDays(-5 * 366).toLocalDateTime(),
      lastDate: today.toLocalDateTime(),
    );
    if (chosenDate != null) setState(() => _storedOn = CalendarDate.fromDateTime(chosenDate));
  }

  /// The last good day by the product's shelf life, when it has one.
  CalendarDate? _suggestedBestBeforeOn(Product? product, ProductCatalog catalog) {
    if (product == null) return null;
    final shelfLifeDays = catalog.recommendedMaximumStorageDaysOf(product);
    if (shelfLifeDays == null || shelfLifeDays <= 0) return null;
    return _storedOn.addDays(shelfLifeDays - 1);
  }

  void _chooseBestBeforeOn(CalendarDate? bestBeforeOn) => setState(() {
    _isBestBeforeChosen = true;
    _chosenBestBeforeOn = bestBeforeOn;
  });

  Future<void> _pickBestBeforeOn(CalendarDate? current) async {
    final today = ref.read(clockProvider).todayLocal();
    final chosenDate = await showDatePicker(
      context: context,
      initialDate: (current ?? today).toLocalDateTime(),
      firstDate: today.addDays(-366).toLocalDateTime(),
      lastDate: today.addDays(5 * 366).toLocalDateTime(),
    );
    if (chosenDate != null) _chooseBestBeforeOn(CalendarDate.fromDateTime(chosenDate));
  }

  Future<void> _save({
    required Product? product,
    required CompartmentIdentifier? compartmentIdentifier,
    required String compartmentName,
    required CalendarDate? bestBeforeOn,
  }) async {
    final localizations = InventoryLocalizations.of(context);
    if (product == null) {
      setState(() => _productError = localizations.productMissing);
      return;
    }
    final quantity = QuantityFormatter.parseDisplayAmount(
      _amountController.text,
      product.canonicalUnit,
    );
    if (quantity == null) {
      setState(() => _amountError = localizations.invalidAmount);
      return;
    }
    if (compartmentIdentifier == null) {
      _showMessage(localizations.compartmentMissing);
      return;
    }
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final successMessage = localizations.addedSnackbar(
      context.quantityFormatter.format(quantity),
      context.productDisplayNameResolver.productName(product),
      compartmentName,
    );
    final result = await ref
        .read(addStockBatchUseCaseProvider)
        .execute(
          AddStockBatchCommand(
            productIdentifier: product.identifier,
            compartmentIdentifier: compartmentIdentifier,
            quantity: quantity,
            storedOn: _storedOn,
            bestBeforeOn: bestBeforeOn,
            note: _noteController.text,
          ),
        );
    if (result case SuccessfulResult(value: final stockBatchIdentifier)) {
      await _pictureDraft.attachTo(
        StockBatchItemVisualSubject(
          stockBatchIdentifier: stockBatchIdentifier.value,
          productIdentifier: product.identifier.value,
        ),
      );
    }
    if (!mounted) return;
    switch (result) {
      case SuccessfulResult():
        context.pop();
        messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      case FailedResult(:final failure):
        setState(() {
          _isSaving = false;
          if (failure is QuantityNotPositive) {
            _amountError = localizations.describeFailure(failure);
          }
        });
        if (failure is! QuantityNotPositive) _showMessage(localizations.describeFailure(failure));
    }
  }

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final localizations = InventoryLocalizations.of(context);
    final layout = _offeredLayout(ref.watch(storageLayoutProvider).value);
    final catalog = ref.watch(productCatalogProvider).value;
    final title =
        _domainOf(widget.domainIdentifier)?.addTitleBuilder?.call(context) ??
        localizations.addTitle;
    if (layout == null || catalog == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!layout.hasStoragePlace) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: EmptyStateView(
          icon: Icons.kitchen_outlined,
          title: localizations.noStoragePlaceTitle,
          message: localizations.noStoragePlaceMessage,
          actionLabel: localizations.setUpStoragePlaceButton,
          onActionPressed: () => context.push(switch (widget.domainIdentifier) {
            final domainIdentifier? => StorageLayoutRoutes.newStoragePlaceIn(domainIdentifier),
            null => StorageLayoutRoutes.newStoragePlace,
          }),
        ),
      );
    }

    final product = switch (_productIdentifier) {
      final productIdentifier? => catalog.productOf(productIdentifier),
      null => null,
    };
    final compartments = layout.activeCompartments;
    final compartmentIdentifier = compartments
        .map((compartment) => compartment.identifier)
        .firstWhere(
          (identifier) => identifier == _compartmentIdentifier,
          orElse: () => compartments.first.identifier,
        );
    final nameResolver = context.compartmentDisplayNameResolver(layout);
    final selectedDomain = _domainOf(layout.domainOfCompartment(compartmentIdentifier));
    final storedOnLabel =
        selectedDomain?.storedOnLabelBuilder(context) ?? localizations.storedOnLabel;
    final bestBeforeLabel = selectedDomain?.bestBeforeLabelBuilder?.call(context);
    final bestBeforeOn = bestBeforeLabel == null
        ? null
        : _isBestBeforeChosen
        ? _chosenBestBeforeOn
        : _suggestedBestBeforeOn(product, catalog);
    final shelfLifeDays = product == null ? null : catalog.recommendedMaximumStorageDaysOf(product);
    final quantityFormatter = context.quantityFormatter;
    final textTheme = Theme.of(context).textTheme;
    // Only while item pictures are switched on (UI examples document, phone 5).
    final pictureSlot = ref
        .watch(enabledItemVisualProvider)
        ?.buildPictureSlot(context, _pictureDraft);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
        children: [
          if (pictureSlot != null) ...[pictureSlot, const SizedBox(height: FoodieSpacing.large)],
          InkWell(
            onTap: _chooseProduct,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: localizations.productLabel,
                errorText: _productError,
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              child: product == null
                  ? Text(localizations.chooseProduct)
                  : Row(
                      children: [
                        ProductVisual(product: product, catalog: catalog, size: 24),
                        const SizedBox(width: FoodieSpacing.small),
                        Expanded(
                          child: Text(context.productDisplayNameResolver.productName(product)),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: FoodieSpacing.large),
          TextField(
            controller: _amountController,
            enabled: product != null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              if (_amountError != null) setState(() => _amountError = null);
            },
            decoration: InputDecoration(
              labelText: localizations.quantityLabel,
              suffixText: product == null
                  ? null
                  : quantityFormatter.unitSymbol(product.canonicalUnit),
              helperText: switch (product?.defaultPackageQuantity) {
                final packageQuantity? => localizations.packageHint(
                  quantityFormatter.format(packageQuantity),
                ),
                null => null,
              },
              errorText: _amountError,
            ),
          ),
          const SizedBox(height: FoodieSpacing.large),
          InkWell(
            onTap: _chooseStoredOn,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: storedOnLabel,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(context.dateDisplayFormatter.formatMediumDate(_storedOn)),
            ),
          ),
          if (bestBeforeLabel != null) ...[
            const SizedBox(height: FoodieSpacing.large),
            _BestBeforeField(
              label: bestBeforeLabel,
              bestBeforeOn: bestBeforeOn,
              today: ref.watch(clockProvider).todayLocal(),
              hint: shelfLifeDays == null || shelfLifeDays <= 0
                  ? null
                  : localizations.bestBeforeHint(
                      context.shelfLifeFormatter.formatDays(shelfLifeDays),
                    ),
              onChosen: _chooseBestBeforeOn,
              onPickDate: () => _pickBestBeforeOn(bestBeforeOn),
            ),
          ],
          const SizedBox(height: FoodieSpacing.large),
          Text(localizations.compartmentLabel, style: textTheme.titleSmall),
          const SizedBox(height: FoodieSpacing.small),
          Wrap(
            spacing: FoodieSpacing.small,
            runSpacing: FoodieSpacing.small,
            children: [
              for (final compartment in compartments)
                ChoiceChip(
                  avatar: Icon(
                    Icons.circle,
                    size: 12,
                    color: CompartmentColorPalette.colorAt(compartment.colorTagIndex),
                  ),
                  label: Text(nameResolver.compartmentNameWithStoragePlace(compartment)),
                  selected: compartment.identifier == compartmentIdentifier,
                  onSelected: (_) =>
                      setState(() => _compartmentIdentifier = compartment.identifier),
                ),
            ],
          ),
          const SizedBox(height: FoodieSpacing.large),
          TextField(
            controller: _noteController,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: localizations.noteLabel),
          ),
          const SizedBox(height: FoodieSpacing.medium),
          FilledButton(
            onPressed: _isSaving
                ? null
                : () => _save(
                    product: product,
                    compartmentIdentifier: compartmentIdentifier,
                    compartmentName: nameResolver.compartmentNameOf(compartmentIdentifier),
                    bestBeforeOn: bestBeforeOn,
                  ),
            child: Text(context.commonLocalizations.actionSave),
          ),
        ],
      ),
    );
  }
}

/// The date printed on the package (UI example phone 13): the date, how
/// long the product usually keeps, and chips for the usual cases.
class _BestBeforeField extends StatelessWidget {
  const _BestBeforeField({
    required this.label,
    required this.bestBeforeOn,
    required this.today,
    required this.hint,
    required this.onChosen,
    required this.onPickDate,
  });

  final String label;
  final CalendarDate? bestBeforeOn;
  final CalendarDate today;
  final String? hint;
  final ValueChanged<CalendarDate?> onChosen;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final localizations = InventoryLocalizations.of(context);
    final quickChoices = [
      (localizations.bestBeforeToday, today),
      (localizations.bestBeforePlusOneDay, today.addDays(1)),
      (localizations.bestBeforePlusThreeDays, today.addDays(3)),
      (localizations.bestBeforePlusOneWeek, today.addDays(7)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onPickDate,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              helperText: hint,
              suffixIcon: const Icon(Icons.event_outlined),
            ),
            child: Text(switch (bestBeforeOn) {
              final date? => context.dateDisplayFormatter.formatMediumDate(date),
              null => localizations.noBestBefore,
            }),
          ),
        ),
        const SizedBox(height: FoodieSpacing.small),
        Wrap(
          spacing: FoodieSpacing.small,
          runSpacing: FoodieSpacing.small,
          children: [
            for (final (choiceLabel, date) in quickChoices)
              ChoiceChip(
                label: Text(choiceLabel),
                selected: bestBeforeOn == date,
                onSelected: (_) => onChosen(date),
              ),
            ChoiceChip(
              label: Text(localizations.bestBeforeNone),
              selected: bestBeforeOn == null,
              onSelected: (_) => onChosen(null),
            ),
            ActionChip(
              avatar: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(localizations.bestBeforePickDate),
              onPressed: onPickDate,
            ),
          ],
        ),
      ],
    );
  }
}
