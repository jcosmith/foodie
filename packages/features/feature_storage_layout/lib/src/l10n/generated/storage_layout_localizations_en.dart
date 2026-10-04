// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'storage_layout_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class StorageLayoutLocalizationsEn extends StorageLayoutLocalizations {
  StorageLayoutLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get configSectionTitle => 'Freezer layout';

  @override
  String get layoutOverviewTitle => 'Freezer layout';

  @override
  String get defaultStoragePlaceName => 'Storage place';

  @override
  String defaultCompartmentName(int number) {
    return 'Compartment $number';
  }

  @override
  String removedName(String name) {
    return '$name (removed)';
  }

  @override
  String get storageKindDescription => 'storage place';

  @override
  String compartmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count compartments',
      one: '1 compartment',
    );
    return '$_temp0';
  }

  @override
  String storagePlaceSummary(String kind, String compartments) {
    return '$kind · $compartments';
  }

  @override
  String get addStoragePlaceButton => 'Add freezer';

  @override
  String get newStoragePlaceTitle => 'Add a freezer';

  @override
  String get templatePrompt => 'Which one is closest to yours? You can change everything later.';

  @override
  String get storagePlaceNameLabel => 'Name (optional)';

  @override
  String storagePlaceNameHelper(String defaultName) {
    return 'For example \"Kitchen\" or \"Cellar\". Leave empty to use \"$defaultName\".';
  }

  @override
  String get addCompartmentButton => 'Add compartment';

  @override
  String compartmentItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get removeCompartment => 'Remove';

  @override
  String get changeColor => 'Change colour';

  @override
  String get compartmentNameTaken => 'Another drawer already has this name.';

  @override
  String get storagePlaceNameTaken => 'Another freezer already has this name.';

  @override
  String get nameTooLong => 'At most 30 characters.';

  @override
  String removeCompartmentDialogTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String removeCompartmentDialogText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It holds $count items. Where should they go?',
      one: 'It holds 1 item. Where should it go?',
    );
    return '$_temp0';
  }

  @override
  String get moveDestinationLabel => 'Move to';

  @override
  String get moveAndRemoveButton => 'Move and remove';

  @override
  String removedCompartmentsNote(String names) {
    return 'Removed (kept for your statistics): $names';
  }

  @override
  String get lastCompartmentHint => 'A freezer needs at least one drawer.';

  @override
  String get layoutHint =>
      'Untouched names follow the app language. Names you type stay as you wrote them.';

  @override
  String get renameStoragePlaceAction => 'Rename freezer';

  @override
  String get renameStoragePlaceDialogTitle => 'Rename freezer';

  @override
  String get removeStoragePlaceAction => 'Remove freezer';

  @override
  String removeStoragePlaceDialogTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeStoragePlaceDialogText =>
      'It disappears from the app. Its drawers are kept for your statistics.';

  @override
  String storagePlaceNotEmpty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Take out or move the $count items in this freezer first.',
      one: 'Take out or move the 1 item in this freezer first.',
    );
    return '$_temp0';
  }

  @override
  String get lastStoragePlaceCannotBeRemoved => 'You need at least one freezer.';

  @override
  String get storagePlaceNotFound => 'This freezer was removed.';

  @override
  String get noStoragePlaceTitle => 'No freezer yet';

  @override
  String get noStoragePlaceMessage => 'Add your freezer and its drawers, then start filling it.';

  @override
  String get genericFailure => 'That did not work. Please try again.';
}
