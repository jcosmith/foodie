// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'household_supplies_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class HouseholdSuppliesLocalizationsEn extends HouseholdSuppliesLocalizations {
  HouseholdSuppliesLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get domainLabel => 'Household';

  @override
  String get domainDescription => 'Cleaning, laundry, bathroom and kitchen paper';

  @override
  String get storedOnLabel => 'Bought on';

  @override
  String get addTitle => 'Add supplies';

  @override
  String get bestBeforeLabel => 'Expires';

  @override
  String get cleaningCupboardName => 'Cleaning cupboard';

  @override
  String get cleaningCupboardDescription => 'cleaning cupboard';

  @override
  String get bathroomCabinetName => 'Bathroom cabinet';

  @override
  String get bathroomCabinetDescription => 'bathroom cabinet';

  @override
  String get laundryRoomName => 'Laundry room';

  @override
  String get laundryRoomDescription => 'laundry room';

  @override
  String get gardenShedName => 'Garden shed';

  @override
  String get gardenShedDescription => 'garden shed';

  @override
  String get garageName => 'Garage';

  @override
  String get garageDescription => 'garage';

  @override
  String get storageRoomName => 'Storage room';

  @override
  String get storageRoomDescription => 'storage room';

  @override
  String get firstAidBoxName => 'First-aid box';

  @override
  String get firstAidBoxDescription => 'first-aid box';

  @override
  String shelfName(int number) {
    return 'Shelf $number';
  }

  @override
  String shelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shelves',
      one: '1 shelf',
    );
    return '$_temp0';
  }

  @override
  String get addShelf => 'Add shelf';

  @override
  String boxName(int number) {
    return 'Box $number';
  }

  @override
  String boxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boxes',
      one: '1 box',
    );
    return '$_temp0';
  }

  @override
  String get addBox => 'Add box';

  @override
  String get templateCleaningCupboard => 'Cleaning cupboard with 3 shelves';

  @override
  String get templateBathroomCabinet => 'Bathroom cabinet with 3 shelves';

  @override
  String get templateLaundryRoom => 'Laundry room with 2 shelves';

  @override
  String get templateGardenShed => 'Garden shed with 2 shelves';

  @override
  String get templateGarage => 'Garage with 3 shelves';

  @override
  String get templateStorageRoom => 'Storage room with 4 shelves';

  @override
  String get templateFirstAidBox => 'One first-aid box';

  @override
  String get categoryCleaning => 'Cleaning';

  @override
  String get categoryLaundry => 'Laundry';

  @override
  String get categoryBathroomAndCare => 'Bathroom and personal care';

  @override
  String get categoryKitchenPaperAndWrap => 'Kitchen paper and wrap';

  @override
  String get productDishSoap => 'Dish soap';

  @override
  String get productDishwasherTabs => 'Dishwasher tabs';

  @override
  String get productAllPurposeCleaner => 'All-purpose cleaner';

  @override
  String get productGlassCleaner => 'Glass cleaner';

  @override
  String get productDescaler => 'Descaler';

  @override
  String get productSpongesAndCloths => 'Sponges and cloths';

  @override
  String get productBinBags => 'Bin bags';

  @override
  String get productDetergent => 'Detergent';

  @override
  String get productSoftener => 'Softener';

  @override
  String get productStainRemover => 'Stain remover';

  @override
  String get productToiletPaper => 'Toilet paper';

  @override
  String get productHandSoap => 'Hand soap';

  @override
  String get productToothpaste => 'Toothpaste';

  @override
  String get productToothbrushes => 'Toothbrushes';

  @override
  String get productShampoo => 'Shampoo';

  @override
  String get productShowerGel => 'Shower gel';

  @override
  String get productDeodorant => 'Deodorant';

  @override
  String get productRazorBlades => 'Razor blades';

  @override
  String get productCottonPads => 'Cotton pads';

  @override
  String get productSanitaryProducts => 'Sanitary products';

  @override
  String get productKitchenRoll => 'Kitchen roll';

  @override
  String get productTissues => 'Tissues';

  @override
  String get productAluminiumFoil => 'Aluminium foil';

  @override
  String get productClingFilm => 'Cling film';

  @override
  String get productBakingPaper => 'Baking paper';

  @override
  String get productFreezerBags => 'Freezer bags';
}
