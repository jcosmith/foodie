import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'fridge_catalog.dart';
import 'fridge_storage_templates.dart';
import 'l10n/generated/fridge_localizations.dart';

/// Texts in the context's language, without needing the delegate in the tree.
FridgeLocalizations _texts(BuildContext context) =>
    lookupFridgeLocalizations(Localizations.localeOf(context));

StorageTemplateContribution _template(StorageTemplate template, LocalizedTextBuilder label) =>
    StorageTemplateContribution(
      identifier: template.identifier,
      sortOrder: template.sortOrder,
      compartmentCount: template.compartmentCount,
      labelBuilder: label,
    );

/// The Fridge domain: its switch and tab, its kinds of fridge with their
/// templates, and the seeded fresh-food catalog. Best-before dates, opened
/// packages and short shelf lives are handled by the inventory and the
/// catalog; this module only brings kinds, products and words.
final class FridgeFeatureModule extends FeatureModuleBase {
  const FridgeFeatureModule();

  static const String identifier = 'fridge';

  @override
  String get moduleIdentifier => identifier;

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: true);

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    FridgeLocalizations.delegate,
  ];

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => _texts(context).domainLabel,
    detailBuilder: (context) => _texts(context).domainDescription,
  );

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: StorageDomainIdentifier.fridge,
    sortOrder: 20,
    iconEmoji: '🧊',
    labelBuilder: (context) => _texts(context).domainLabel,
    descriptionBuilder: (context) => _texts(context).domainDescription,
    storedOnLabelBuilder: (context) => _texts(context).storedOnLabel,
    addTitleBuilder: (context) => _texts(context).addTitle,
    bestBeforeLabelBuilder: (context) => _texts(context).bestBeforeLabel,
    countsDiscardsAsWaste: true,
  );

  @override
  NavigationDestinationContribution get navigationDestination => NavigationDestinationContribution(
    sortOrder: storageDomain.sortOrder,
    iconEmoji: storageDomain.iconEmoji,
    labelBuilder: storageDomain.labelBuilder,
    initialLocation: ShellRoutePaths.domainTab(StorageDomainIdentifier.fridge),
    routes: [
      GoRoute(
        path: ShellRoutePaths.domainTab(StorageDomainIdentifier.fridge),
        builder: (context, state) =>
            const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.fridge),
      ),
    ],
  );

  @override
  List<StorageKindContribution> get storageKinds => [
    StorageKindContribution(
      storageName: FridgeStorageKinds.fridge.storageName,
      domainIdentifier: StorageDomainIdentifier.fridge,
      sortOrder: 200,
      iconEmoji: '🧊',
      placeNameBuilder: (context) => _texts(context).fridgeName,
      kindDescriptionBuilder: (context) => _texts(context).fridgeDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          FridgeStorageTemplates.threeShelves,
          (context) => _texts(context).templateThreeShelves,
        ),
        _template(
          FridgeStorageTemplates.fiveShelves,
          (context) => _texts(context).templateFiveShelves,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: FridgeStorageKinds.drinksFridge.storageName,
      domainIdentifier: StorageDomainIdentifier.fridge,
      sortOrder: 210,
      iconEmoji: '🧃',
      placeNameBuilder: (context) => _texts(context).drinksFridgeName,
      kindDescriptionBuilder: (context) => _texts(context).drinksFridgeDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(FridgeStorageTemplates.drinks, (context) => _texts(context).templateDrinks),
      ],
    ),
    StorageKindContribution(
      storageName: FridgeStorageKinds.wineFridge.storageName,
      domainIdentifier: StorageDomainIdentifier.fridge,
      sortOrder: 220,
      iconEmoji: '🍷',
      placeNameBuilder: (context) => _texts(context).wineFridgeName,
      kindDescriptionBuilder: (context) => _texts(context).wineFridgeDescription,
      compartmentNameBuilder: (context, number) => _texts(context).rackName(number),
      compartmentCountBuilder: (context, count) => _texts(context).rackCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addRack,
      templates: [
        _template(FridgeStorageTemplates.wine, (context) => _texts(context).templateWine),
      ],
    ),
  ];

  @override
  CatalogContribution get catalog => const CatalogContribution(
    categories: FridgeCatalog.categories,
    products: FridgeCatalog.products,
    categoryNameBuilder: _categoryName,
    productNameBuilder: _productName,
  );
}

String? _categoryName(Locale locale, String catalogKey) {
  final texts = lookupFridgeLocalizations(locale);
  return switch (catalogKey) {
    'dairy' => texts.categoryDairy,
    'freshProduce' => texts.categoryFreshProduce,
    'freshMeatAndFish' => texts.categoryFreshMeatAndFish,
    'leftovers' => texts.categoryLeftovers,
    'chilledOther' => texts.categoryChilledOther,
    _ => null,
  };
}

String? _productName(Locale locale, String catalogKey) {
  final texts = lookupFridgeLocalizations(locale);
  return switch (catalogKey) {
    'milk' => texts.productMilk,
    'yoghurt' => texts.productYoghurt,
    'cream' => texts.productCream,
    'slicedCheese' => texts.productSlicedCheese,
    'mozzarella' => texts.productMozzarella,
    'eggs' => texts.productEggs,
    'lettuce' => texts.productLettuce,
    'tomatoes' => texts.productTomatoes,
    'cucumber' => texts.productCucumber,
    'freshHerbs' => texts.productFreshHerbs,
    'freshMincedMeat' => texts.productFreshMincedMeat,
    'freshChickenBreast' => texts.productFreshChickenBreast,
    'freshFish' => texts.productFreshFish,
    'coldCuts' => texts.productColdCuts,
    'leftovers' => texts.productLeftovers,
    'pesto' => texts.productPesto,
    _ => null,
  };
}
