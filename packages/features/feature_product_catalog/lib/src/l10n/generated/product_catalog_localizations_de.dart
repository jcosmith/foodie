// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'product_catalog_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ProductCatalogLocalizationsDe extends ProductCatalogLocalizations {
  ProductCatalogLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get configSectionTitle => 'Produkte';

  @override
  String get productListTitle => 'Produkte';

  @override
  String get productListHint =>
      'Ausgeblendete Produkte verschwinden aus dieser Liste und der Auswahl. Ihre Geschichte bleibt.';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '1 Produkt',
    );
    return '$_temp0';
  }

  @override
  String get pickerTitle => 'Produkt wählen';

  @override
  String get searchHint => 'Produkte suchen';

  @override
  String get createProductAction => 'Neues Produkt anlegen';

  @override
  String createProductWithName(String name) {
    return '„$name“ anlegen';
  }

  @override
  String noProductsFound(String query) {
    return 'Kein Produkt passt zu „$query“.';
  }

  @override
  String get newProductTitle => 'Neues Produkt';

  @override
  String get editProductTitle => 'Produkt bearbeiten';

  @override
  String get nameLabel => 'Name';

  @override
  String nameHintSeeded(String name) {
    return 'Leer lassen für „$name“';
  }

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get unitLabel => 'Gezählt in';

  @override
  String get unitLockedHint => 'Die Einheit bleibt fest, weil der Bestand in ihr gespeichert ist.';

  @override
  String get packageSizeLabel => 'Übliche Packungsgröße (optional)';

  @override
  String get packageSizeHelper => 'Füllt die Menge beim Einfrieren vor.';

  @override
  String get shelfLifeLabel => 'Hält sich (optional)';

  @override
  String shelfLifeHelper(String shelfLife) {
    return 'Leer lassen, um der Kategorie zu folgen: $shelfLife.';
  }

  @override
  String get shelfLifeHelperNone =>
      'Leer lassen, um wie die Kategorie ohne Haltbarkeit zu bleiben.';

  @override
  String get storageRecommendationNote => 'Lagerzeiten sind Empfehlungen, keine Garantie.';

  @override
  String get iconLabel => 'Symbol (ein Emoji, optional)';

  @override
  String get iconImageChoose => 'Bild auswählen';

  @override
  String get iconImageRemove => 'Bild entfernen';

  @override
  String get iconImageHint =>
      'Ein Bild wird statt des Emojis gezeigt. Jede Bilddatei geht; sie wird passend verkleinert.';

  @override
  String get iconImageUnreadable => 'Diese Datei ist kein Bild, das die App lesen kann.';

  @override
  String get defaultCompartmentLabel => 'Standardfach';

  @override
  String get defaultCompartmentNone => 'Das zuletzt genutzte Fach';

  @override
  String get defaultCompartmentHelper => 'Wird vorausgewählt, wenn du dieses Produkt hinzufügst.';

  @override
  String get archiveProductAction => 'Produkt ausblenden';

  @override
  String archiveProductDialogTitle(String name) {
    return '$name ausblenden?';
  }

  @override
  String get archiveProductDialogText =>
      'Es verschwindet aus der Produktliste. Vorhandene Produkte und deine Statistik behalten es.';

  @override
  String get nameMissing => 'Bitte gib einen Namen ein.';

  @override
  String get nameTooLong => 'Höchstens 40 Zeichen.';

  @override
  String get invalidSetting => 'Mengen müssen größer als null sein.';

  @override
  String get invalidNumber => 'Bitte gib eine Zahl ein.';

  @override
  String get genericFailure => 'Das hat nicht geklappt. Bitte versuche es noch einmal.';
}
