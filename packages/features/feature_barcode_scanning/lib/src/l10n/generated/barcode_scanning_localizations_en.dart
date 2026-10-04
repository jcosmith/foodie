// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'barcode_scanning_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class BarcodeScanningLocalizationsEn extends BarcodeScanningLocalizations {
  BarcodeScanningLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get optionalFeatureTitle => 'Barcode scanning';

  @override
  String get optionalFeatureDetail => 'Uses the camera, on this phone only';

  @override
  String get quickActionScanToAdd => 'Scan to add';

  @override
  String get quickActionScanToRemove => 'Scan to remove';

  @override
  String get scannerTitle => 'Scan';

  @override
  String get scanModeAdd => 'Add';

  @override
  String get scanModeRemove => 'Remove';

  @override
  String get scannerHint => 'Hold the barcode inside the frame';

  @override
  String get scannerPrivacy => 'Scanned on this phone. Nothing is sent anywhere.';

  @override
  String get recognized => 'Recognised';

  @override
  String amountInStoragePlace(String amount) {
    return '$amount at home';
  }

  @override
  String weightInCode(String weight) {
    return 'Weight in the code: $weight';
  }

  @override
  String addToDrawer(String amount, String drawer) {
    return 'Add $amount to $drawer';
  }

  @override
  String get changeDetails => 'Change details';

  @override
  String addedSnackbar(String amount, String product, String drawer) {
    return 'Added $amount of $product to $drawer';
  }

  @override
  String bagsInStoragePlace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs at home. Take from the oldest?',
      one: '1 pack at home. Take from it?',
    );
    return '$_temp0';
  }

  @override
  String get chooseAmount => 'Choose amount';

  @override
  String get otherBags => 'Or another bag';

  @override
  String get notInStoragePlace => 'None of this product is at home.';

  @override
  String unknownCode(String code) {
    return 'New code $code. Which product is this?';
  }

  @override
  String get chooseProduct => 'Choose product';

  @override
  String get learnedCode => 'Learned. Next time this code is recognised instantly.';

  @override
  String get wrongProduct => 'Not this product?';

  @override
  String get scanNext => 'Scan next';

  @override
  String get cameraPermissionDenied =>
      'Camera access is off. Allow it in the phone\'s settings to scan.';

  @override
  String get cameraUnavailable => 'The camera cannot be started.';

  @override
  String get productUnavailable => 'This product is no longer available.';

  @override
  String get scanSeveral => 'Several in a row';

  @override
  String unpackingListTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items to put away',
      one: '1 item to put away',
      zero: 'Scan your groceries one after another',
    );
    return '$_temp0';
  }

  @override
  String get amountNeeded => 'Amount needed';

  @override
  String get noStoragePlaceYet => 'Set up a storage place first';

  @override
  String putAwayButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Put $count items away',
      one: 'Put 1 item away',
    );
    return '$_temp0';
  }

  @override
  String putAwaySnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items put away',
      one: '1 item put away',
    );
    return '$_temp0';
  }

  @override
  String get removeFromList => 'Remove from the list';

  @override
  String get amountDialogTitle => 'How much is it?';

  @override
  String get invalidAmount => 'Enter an amount above zero.';

  @override
  String get discardListTitle => 'Discard the scanned items?';

  @override
  String discardListMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items are not put away yet.',
      one: '1 item is not put away yet.',
    );
    return '$_temp0';
  }

  @override
  String get discardButton => 'Discard';
}
