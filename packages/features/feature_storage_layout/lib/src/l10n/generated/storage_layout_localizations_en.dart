// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'storage_layout_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class StorageLayoutLocalizationsEn extends StorageLayoutLocalizations {
  StorageLayoutLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get configSectionTitle => 'Storage places';

  @override
  String get layoutOverviewTitle => 'Storage places';

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
  String get addStoragePlaceButton => 'Add storage place';

  @override
  String get newStoragePlaceTitle => 'Add a storage place';

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
  String get compartmentNameTaken => 'Another compartment already has this name.';

  @override
  String get storagePlaceNameTaken => 'Another storage place already has this name.';

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
  String get lastCompartmentHint => 'A storage place needs at least one compartment.';

  @override
  String get layoutHint =>
      'Untouched names follow the app language. Names you type stay as you wrote them.';

  @override
  String get renameStoragePlaceAction => 'Rename';

  @override
  String get renameStoragePlaceDialogTitle => 'Rename storage place';

  @override
  String get removeStoragePlaceAction => 'Remove storage place';

  @override
  String removeStoragePlaceDialogTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeStoragePlaceDialogText =>
      'It disappears from the app. Its compartments are kept for your statistics.';

  @override
  String storagePlaceNotEmpty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Take out or move the $count items in here first.',
      one: 'Take out or move the 1 item in here first.',
    );
    return '$_temp0';
  }

  @override
  String get lastStoragePlaceCannotBeRemoved => 'You need at least one storage place.';

  @override
  String get storagePlaceNotFound => 'This storage place was removed.';

  @override
  String get noStoragePlaceTitle => 'No storage place yet';

  @override
  String get noStoragePlaceMessage =>
      'Add where you keep things and how it is divided, then start filling it.';

  @override
  String get genericFailure => 'That did not work. Please try again.';
}
