import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'household_supplies_catalog.dart';
import 'household_supplies_storage_templates.dart';
import 'l10n/generated/household_supplies_localizations.dart';

/// Texts in the context's language, without needing the delegate in the tree.
HouseholdSuppliesLocalizations _texts(BuildContext context) =>
    lookupHouseholdSuppliesLocalizations(Localizations.localeOf(context));

StorageTemplateContribution _template(StorageTemplate template, LocalizedTextBuilder label) =>
    StorageTemplateContribution(
      identifier: template.identifier,
      sortOrder: template.sortOrder,
      compartmentCount: template.compartmentCount,
      labelBuilder: label,
    );

/// The Household domain, in its basic form (architecture 10.9): its switch
/// and tab, off until switched on, the places supplies are kept with their
/// templates, and a small seeded catalog. Supplies keep no shelf life and
/// throwing them away is never food waste; quantities, minimums and the
/// shopping list work for them as for food.
final class HouseholdSuppliesFeatureModule extends FeatureModuleBase {
  const HouseholdSuppliesFeatureModule();

  static const String identifier = 'household';

  @override
  String get moduleIdentifier => identifier;

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: false);

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    HouseholdSuppliesLocalizations.delegate,
  ];

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => _texts(context).domainLabel,
    detailBuilder: (context) => _texts(context).domainDescription,
  );

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: StorageDomainIdentifier.household,
    sortOrder: 40,
    iconEmoji: '🧴',
    labelBuilder: (context) => _texts(context).domainLabel,
    descriptionBuilder: (context) => _texts(context).domainDescription,
    storedOnLabelBuilder: (context) => _texts(context).storedOnLabel,
    addTitleBuilder: (context) => _texts(context).addTitle,
    bestBeforeLabelBuilder: (context) => _texts(context).bestBeforeLabel,
    countsDiscardsAsWaste: false,
  );

  @override
  NavigationDestinationContribution get navigationDestination => NavigationDestinationContribution(
    sortOrder: storageDomain.sortOrder,
    iconEmoji: storageDomain.iconEmoji,
    labelBuilder: storageDomain.labelBuilder,
    initialLocation: ShellRoutePaths.domainTab(StorageDomainIdentifier.household),
    routes: [
      GoRoute(
        path: ShellRoutePaths.domainTab(StorageDomainIdentifier.household),
        builder: (context, state) =>
            const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.household),
      ),
    ],
  );

  @override
  List<StorageKindContribution> get storageKinds => [
    StorageKindContribution(
      storageName: HouseholdSuppliesStorageKinds.cleaningCupboard.storageName,
      domainIdentifier: StorageDomainIdentifier.household,
      sortOrder: 400,
      iconEmoji: '🧹',
      placeNameBuilder: (context) => _texts(context).cleaningCupboardName,
      kindDescriptionBuilder: (context) => _texts(context).cleaningCupboardDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          HouseholdSuppliesStorageTemplates.cleaningCupboard,
          (context) => _texts(context).templateCleaningCupboard,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: HouseholdSuppliesStorageKinds.bathroomCabinet.storageName,
      domainIdentifier: StorageDomainIdentifier.household,
      sortOrder: 410,
      iconEmoji: '🪥',
      placeNameBuilder: (context) => _texts(context).bathroomCabinetName,
      kindDescriptionBuilder: (context) => _texts(context).bathroomCabinetDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          HouseholdSuppliesStorageTemplates.bathroomCabinet,
          (context) => _texts(context).templateBathroomCabinet,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: HouseholdSuppliesStorageKinds.laundryRoom.storageName,
      domainIdentifier: StorageDomainIdentifier.household,
      sortOrder: 420,
      iconEmoji: '🧺',
      placeNameBuilder: (context) => _texts(context).laundryRoomName,
      kindDescriptionBuilder: (context) => _texts(context).laundryRoomDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          HouseholdSuppliesStorageTemplates.laundryRoom,
          (context) => _texts(context).templateLaundryRoom,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: HouseholdSuppliesStorageKinds.gardenShed.storageName,
      domainIdentifier: StorageDomainIdentifier.household,
      sortOrder: 430,
      iconEmoji: '🌱',
      placeNameBuilder: (context) => _texts(context).gardenShedName,
      kindDescriptionBuilder: (context) => _texts(context).gardenShedDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          HouseholdSuppliesStorageTemplates.gardenShed,
          (context) => _texts(context).templateGardenShed,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: HouseholdSuppliesStorageKinds.garage.storageName,
      domainIdentifier: StorageDomainIdentifier.household,
      sortOrder: 440,
      iconEmoji: '🚗',
      placeNameBuilder: (context) => _texts(context).garageName,
      kindDescriptionBuilder: (context) => _texts(context).garageDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          HouseholdSuppliesStorageTemplates.garage,
          (context) => _texts(context).templateGarage,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: HouseholdSuppliesStorageKinds.storageRoom.storageName,
      domainIdentifier: StorageDomainIdentifier.household,
      sortOrder: 450,
      iconEmoji: '📦',
      placeNameBuilder: (context) => _texts(context).storageRoomName,
      kindDescriptionBuilder: (context) => _texts(context).storageRoomDescription,
      compartmentNameBuilder: (context, number) => _texts(context).shelfName(number),
      compartmentCountBuilder: (context, count) => _texts(context).shelfCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addShelf,
      templates: [
        _template(
          HouseholdSuppliesStorageTemplates.storageRoom,
          (context) => _texts(context).templateStorageRoom,
        ),
      ],
    ),
    StorageKindContribution(
      storageName: HouseholdSuppliesStorageKinds.firstAidBox.storageName,
      domainIdentifier: StorageDomainIdentifier.household,
      sortOrder: 460,
      iconEmoji: '🩹',
      placeNameBuilder: (context) => _texts(context).firstAidBoxName,
      kindDescriptionBuilder: (context) => _texts(context).firstAidBoxDescription,
      compartmentNameBuilder: (context, number) => _texts(context).boxName(number),
      compartmentCountBuilder: (context, count) => _texts(context).boxCount(count),
      addCompartmentLabelBuilder: (context) => _texts(context).addBox,
      templates: [
        _template(
          HouseholdSuppliesStorageTemplates.firstAidBox,
          (context) => _texts(context).templateFirstAidBox,
        ),
      ],
    ),
  ];

  @override
  CatalogContribution get catalog => const CatalogContribution(
    categories: HouseholdSuppliesCatalog.categories,
    products: HouseholdSuppliesCatalog.products,
    categoryNameBuilder: _categoryName,
    productNameBuilder: _productName,
  );
}

String? _categoryName(Locale locale, String catalogKey) {
  final texts = lookupHouseholdSuppliesLocalizations(locale);
  return switch (catalogKey) {
    'cleaning' => texts.categoryCleaning,
    'laundry' => texts.categoryLaundry,
    'bathroomAndCare' => texts.categoryBathroomAndCare,
    'kitchenPaperAndWrap' => texts.categoryKitchenPaperAndWrap,
    _ => null,
  };
}

String? _productName(Locale locale, String catalogKey) {
  final texts = lookupHouseholdSuppliesLocalizations(locale);
  return switch (catalogKey) {
    'dishSoap' => texts.productDishSoap,
    'dishwasherTabs' => texts.productDishwasherTabs,
    'allPurposeCleaner' => texts.productAllPurposeCleaner,
    'glassCleaner' => texts.productGlassCleaner,
    'descaler' => texts.productDescaler,
    'spongesAndCloths' => texts.productSpongesAndCloths,
    'binBags' => texts.productBinBags,
    'detergent' => texts.productDetergent,
    'softener' => texts.productSoftener,
    'stainRemover' => texts.productStainRemover,
    'toiletPaper' => texts.productToiletPaper,
    'handSoap' => texts.productHandSoap,
    'toothpaste' => texts.productToothpaste,
    'toothbrushes' => texts.productToothbrushes,
    'shampoo' => texts.productShampoo,
    'showerGel' => texts.productShowerGel,
    'deodorant' => texts.productDeodorant,
    'razorBlades' => texts.productRazorBlades,
    'cottonPads' => texts.productCottonPads,
    'sanitaryProducts' => texts.productSanitaryProducts,
    'kitchenRoll' => texts.productKitchenRoll,
    'tissues' => texts.productTissues,
    'aluminiumFoil' => texts.productAluminiumFoil,
    'clingFilm' => texts.productClingFilm,
    'bakingPaper' => texts.productBakingPaper,
    'freezerBags' => texts.productFreezerBags,
    _ => null,
  };
}
