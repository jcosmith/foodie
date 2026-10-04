// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'household_supplies_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class HouseholdSuppliesLocalizationsDe extends HouseholdSuppliesLocalizations {
  HouseholdSuppliesLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get domainLabel => 'Haushalt';

  @override
  String get domainDescription => 'Putzen, Wäsche, Bad und Küchenpapier';

  @override
  String get storedOnLabel => 'Gekauft am';

  @override
  String get addTitle => 'Vorräte hinzufügen';

  @override
  String get bestBeforeLabel => 'Haltbar bis';

  @override
  String get cleaningCupboardName => 'Putzschrank';

  @override
  String get cleaningCupboardDescription => 'Putzschrank';

  @override
  String get bathroomCabinetName => 'Badschrank';

  @override
  String get bathroomCabinetDescription => 'Badschrank';

  @override
  String get laundryRoomName => 'Waschküche';

  @override
  String get laundryRoomDescription => 'Waschküche';

  @override
  String get gardenShedName => 'Gartenhaus';

  @override
  String get gardenShedDescription => 'Gartenhaus';

  @override
  String get garageName => 'Garage';

  @override
  String get garageDescription => 'Garage';

  @override
  String get storageRoomName => 'Abstellraum';

  @override
  String get storageRoomDescription => 'Abstellraum';

  @override
  String get firstAidBoxName => 'Erste-Hilfe-Box';

  @override
  String get firstAidBoxDescription => 'Erste-Hilfe-Box';

  @override
  String shelfName(int number) {
    return 'Regal $number';
  }

  @override
  String shelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Regale',
      one: '1 Regal',
    );
    return '$_temp0';
  }

  @override
  String get addShelf => 'Regal hinzufügen';

  @override
  String boxName(int number) {
    return 'Box $number';
  }

  @override
  String boxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Boxen',
      one: '1 Box',
    );
    return '$_temp0';
  }

  @override
  String get addBox => 'Box hinzufügen';

  @override
  String get templateCleaningCupboard => 'Putzschrank mit 3 Regalen';

  @override
  String get templateBathroomCabinet => 'Badschrank mit 3 Regalen';

  @override
  String get templateLaundryRoom => 'Waschküche mit 2 Regalen';

  @override
  String get templateGardenShed => 'Gartenhaus mit 2 Regalen';

  @override
  String get templateGarage => 'Garage mit 3 Regalen';

  @override
  String get templateStorageRoom => 'Abstellraum mit 4 Regalen';

  @override
  String get templateFirstAidBox => 'Eine Erste-Hilfe-Box';

  @override
  String get categoryCleaning => 'Putzen';

  @override
  String get categoryLaundry => 'Wäsche';

  @override
  String get categoryBathroomAndCare => 'Bad und Körperpflege';

  @override
  String get categoryKitchenPaperAndWrap => 'Küchenpapier und Folien';

  @override
  String get productDishSoap => 'Spülmittel';

  @override
  String get productDishwasherTabs => 'Spülmaschinentabs';

  @override
  String get productAllPurposeCleaner => 'Allzweckreiniger';

  @override
  String get productGlassCleaner => 'Glasreiniger';

  @override
  String get productDescaler => 'Entkalker';

  @override
  String get productSpongesAndCloths => 'Schwämme und Tücher';

  @override
  String get productBinBags => 'Müllbeutel';

  @override
  String get productDetergent => 'Waschmittel';

  @override
  String get productSoftener => 'Weichspüler';

  @override
  String get productStainRemover => 'Fleckentferner';

  @override
  String get productToiletPaper => 'Toilettenpapier';

  @override
  String get productHandSoap => 'Handseife';

  @override
  String get productToothpaste => 'Zahnpasta';

  @override
  String get productToothbrushes => 'Zahnbürsten';

  @override
  String get productShampoo => 'Shampoo';

  @override
  String get productShowerGel => 'Duschgel';

  @override
  String get productDeodorant => 'Deo';

  @override
  String get productRazorBlades => 'Rasierklingen';

  @override
  String get productCottonPads => 'Wattepads';

  @override
  String get productSanitaryProducts => 'Hygieneartikel';

  @override
  String get productKitchenRoll => 'Küchenrolle';

  @override
  String get productTissues => 'Taschentücher';

  @override
  String get productAluminiumFoil => 'Alufolie';

  @override
  String get productClingFilm => 'Frischhaltefolie';

  @override
  String get productBakingPaper => 'Backpapier';

  @override
  String get productFreezerBags => 'Gefrierbeutel';
}
