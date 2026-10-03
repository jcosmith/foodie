// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'barcode_scanning_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class BarcodeScanningLocalizationsDe extends BarcodeScanningLocalizations {
  BarcodeScanningLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get optionalFeatureTitle => 'Barcode-Scan';

  @override
  String get optionalFeatureDetail => 'Nutzt die Kamera, nur auf diesem Telefon';

  @override
  String get quickActionScanToAdd => 'Scannen und einfrieren';

  @override
  String get quickActionScanToRemove => 'Scannen und entnehmen';

  @override
  String get scannerTitle => 'Scannen';

  @override
  String get scanModeAdd => 'Einlagern';

  @override
  String get scanModeRemove => 'Entnehmen';

  @override
  String get scannerHint => 'Barcode in den Rahmen halten';

  @override
  String get scannerPrivacy => 'Wird auf diesem Telefon erkannt. Nichts wird gesendet.';

  @override
  String get recognized => 'Erkannt';

  @override
  String amountInFreezer(String amount) {
    return '$amount eingefroren';
  }

  @override
  String weightInCode(String weight) {
    return 'Gewicht im Code: $weight';
  }

  @override
  String addToDrawer(String amount, String drawer) {
    return '$amount in $drawer legen';
  }

  @override
  String get changeDetails => 'Details ändern';

  @override
  String addedSnackbar(String amount, String product, String drawer) {
    return '$amount $product in $drawer gelegt';
  }

  @override
  String bagsInFreezer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Packungen eingefroren. Von der ältesten nehmen?',
      one: '1 Packung eingefroren. Davon nehmen?',
    );
    return '$_temp0';
  }

  @override
  String get chooseAmount => 'Menge wählen';

  @override
  String get otherBags => 'Oder eine andere Packung';

  @override
  String get notInFreezer => 'Von diesem Produkt ist nichts eingefroren.';

  @override
  String unknownCode(String code) {
    return 'Neuer Code $code. Welches Produkt ist das?';
  }

  @override
  String get chooseProduct => 'Produkt wählen';

  @override
  String get learnedCode => 'Gelernt. Beim nächsten Mal wird der Code sofort erkannt.';

  @override
  String get wrongProduct => 'Falsches Produkt?';

  @override
  String get scanNext => 'Weiter scannen';

  @override
  String get cameraPermissionDenied =>
      'Kamerazugriff ist aus. Erlaube ihn in den Einstellungen des Telefons, um zu scannen.';

  @override
  String get cameraUnavailable => 'Die Kamera lässt sich nicht starten.';

  @override
  String get productUnavailable => 'Dieses Produkt gibt es nicht mehr.';

  @override
  String get scanSeveral => 'Mehrere nacheinander';

  @override
  String unpackingListTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile zum Einräumen',
      one: '1 Teil zum Einräumen',
      zero: 'Scanne deine Einkäufe nacheinander',
    );
    return '$_temp0';
  }

  @override
  String get amountNeeded => 'Menge fehlt';

  @override
  String get noFreezerYet => 'Richte zuerst einen Gefrierschrank ein';

  @override
  String putAwayButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile einfrieren',
      one: '1 Teil einfrieren',
    );
    return '$_temp0';
  }

  @override
  String putAwaySnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile eingefroren',
      one: '1 Teil eingefroren',
    );
    return '$_temp0';
  }

  @override
  String get removeFromList => 'Von der Liste nehmen';

  @override
  String get amountDialogTitle => 'Wie viel ist es?';

  @override
  String get invalidAmount => 'Gib eine Menge über null ein.';

  @override
  String get discardListTitle => 'Gescannte Teile verwerfen?';

  @override
  String discardListMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile sind noch nicht eingefroren.',
      one: '1 Teil ist noch nicht eingefroren.',
    );
    return '$_temp0';
  }

  @override
  String get discardButton => 'Verwerfen';
}
