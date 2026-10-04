import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/product_catalog_providers.dart';
import '../application/use_cases/product_settings.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import '../domain/product_catalog.dart';
import '../domain/product_icon_image.dart';
import '../domain/product_name_policy.dart';
import '../l10n/generated/product_catalog_localizations.dart';
import 'catalog_localization.dart';
import 'product_tile.dart';

/// Creates a product, or edits one when [productIdentifier] is set. A new
/// product's identifier is returned when the screen closes.
class ProductEditorScreen extends ConsumerStatefulWidget {
  const ProductEditorScreen({this.productIdentifier, this.initialName = '', super.key});

  final ProductIdentifier? productIdentifier;
  final String initialName;

  @override
  ConsumerState<ProductEditorScreen> createState() => _ProductEditorScreenState();
}

class _ProductEditorScreenState extends ConsumerState<ProductEditorScreen> {
  static const double _averageDaysPerMonth = 30.4;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _packageSizeController = TextEditingController();
  final TextEditingController _storageMonthsController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  bool _hasLoadedInitialValues = false;
  CategoryIdentifier? _categoryIdentifier;
  CompartmentIdentifier? _defaultCompartmentIdentifier;
  ProductIconImage? _iconImage;
  bool _isChoosingIconImage = false;
  QuantityUnit _unit = QuantityUnit.gram;
  String? _nameError;
  String? _packageSizeError;
  String? _storageMonthsError;
  bool _isSaving = false;

  /// A photo taken for a new product, attached once the product is saved.
  final ItemPictureDraft _pictureDraft = ItemPictureDraft();

  bool get _isNewProduct => widget.productIdentifier == null;

  @override
  void dispose() {
    _nameController.dispose();
    _packageSizeController.dispose();
    _storageMonthsController.dispose();
    _iconController.dispose();
    _pictureDraft.dispose();
    super.dispose();
  }

  void _loadInitialValues(ProductCatalog catalog, Product? product) {
    if (_hasLoadedInitialValues || catalog.categories.isEmpty) return;
    _hasLoadedInitialValues = true;
    if (product == null) {
      _nameController.text = widget.initialName;
      _categoryIdentifier = catalog.categories.first.identifier;
      return;
    }
    final quantityFormatter = context.quantityFormatter;
    _nameController.text = product.customName ?? '';
    _categoryIdentifier = product.categoryIdentifier;
    _unit = product.canonicalUnit;
    _packageSizeController.text = switch (product.defaultPackageQuantity) {
      final packageQuantity? => quantityFormatter.formatAmountForInput(packageQuantity),
      null => '',
    };
    _storageMonthsController.text = switch (product.recommendedMaximumStorageDays) {
      final storageDays? => (storageDays / _averageDaysPerMonth).round().toString(),
      null => '',
    };
    _iconController.text = product.iconEmoji ?? '';
    _defaultCompartmentIdentifier = product.defaultCompartmentIdentifier;
    _iconImage = product.iconImage;
  }

  Future<void> _chooseIconImage() async {
    final localizations = ProductCatalogLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isChoosingIconImage = true);
    final result = await ref.read(chooseProductIconImageUseCaseProvider).execute();
    if (!mounted) return;
    setState(() {
      _isChoosingIconImage = false;
      if (result case SuccessfulResult(value: final iconImage?)) _iconImage = iconImage;
    });
    if (result case FailedResult(:final failure)) {
      messenger.showSnackBar(SnackBar(content: Text(localizations.describeFailure(failure))));
    }
  }

  /// The chosen default drawer while it is still in use; a removed drawer
  /// counts as none.
  CompartmentIdentifier? _activeDefaultCompartmentIdentifier(StorageLayout? layout) {
    final compartmentIdentifier = _defaultCompartmentIdentifier;
    if (layout == null || compartmentIdentifier == null) return null;
    final isActive = layout.activeCompartments.any(
      (compartment) => compartment.identifier == compartmentIdentifier,
    );
    return isActive ? compartmentIdentifier : null;
  }

  ProductSettings? _readSettings(ProductCatalogLocalizations localizations) {
    final packageSizeText = _packageSizeController.text.trim();
    final packageQuantity = packageSizeText.isEmpty
        ? null
        : QuantityFormatter.parseDisplayAmount(packageSizeText, _unit);
    final storageMonthsText = _storageMonthsController.text.trim();
    final storageMonths = storageMonthsText.isEmpty ? null : int.tryParse(storageMonthsText);
    setState(() {
      _packageSizeError = packageSizeText.isNotEmpty && packageQuantity == null
          ? localizations.invalidNumber
          : null;
      _storageMonthsError = storageMonthsText.isNotEmpty && storageMonths == null
          ? localizations.invalidNumber
          : null;
    });
    if (_packageSizeError != null || _storageMonthsError != null) return null;
    return ProductSettings(
      enteredName: _nameController.text,
      categoryIdentifier: _categoryIdentifier!,
      defaultPackageQuantity: packageQuantity,
      recommendedMaximumStorageDays: storageMonths == null
          ? null
          : (storageMonths * _averageDaysPerMonth).round(),
      iconEmoji: _iconController.text,
      iconImage: _iconImage,
      defaultCompartmentIdentifier: _activeDefaultCompartmentIdentifier(
        ref.read(storageLayoutProvider).value,
      ),
    );
  }

  Future<void> _save() async {
    final localizations = ProductCatalogLocalizations.of(context);
    final settings = _readSettings(localizations);
    if (settings == null) return;
    setState(() => _isSaving = true);
    final productIdentifier = widget.productIdentifier;
    final result = productIdentifier == null
        ? await ref
              .read(createProductUseCaseProvider)
              .execute(settings: settings, canonicalUnit: _unit)
        : (await ref
                  .read(updateProductUseCaseProvider)
                  .execute(productIdentifier: productIdentifier, settings: settings))
              .mapValue((_) => productIdentifier);
    if (result case SuccessfulResult(value: final savedProductIdentifier)) {
      await _pictureDraft.attachTo(
        ProductItemVisualSubject(productIdentifier: savedProductIdentifier.value),
      );
    }
    if (!mounted) return;
    result.fold(
      onSuccess: (savedProductIdentifier) => context.pop(savedProductIdentifier),
      onFailure: (failure) => setState(() {
        _isSaving = false;
        _nameError = localizations.describeFailure(failure);
      }),
    );
  }

  Future<void> _archive(Product product) async {
    final localizations = ProductCatalogLocalizations.of(context);
    final commonLocalizations = context.commonLocalizations;
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          localizations.archiveProductDialogTitle(
            context.productDisplayNameResolver.productName(product),
          ),
        ),
        content: Text(localizations.archiveProductDialogText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(commonLocalizations.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.archiveProductAction),
          ),
        ],
      ),
    );
    if (isConfirmed != true) return;
    await ref.read(archiveProductUseCaseProvider).execute(product.identifier);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ProductCatalogLocalizations.of(context);
    final quantityFormatter = context.quantityFormatter;
    final catalog = ref.watch(productCatalogProvider).value;
    final layout = ref.watch(storageLayoutProvider).value;
    final productIdentifier = widget.productIdentifier;
    final product = productIdentifier == null ? null : catalog?.productOf(productIdentifier);
    if (catalog == null || (!_isNewProduct && product == null)) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    _loadInitialValues(catalog, product);
    final selectedCategory = _categoryIdentifier == null
        ? null
        : catalog.categoryOf(_categoryIdentifier!);
    final nameResolver = context.productDisplayNameResolver;
    final itemVisualProvider = ref.watch(enabledItemVisualProvider);
    final pictureSection = switch ((itemVisualProvider, product)) {
      (null, _) => null,
      (final provider?, null) => provider.buildPictureSlot(context, _pictureDraft),
      (final provider?, final existingProduct?) => provider.buildPictureEditor(
        context,
        ProductItemVisualSubject(productIdentifier: existingProduct.identifier.value),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewProduct ? localizations.newProductTitle : localizations.editProductTitle),
        actions: [
          if (product != null)
            PopupMenuButton<void>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () => _archive(product),
                  child: Text(localizations.archiveProductAction),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
        children: [
          if (pictureSection != null) ...[
            pictureSection,
            const SizedBox(height: FoodieSpacing.large),
          ],
          TextField(
            controller: _nameController,
            autofocus: _isNewProduct && widget.initialName.isEmpty,
            maxLength: ProductNamePolicy.maximumNameLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: localizations.nameLabel,
              hintText: product?.catalogKey == null
                  ? null
                  : localizations.nameHintSeeded(
                      nameResolver.productName(product!.copyWith(customName: () => null)),
                    ),
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: FoodieSpacing.medium),
          DropdownButtonFormField<CategoryIdentifier>(
            initialValue: _categoryIdentifier,
            decoration: InputDecoration(labelText: localizations.categoryLabel),
            items: [
              for (final category in catalog.categories)
                DropdownMenuItem(
                  value: category.identifier,
                  child: Text('${category.iconEmoji}  ${nameResolver.categoryName(category)}'),
                ),
            ],
            onChanged: (categoryIdentifier) =>
                setState(() => _categoryIdentifier = categoryIdentifier),
          ),
          const SizedBox(height: FoodieSpacing.large),
          Text(localizations.unitLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: FoodieSpacing.small),
          SegmentedButton<QuantityUnit>(
            segments: [
              for (final unit in QuantityUnit.values)
                ButtonSegment(value: unit, label: Text(quantityFormatter.unitName(unit))),
            ],
            selected: {_unit},
            showSelectedIcon: false,
            onSelectionChanged: _isNewProduct
                ? (selection) => setState(() => _unit = selection.single)
                : null,
          ),
          if (!_isNewProduct)
            Padding(
              padding: const EdgeInsets.only(top: FoodieSpacing.extraSmall),
              child: Text(
                localizations.unitLockedHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: FoodieSpacing.large),
          TextField(
            controller: _packageSizeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: localizations.packageSizeLabel,
              helperText: localizations.packageSizeHelper,
              suffixText: quantityFormatter.unitSymbol(_unit),
              errorText: _packageSizeError,
            ),
          ),
          const SizedBox(height: FoodieSpacing.medium),
          TextField(
            controller: _storageMonthsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: localizations.storageMonthsLabel,
              helperText: selectedCategory == null
                  ? null
                  : localizations.storageMonthsHelper(
                      (selectedCategory.recommendedMaximumStorageDays / _averageDaysPerMonth)
                          .round(),
                    ),
              helperMaxLines: 2,
              errorText: _storageMonthsError,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: FoodieSpacing.extraSmall),
            child: Text(
              localizations.storageRecommendationNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (layout != null && layout.hasStoragePlace) ...[
            const SizedBox(height: FoodieSpacing.medium),
            _DefaultCompartmentField(
              layout: layout,
              selectedCompartmentIdentifier: _activeDefaultCompartmentIdentifier(layout),
              onChanged: (compartmentIdentifier) =>
                  setState(() => _defaultCompartmentIdentifier = compartmentIdentifier),
            ),
          ],
          const SizedBox(height: FoodieSpacing.medium),
          _ProductIconField(
            emojiController: _iconController,
            categoryEmoji: selectedCategory?.iconEmoji,
            image: _iconImage,
            isChoosingImage: _isChoosingIconImage,
            onChooseImage: _chooseIconImage,
            onRemoveImage: () => setState(() => _iconImage = null),
          ),
          const SizedBox(height: FoodieSpacing.large),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: Text(context.commonLocalizations.actionSave),
          ),
        ],
      ),
    );
  }
}

/// Picks the drawer a new batch of the product goes into, or none.
class _DefaultCompartmentField extends StatelessWidget {
  const _DefaultCompartmentField({
    required this.layout,
    required this.selectedCompartmentIdentifier,
    required this.onChanged,
  });

  final StorageLayout layout;
  final CompartmentIdentifier? selectedCompartmentIdentifier;
  final ValueChanged<CompartmentIdentifier?> onChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = ProductCatalogLocalizations.of(context);
    final nameResolver = context.compartmentDisplayNameResolver(layout);
    return DropdownButtonFormField<CompartmentIdentifier?>(
      // Rebuilt when the choice changes from outside, for example on load.
      key: ValueKey(selectedCompartmentIdentifier),
      initialValue: selectedCompartmentIdentifier,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: localizations.defaultCompartmentLabel,
        helperText: localizations.defaultCompartmentHelper,
        helperMaxLines: 2,
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(localizations.defaultCompartmentNone)),
        for (final compartment in layout.activeCompartments)
          DropdownMenuItem(
            value: compartment.identifier,
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: CompartmentColorPalette.colorAt(compartment.colorTagIndex),
                ),
                const SizedBox(width: FoodieSpacing.small),
                Expanded(
                  child: Text(
                    nameResolver.compartmentNameWithStoragePlace(compartment),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// The product's icon: an emoji, or a picture chosen from a file, which is
/// shown instead of the emoji wherever there is room for a picture.
class _ProductIconField extends StatelessWidget {
  const _ProductIconField({
    required this.emojiController,
    required this.categoryEmoji,
    required this.image,
    required this.isChoosingImage,
    required this.onChooseImage,
    required this.onRemoveImage,
  });

  static const double _previewSize = 56;

  final TextEditingController emojiController;
  final String? categoryEmoji;
  final ProductIconImage? image;
  final bool isChoosingImage;
  final VoidCallback onChooseImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final localizations = ProductCatalogLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: emojiController,
              builder: (context, emojiValue, _) {
                final typedEmoji = emojiValue.text.trim();
                return ProductIcon(
                  emoji: typedEmoji.isNotEmpty ? typedEmoji : categoryEmoji ?? '',
                  image: image,
                  size: _previewSize,
                );
              },
            ),
            const SizedBox(width: FoodieSpacing.medium),
            Expanded(
              child: TextField(
                controller: emojiController,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: localizations.iconLabel,
                  hintText: categoryEmoji,
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: FoodieSpacing.small,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: isChoosingImage ? null : onChooseImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(localizations.iconImageChoose),
            ),
            if (image != null)
              TextButton(onPressed: onRemoveImage, child: Text(localizations.iconImageRemove)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: FoodieSpacing.extraSmall),
          child: Text(localizations.iconImageHint, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
