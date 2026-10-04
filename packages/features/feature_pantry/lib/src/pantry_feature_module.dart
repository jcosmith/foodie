import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'l10n/generated/pantry_localizations.dart';
import 'pantry_catalog.dart';
import 'pantry_storage_templates.dart';

/// Texts in the context's language, without needing the delegate in the tree.
PantryLocalizations _texts(BuildContext context) =>
    lookupPantryLocalizations(Localizations.localeOf(context));

StorageTemplateContribution _template(StorageTemplate template, LocalizedTextBuilder label) =>
    StorageTemplateContribution(
      identifier: template.identifier,
      sortOrder: template.sortOrder,
      compartmentCount: template.compartmentCount,
      labelBuilder: label,
    );

/// The Pantry domain: its switch and tab, the pantry, kitchen cupboard,
/// cellar and drinks crate with their templates, and the seeded catalog of
/// bread, dry goods, tins, spices, drinks and snacks.
final class PantryFeatureModule extends FeatureModuleBase {
  const PantryFeatureModule();

  static const String identifier = 'pantry';

  @override
  String get moduleIdentifier => identifier;

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: true);

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    PantryLocalizations.delegate,
  ];

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => _texts(context).domainLabel,
    detailBuilder: (context) => _texts(context).domainDescription,
  );

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: StorageDomainIdentifier.pantry,
    sortOrder: 30,
    iconEmoji: '🥫',
    labelBuilder: (context) => _texts(context).domainLabel,
    descriptionBuilder: (context) => _texts(context).domainDescription,
    storedOnLabelBuilder: (context) => _texts(context).storedOnLabel,
    addTitleBuilder: (context) => _texts(context).addTitle,
    countsDiscardsAsWaste: true,
  );

  @override
  NavigationDestinationContribution get navigationDestination => NavigationDestinationContribution(
    sortOrder: storageDomain.sortOrder,
    iconEmoji: storageDomain.iconEmoji,
    labelBuilder: storageDomain.labelBuilder,
    initialLocation: ShellRoutePaths.domainTab(StorageDomainIdentifier.pantry),
    routes: [
      GoRoute(
        path: ShellRoutePaths.domainTab(StorageDomainIdentifier.pantry),
        builder: (context, state) =>
            const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.pantry),
      ),
    ],
  );

  @override
  List<StorageKindContribution> get storageKinds => [
    StorageKindContribution(
      storageName: PantryStorageKinds.pantry.storageName,
      domainIdentifier: StorageDomainIdentifier.pantry,
      sortOrder: 300,
      iconEmoji: '🥫',
      placeNameBuilder: (context) => _texts(context).pantryName,
      kindDescriptionBuilder: (context) => _texts(context).pantryDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          PantryStorageTemplates.pantryShelves,
          (context) => _texts(context).templatePantryShelves,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: PantryStorageKinds.kitchenCupboard.storageName,
      domainIdentifier: StorageDomainIdentifier.pantry,
      sortOrder: 310,
      iconEmoji: '🗄️',
      placeNameBuilder: (context) => _texts(context).kitchenCupboardName,
      kindDescriptionBuilder: (context) => _texts(context).kitchenCupboardDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          PantryStorageTemplates.kitchenCupboard,
          (context) => _texts(context).templateKitchenCupboard,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: PantryStorageKinds.cellar.storageName,
      domainIdentifier: StorageDomainIdentifier.pantry,
      sortOrder: 320,
      iconEmoji: '🏚️',
      placeNameBuilder: (context) => _texts(context).cellarName,
      kindDescriptionBuilder: (context) => _texts(context).cellarDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(PantryStorageTemplates.cellar, (context) => _texts(context).templateCellar),
      ],
    ),
    StorageKindContribution(
      storageName: PantryStorageKinds.drinksCrate.storageName,
      domainIdentifier: StorageDomainIdentifier.pantry,
      sortOrder: 330,
      iconEmoji: '🍾',
      placeNameBuilder: (context) => _texts(context).drinksCrateName,
      kindDescriptionBuilder: (context) => _texts(context).drinksCrateDescription,
      compartmentNameBuilder: (context, number) => _texts(context).crateName(number),
      compartmentCountBuilder: (context, count) => _texts(context).crateCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addCrate,
      templates: [
        _template(
          PantryStorageTemplates.drinksCrate,
          (context) => _texts(context).templateDrinksCrate,
        ),
      ],
    ),
  ];

  @override
  CatalogContribution get catalog => const CatalogContribution(
    categories: PantryCatalog.categories,
    products: PantryCatalog.products,
    categoryNameBuilder: _categoryName,
    productNameBuilder: _productName,
  );
}

String? _categoryName(Locale locale, String catalogKey) {
  final texts = lookupPantryLocalizations(locale);
  return switch (catalogKey) {
    'breadAndBakery' => texts.categoryBreadAndBakery,
    'dryGoods' => texts.categoryDryGoods,
    'tinsAndJars' => texts.categoryTinsAndJars,
    'spicesAndCondiments' => texts.categorySpicesAndCondiments,
    'oilsAndVinegar' => texts.categoryOilsAndVinegar,
    'baking' => texts.categoryBaking,
    'breakfastAndSpreads' => texts.categoryBreakfastAndSpreads,
    'snacks' => texts.categorySnacks,
    'drinks' => texts.categoryDrinks,
    _ => null,
  };
}

String? _productName(Locale locale, String catalogKey) {
  final texts = lookupPantryLocalizations(locale);
  return switch (catalogKey) {
    'freshBread' => texts.productFreshBread,
    'toastBread' => texts.productToastBread,
    'pasta' => texts.productPasta,
    'rice' => texts.productRice,
    'oats' => texts.productOats,
    'cannedTomatoes' => texts.productCannedTomatoes,
    'chickpeas' => texts.productChickpeas,
    'tuna' => texts.productTuna,
    'salt' => texts.productSalt,
    'pepper' => texts.productPepper,
    'ketchup' => texts.productKetchup,
    'mustard' => texts.productMustard,
    'oliveOil' => texts.productOliveOil,
    'vinegar' => texts.productVinegar,
    'flour' => texts.productFlour,
    'sugar' => texts.productSugar,
    'cornflakes' => texts.productCornflakes,
    'jam' => texts.productJam,
    'honey' => texts.productHoney,
    'chocolateSpread' => texts.productChocolateSpread,
    'crisps' => texts.productCrisps,
    'biscuits' => texts.productBiscuits,
    'mineralWater' => texts.productMineralWater,
    'orangeJuice' => texts.productOrangeJuice,
    _ => null,
  };
}
