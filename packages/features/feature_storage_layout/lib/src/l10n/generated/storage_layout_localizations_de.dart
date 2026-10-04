// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'storage_layout_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class StorageLayoutLocalizationsDe extends StorageLayoutLocalizations {
  StorageLayoutLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get configSectionTitle => 'Aufteilung';

  @override
  String get layoutOverviewTitle => 'Aufteilung';

  @override
  String defaultStoragePlaceName(String storageKind) {
    String _temp0 = intl.Intl.selectLogic(storageKind, {
      'chest': 'Gefriertruhe',
      'fridgeFreezerCompartment': 'Gefrierfach',
      'other': 'Gefrierschrank',
    });
    return '$_temp0';
  }

  @override
  String defaultCompartmentName(String storageKind, int number) {
    String _temp0 = intl.Intl.selectLogic(storageKind, {
      'chest': 'Korb $number',
      'fridgeFreezerCompartment': 'Fach $number',
      'other': 'Schublade $number',
    });
    return '$_temp0';
  }

  @override
  String removedName(String name) {
    return '$name (entfernt)';
  }

  @override
  String storageKindDescription(String storageKind) {
    String _temp0 = intl.Intl.selectLogic(storageKind, {
      'chest': 'Truhe',
      'fridgeFreezerCompartment': 'im Kühlschrank',
      'other': 'stehend',
    });
    return '$_temp0';
  }

  @override
  String drawerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schubladen',
      one: '1 Schublade',
    );
    return '$_temp0';
  }

  @override
  String basketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Körbe',
      one: '1 Korb',
    );
    return '$_temp0';
  }

  @override
  String shelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fächer',
      one: '1 Fach',
    );
    return '$_temp0';
  }

  @override
  String storagePlaceSummary(String kind, String compartments) {
    return '$kind · $compartments';
  }

  @override
  String get addStoragePlaceButton => 'Gefriergerät hinzufügen';

  @override
  String get newStoragePlaceTitle => 'Gefriergerät hinzufügen';

  @override
  String get templatePrompt => 'Was kommt deinem am nächsten? Du kannst später alles ändern.';

  @override
  String get templateUprightWithThreeDrawers => 'Gefrierschrank mit 3 Schubladen';

  @override
  String get templateUprightWithFiveDrawers => 'Gefrierschrank mit 5 Schubladen';

  @override
  String get templateUprightWithSevenDrawers => 'Gefrierschrank mit 7 Schubladen';

  @override
  String get templateChestWithBaskets => 'Gefriertruhe mit 3 Körben';

  @override
  String get templateFridgeFreezerCompartment => 'Gefrierfach im Kühlschrank';

  @override
  String get templateEmpty => 'Mit einer Schublade beginnen und den Rest selbst anlegen';

  @override
  String get storagePlaceNameLabel => 'Name (optional)';

  @override
  String storagePlaceNameHelper(String defaultName) {
    return 'Zum Beispiel „Küche“ oder „Keller“. Leer lassen für „$defaultName“.';
  }

  @override
  String addCompartmentButton(String storageKind) {
    String _temp0 = intl.Intl.selectLogic(storageKind, {
      'chest': 'Korb hinzufügen',
      'fridgeFreezerCompartment': 'Fach hinzufügen',
      'other': 'Schublade hinzufügen',
    });
    return '$_temp0';
  }

  @override
  String compartmentItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '1 Produkt',
      zero: 'Leer',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Nach oben';

  @override
  String get moveDown => 'Nach unten';

  @override
  String get removeCompartment => 'Entfernen';

  @override
  String get changeColor => 'Farbe ändern';

  @override
  String get compartmentNameTaken => 'Eine andere Schublade heißt schon so.';

  @override
  String get storagePlaceNameTaken => 'Ein anderes Gefriergerät heißt schon so.';

  @override
  String get nameTooLong => 'Höchstens 30 Zeichen.';

  @override
  String removeCompartmentDialogTitle(String name) {
    return '$name entfernen?';
  }

  @override
  String removeCompartmentDialogText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Darin sind $count Produkte. Wohin sollen sie?',
      one: 'Darin ist 1 Produkt. Wohin soll es?',
    );
    return '$_temp0';
  }

  @override
  String get moveDestinationLabel => 'Verschieben nach';

  @override
  String get moveAndRemoveButton => 'Verschieben und entfernen';

  @override
  String removedCompartmentsNote(String names) {
    return 'Entfernt (für die Statistik behalten): $names';
  }

  @override
  String get lastCompartmentHint => 'Ein Gefriergerät braucht mindestens eine Schublade.';

  @override
  String get layoutHint =>
      'Unveränderte Namen folgen der App-Sprache. Selbst getippte Namen bleiben, wie du sie geschrieben hast.';

  @override
  String get renameStoragePlaceAction => 'Umbenennen';

  @override
  String get renameStoragePlaceDialogTitle => 'Gefriergerät umbenennen';

  @override
  String get removeStoragePlaceAction => 'Gefriergerät entfernen';

  @override
  String removeStoragePlaceDialogTitle(String name) {
    return '$name entfernen?';
  }

  @override
  String get removeStoragePlaceDialogText =>
      'Es verschwindet aus der App. Seine Schubladen bleiben für die Statistik erhalten.';

  @override
  String storagePlaceNotEmpty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nimm zuerst die $count Produkte heraus oder verschiebe sie.',
      one: 'Nimm zuerst das 1 Produkt heraus oder verschiebe es.',
    );
    return '$_temp0';
  }

  @override
  String get lastStoragePlaceCannotBeRemoved => 'Du brauchst mindestens ein Gefriergerät.';

  @override
  String get storagePlaceNotFound => 'Dieses Gefriergerät wurde entfernt.';

  @override
  String get noStoragePlaceTitle => 'Noch kein Gefriergerät';

  @override
  String get noStoragePlaceMessage =>
      'Lege dein Gefriergerät und seine Schubladen an und fülle es dann.';

  @override
  String get genericFailure => 'Das hat nicht geklappt. Bitte versuche es noch einmal.';
}
