import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'freezer_catalog.dart';
import 'freezer_storage_templates.dart';
import 'l10n/generated/freezer_localizations.dart';

/// Texts in the context's language, without needing the delegate in the tree.
FreezerLocalizations _texts(BuildContext context) =>
    lookupFreezerLocalizations(Localizations.localeOf(context));

StorageTemplateContribution _template(StorageTemplate template, LocalizedTextBuilder label) =>
    StorageTemplateContribution(
      identifier: template.identifier,
      sortOrder: template.sortOrder,
      compartmentCount: template.compartmentCount,
      labelBuilder: label,
    );

/// The Freezer domain: its switch, its kinds of freezer with their
/// templates, and the seeded frozen-food catalog.
final class FreezerFeatureModule extends FeatureModuleBase {
  const FreezerFeatureModule();

  static const String identifier = 'freezer';

  @override
  String get moduleIdentifier => identifier;

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: true);

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    FreezerLocalizations.delegate,
  ];

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => _texts(context).domainLabel,
    detailBuilder: (context) => _texts(context).domainDescription,
  );

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: StorageDomainIdentifier.freezer,
    sortOrder: 10,
    iconEmoji: '❄️',
    labelBuilder: (context) => _texts(context).domainLabel,
    descriptionBuilder: (context) => _texts(context).domainDescription,
    storedOnLabelBuilder: (context) => _texts(context).storedOnLabel,
    countsDiscardsAsWaste: true,
  );

  @override
  NavigationDestinationContribution get navigationDestination => NavigationDestinationContribution(
    sortOrder: storageDomain.sortOrder,
    iconEmoji: storageDomain.iconEmoji,
    labelBuilder: storageDomain.labelBuilder,
    initialLocation: ShellRoutePaths.domainTab(StorageDomainIdentifier.freezer),
    routes: [
      GoRoute(
        path: ShellRoutePaths.domainTab(StorageDomainIdentifier.freezer),
        builder: (context, state) =>
            const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.freezer),
      ),
    ],
  );

  @override
  List<StorageKindContribution> get storageKinds => [
    StorageKindContribution(
      storageName: FreezerStorageKinds.upright.storageName,
      domainIdentifier: StorageDomainIdentifier.freezer,
      sortOrder: 100,
      iconEmoji: '🧊',
      placeNameBuilder: (context) => _texts(context).uprightName,
      kindDescriptionBuilder: (context) => _texts(context).uprightDescription,
      compartmentNameBuilder: (context, number) => _texts(context).drawerName(number),
      compartmentCountBuilder: (context, count) => _texts(context).drawerCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addDrawer,
      templates: [
        _template(
          FreezerStorageTemplates.uprightWithThreeDrawers,
          (context) => _texts(context).templateUprightWithThreeDrawers,
        ),
        _template(
          FreezerStorageTemplates.uprightWithFiveDrawers,
          (context) => _texts(context).templateUprightWithFiveDrawers,
        ),
        _template(
          FreezerStorageTemplates.uprightWithSevenDrawers,
          (context) => _texts(context).templateUprightWithSevenDrawers,
        ),
        _template(FreezerStorageTemplates.empty, (context) => _texts(context).templateEmpty),
      ],
    ),
    StorageKindContribution(
      storageName: FreezerStorageKinds.chest.storageName,
      domainIdentifier: StorageDomainIdentifier.freezer,
      sortOrder: 110,
      iconEmoji: '🧊',
      placeNameBuilder: (context) => _texts(context).chestName,
      kindDescriptionBuilder: (context) => _texts(context).chestDescription,
      compartmentNameBuilder: (context, number) => _texts(context).basketName(number),
      compartmentCountBuilder: (context, count) => _texts(context).basketCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addBasket,
      templates: [
        _template(
          FreezerStorageTemplates.chestWithBaskets,
          (context) => _texts(context).templateChestWithBaskets,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: FreezerStorageKinds.fridgeFreezerCompartment.storageName,
      domainIdentifier: StorageDomainIdentifier.freezer,
      sortOrder: 120,
      iconEmoji: '🧊',
      placeNameBuilder: (context) => _texts(context).fridgeFreezerName,
      kindDescriptionBuilder: (context) => _texts(context).fridgeFreezerDescription,
      compartmentNameBuilder: (context, number) => _texts(context).compartmentName(number),
      compartmentCountBuilder: (context, count) => _texts(context).compartmentCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addCompartment,
      templates: [
        _template(
          FreezerStorageTemplates.fridgeFreezerCompartment,
          (context) => _texts(context).templateFridgeFreezerCompartment,
        ),
      ],
    ),
  ];

  @override
  CatalogContribution get catalog => const CatalogContribution(
    categories: FreezerCatalog.categories,
    products: FreezerCatalog.products,
    categoryNameBuilder: _categoryName,
    productNameBuilder: _productName,
  );
}

String? _categoryName(Locale locale, String catalogKey) {
  final texts = lookupFreezerLocalizations(locale);
  return switch (catalogKey) {
    'vegetables' => texts.categoryVegetables,
    'fruit' => texts.categoryFruit,
    'meatAndFish' => texts.categoryMeatAndFish,
    'meals' => texts.categoryMeals,
    'bakery' => texts.categoryBakery,
    'desserts' => texts.categoryDesserts,
    'other' => texts.categoryOther,
    _ => null,
  };
}

String? _productName(Locale locale, String catalogKey) {
  final texts = lookupFreezerLocalizations(locale);
  return switch (catalogKey) {
    'leafSpinach' => texts.productLeafSpinach,
    'gardenPeas' => texts.productGardenPeas,
    'broccoli' => texts.productBroccoli,
    'mixedVegetables' => texts.productMixedVegetables,
    'herbs' => texts.productHerbs,
    'frenchFries' => texts.productFrenchFries,
    'mixedBerries' => texts.productMixedBerries,
    'strawberries' => texts.productStrawberries,
    'mango' => texts.productMango,
    'chickenBreast' => texts.productChickenBreast,
    'mincedMeat' => texts.productMincedMeat,
    'salmonFillet' => texts.productSalmonFillet,
    'fishFingers' => texts.productFishFingers,
    'prawns' => texts.productPrawns,
    'bologneseHomemade' => texts.productBologneseHomemade,
    'soupHomemade' => texts.productSoupHomemade,
    'lasagne' => texts.productLasagne,
    'pizzaMargherita' => texts.productPizzaMargherita,
    'wholegrainBread' => texts.productWholegrainBread,
    'breadRolls' => texts.productBreadRolls,
    'croissants' => texts.productCroissants,
    'vanillaIceCream' => texts.productVanillaIceCream,
    'cake' => texts.productCake,
    'butter' => texts.productButter,
    _ => null,
  };
}
