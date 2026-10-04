// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'inventory_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class InventoryLocalizationsDe extends InventoryLocalizations {
  InventoryLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get overviewTitle => 'Zu Hause';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '1 Produkt',
    );
    return '$_temp0';
  }

  @override
  String drawerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fächer',
      one: '1 Fach',
    );
    return '$_temp0';
  }

  @override
  String itemsInDrawers(String items, String drawers) {
    return '$items in $drawers';
  }

  @override
  String get searchHint => 'Produkte suchen';

  @override
  String get sortByDrawer => 'Nach Ort';

  @override
  String get sortByEatBefore => 'Zuerst verbrauchen';

  @override
  String get expandAllDrawers => 'Alle aufklappen';

  @override
  String get collapseAllDrawers => 'Alle zuklappen';

  @override
  String frozenAgo(String age) {
    return 'eingelagert $age';
  }

  @override
  String ofInitial(String remaining, String initial) {
    return '$remaining von $initial';
  }

  @override
  String remainingShare(int percent) {
    return '$percent % übrig';
  }

  @override
  String get noStoragePlaceTitle => 'Richte zuerst einen Lagerort ein';

  @override
  String get noStoragePlaceMessage =>
      'Sag der App, wo du Dinge aufbewahrst und wie es aufgeteilt ist, und trage dann ein, was drin ist.';

  @override
  String get setUpStoragePlaceButton => 'Lagerort hinzufügen';

  @override
  String get emptyTitle => 'Hier ist noch nichts';

  @override
  String get emptyMessage =>
      'Trag ein, was du einräumst, und die App merkt sich, wie lange es schon da ist.';

  @override
  String noSearchResults(String query) {
    return 'Nichts passt zu „$query“.';
  }

  @override
  String get addButton => 'Hinzufügen';

  @override
  String get quickActionAdd => 'Eintragen';

  @override
  String get takeTitle => 'Wie viel nimmst du?';

  @override
  String get discardTitle => 'Wie viel wirfst du weg?';

  @override
  String leftAfter(String amount) {
    return '$amount bleiben';
  }

  @override
  String get allTaken => 'Packung ist aufgebraucht';

  @override
  String get amountSliderLabel => 'Menge';

  @override
  String get exactAmount => 'Genaue Menge';

  @override
  String get all => 'Alles';

  @override
  String takeAmountButton(String amount) {
    return '$amount entnehmen';
  }

  @override
  String tookSnackbar(String amount, String product) {
    return '$amount $product entnommen';
  }

  @override
  String get discardAction => 'Wegwerfen';

  @override
  String get moveAction => 'Verschieben';

  @override
  String get correctAction => 'Menge korrigieren';

  @override
  String get discardReasonLabel => 'Warum?';

  @override
  String get reasonTooOld => 'Zu lange gelagert';

  @override
  String get reasonFreezerBurn => 'Gefrierbrand';

  @override
  String get reasonExpired => 'Abgelaufen';

  @override
  String get reasonSpoiled => 'Verdorben';

  @override
  String get reasonUnwanted => 'Wollte keiner';

  @override
  String get reasonOther => 'Anderes';

  @override
  String discardAmountButton(String amount) {
    return '$amount wegwerfen';
  }

  @override
  String discardedSnackbar(String amount, String product) {
    return '$amount $product weggeworfen';
  }

  @override
  String get moveTitle => 'In ein anderes Fach';

  @override
  String get moveDestinationLabel => 'Verschieben nach';

  @override
  String get moveAmountLabel => 'Wie viel?';

  @override
  String moveAmountButton(String amount) {
    return '$amount verschieben';
  }

  @override
  String movedSnackbar(String amount, String product, String compartment) {
    return '$amount $product nach $compartment verschoben';
  }

  @override
  String get noOtherCompartment => 'Lege ein weiteres Fach an, um etwas zu verschieben.';

  @override
  String get correctTitle => 'Wie viel ist wirklich noch da?';

  @override
  String get correctHint =>
      'Für den Fall, dass du mehr oder weniger genommen hast als eingetragen.';

  @override
  String correctedSnackbar(String product, String amount) {
    return '$product: noch $amount';
  }

  @override
  String get addTitle => 'Hinzufügen';

  @override
  String get productLabel => 'Produkt';

  @override
  String get chooseProduct => 'Produkt wählen';

  @override
  String get quantityLabel => 'Menge';

  @override
  String packageHint(String amount) {
    return 'Packung: $amount';
  }

  @override
  String get storedOnLabel => 'Eingelagert am';

  @override
  String get compartmentLabel => 'Wo';

  @override
  String get noteLabel => 'Notiz (optional)';

  @override
  String addedSnackbar(String amount, String product, String compartment) {
    return '$amount $product in $compartment gelegt';
  }

  @override
  String get quantityNotPositive => 'Gib eine Menge über null ein.';

  @override
  String get quantityExceedsRemaining => 'Das ist mehr, als noch da ist.';

  @override
  String get invalidAmount => 'Bitte gib eine Zahl ein.';

  @override
  String get productMissing => 'Wähle zuerst ein Produkt.';

  @override
  String get compartmentMissing => 'Wähle, wohin es kommt.';

  @override
  String get storedOnInFuture => 'Das Datum kann nicht in der Zukunft liegen.';

  @override
  String get genericFailure => 'Das hat nicht geklappt. Bitte versuche es noch einmal.';

  @override
  String get batchPhotoButton => 'Foto dieser Packung';
}
