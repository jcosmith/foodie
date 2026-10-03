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
  String get storageMonthsLabel => 'Höchstens aufbewahren, in Monaten (optional)';

  @override
  String storageMonthsHelper(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Leer lassen, um der Kategorie zu folgen: etwa $months Monate.',
      one: 'Leer lassen, um der Kategorie zu folgen: etwa 1 Monat.',
    );
    return '$_temp0';
  }

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
  String get defaultCompartmentLabel => 'Standardschublade';

  @override
  String get defaultCompartmentNone => 'Die zuletzt genutzte Schublade';

  @override
  String get defaultCompartmentHelper => 'Wird vorausgewählt, wenn du dieses Produkt einfrierst.';

  @override
  String get archiveProductAction => 'Produkt ausblenden';

  @override
  String archiveProductDialogTitle(String name) {
    return '$name ausblenden?';
  }

  @override
  String get archiveProductDialogText =>
      'Es verschwindet aus der Produktliste. Bereits eingefrorene Produkte und deine Statistik behalten es.';

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

  @override
  String get categoryVegetables => 'Gemüse';

  @override
  String get categoryFruit => 'Obst';

  @override
  String get categoryMeatAndFish => 'Fleisch & Fisch';

  @override
  String get categoryMeals => 'Gerichte';

  @override
  String get categoryBakery => 'Backwaren';

  @override
  String get categoryDesserts => 'Desserts';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get productLeafSpinach => 'Blattspinat';

  @override
  String get productGardenPeas => 'Erbsen';

  @override
  String get productBroccoli => 'Brokkoli';

  @override
  String get productMixedVegetables => 'Gemüsemischung';

  @override
  String get productHerbs => 'Kräuter';

  @override
  String get productFrenchFries => 'Pommes frites';

  @override
  String get productMixedBerries => 'Beerenmischung';

  @override
  String get productStrawberries => 'Erdbeeren';

  @override
  String get productMango => 'Mango';

  @override
  String get productChickenBreast => 'Hähnchenbrust';

  @override
  String get productMincedMeat => 'Hackfleisch';

  @override
  String get productSalmonFillet => 'Lachsfilet';

  @override
  String get productFishFingers => 'Fischstäbchen';

  @override
  String get productPrawns => 'Garnelen';

  @override
  String get productBologneseHomemade => 'Bolognese (selbstgemacht)';

  @override
  String get productSoupHomemade => 'Suppe (selbstgemacht)';

  @override
  String get productLasagne => 'Lasagne';

  @override
  String get productPizzaMargherita => 'Pizza Margherita';

  @override
  String get productWholegrainBread => 'Vollkornbrot';

  @override
  String get productBreadRolls => 'Brötchen';

  @override
  String get productCroissants => 'Croissants';

  @override
  String get productVanillaIceCream => 'Vanilleeis';

  @override
  String get productCake => 'Kuchen';

  @override
  String get productButter => 'Butter';
}
