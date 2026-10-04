// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'receipt_scanning_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ReceiptScanningLocalizationsDe extends ReceiptScanningLocalizations {
  ReceiptScanningLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get optionalFeatureTitle => 'Kassenbon-Scan';

  @override
  String get optionalFeatureDetail => 'Liest Kassenbons nur auf diesem Telefon';

  @override
  String get quickActionScanReceipt => 'Kassenbon scannen';

  @override
  String get segmentTitle => 'Kassenbons';

  @override
  String get segmentSubtitle => 'Kassenbons bleiben verschlüsselt auf diesem Telefon';

  @override
  String get scanTitle => 'Kassenbon scannen';

  @override
  String get scanPrivacy => 'Wird auf diesem Telefon gelesen. Nichts wird gesendet.';

  @override
  String get scanHint =>
      'Leg den Bon flach und gut beleuchtet hin. Einen langen Bon fotografierst du in mehreren Teilen, von oben nach unten.';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get pickFromGallery => 'Aus der Galerie';

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get readReceipt => 'Bon lesen';

  @override
  String get noTextOnPhoto =>
      'Auf diesem Foto ist kein Text zu erkennen. Versuch es mit mehr Licht.';

  @override
  String get unreadablePhoto => 'Dieses Foto lässt sich nicht lesen.';

  @override
  String get noItemsFound =>
      'Auf diesem Bon wurden keine Artikel gefunden. Er wird trotzdem aufbewahrt und ist durchsuchbar.';

  @override
  String get unknownStore => 'Unbekanntes Geschäft';

  @override
  String needsYou(int count) {
    return 'Braucht dich · $count';
  }

  @override
  String recognisedSection(int count) {
    return 'Erkannt · $count';
  }

  @override
  String notAddedSection(int count) {
    return 'Nicht hinzugefügt · $count';
  }

  @override
  String get unknownLine => 'Diese Zeile kennen wir noch nicht.';

  @override
  String suggestedProduct(String product) {
    return '$product?';
  }

  @override
  String get confirmSuggestion => 'Ja';

  @override
  String get pickProduct => 'Produkt wählen';

  @override
  String get ignoreLine => 'Ignorieren';

  @override
  String get ignoreAtStore => 'Bei diesem Geschäft ignorieren';

  @override
  String get setAmountAndPlace => 'Menge und Lagerort festlegen';

  @override
  String addItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel hinzufügen',
      one: '1 Artikel hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String addedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel hinzugefügt',
      one: '1 Artikel hinzugefügt',
      zero: 'Kassenbon aufbewahrt',
    );
    return '$_temp0';
  }

  @override
  String get keepReceipt => 'Bon aufbewahren';

  @override
  String get editLineTitle => 'Menge und Lagerort';

  @override
  String amountLabel(String unit) {
    return 'Menge ($unit)';
  }

  @override
  String get compartmentLabel => 'Lagerort';

  @override
  String get invalidAmount => 'Gib eine Menge über null ein';

  @override
  String openLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen noch offen',
      one: '1 Zeile noch offen',
      zero: 'Nichts mehr offen',
    );
    return '$_temp0';
  }

  @override
  String openBadge(int count) {
    return '$count offen';
  }

  @override
  String get lineAdded => 'Hinzugefügt';

  @override
  String get lineNotAdded => 'Nicht hinzugefügt';

  @override
  String get searchHint => 'Kassenbons durchsuchen';

  @override
  String get noReceipts => 'Noch keine Kassenbons. Scanne einen über den Plus-Knopf.';

  @override
  String get noSearchHits => 'Kein Kassenbon erwähnt das.';

  @override
  String get deleteReceipt => 'Kassenbon löschen';

  @override
  String get deleteReceiptQuestion =>
      'Diesen Kassenbon löschen? Was er hinzugefügt hat, bleibt im Vorrat.';

  @override
  String get delete => 'Löschen';

  @override
  String get receiptDeleted => 'Kassenbon gelöscht';

  @override
  String get receiptGone => 'Dieser Kassenbon wurde gelöscht.';

  @override
  String lineWithPrice(String text, String price) {
    return '$text · $price';
  }

  @override
  String totalAmount(String amount) {
    return 'Summe $amount';
  }

  @override
  String pageImageLabel(int number) {
    return 'Seite $number';
  }

  @override
  String get lineNotOpen => 'Diese Zeile ist schon erledigt.';

  @override
  String get photoRetentionLabel => 'Kassenbon-Fotos behalten';

  @override
  String get photoRetentionExplanation =>
      'Der Text jedes Kassenbons bleibt durchsuchbar; ältere Fotos werden gelöscht, um Platz zu sparen.';

  @override
  String get photoRetentionForever => 'Bis ich den Kassenbon lösche';

  @override
  String photoRetentionMonths(int months) {
    return '$months Monate';
  }

  @override
  String get correctText => 'Text korrigieren';

  @override
  String get correctTextHint => 'Wie auf dem Bon gedruckt';

  @override
  String recognisedAs(String text) {
    return 'Erkannt als: $text';
  }

  @override
  String get filterAllStores => 'Alle Geschäfte';

  @override
  String get filterAnyTime => 'Jederzeit';

  @override
  String filterLastMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Letzte $months Monate',
      one: 'Letzter Monat',
    );
    return '$_temp0';
  }

  @override
  String get filterAnyAmount => 'Jeder Betrag';

  @override
  String filterUpTo(String amount) {
    return 'Bis $amount';
  }

  @override
  String filterOver(String amount) {
    return 'Über $amount';
  }

  @override
  String get noFilteredReceipts => 'Kein Kassenbon passt zu diesen Filtern.';
}
