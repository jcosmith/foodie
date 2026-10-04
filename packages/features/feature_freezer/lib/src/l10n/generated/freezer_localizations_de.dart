// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'freezer_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FreezerLocalizationsDe extends FreezerLocalizations {
  FreezerLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get domainLabel => 'Tiefkühler';

  @override
  String get domainDescription => 'Tiefkühlkost, Schubladen und Körbe';

  @override
  String get storedOnLabel => 'Eingefroren am';

  @override
  String get uprightName => 'Gefrierschrank';

  @override
  String get chestName => 'Gefriertruhe';

  @override
  String get fridgeFreezerName => 'Gefrierfach';

  @override
  String get uprightDescription => 'stehend';

  @override
  String get chestDescription => 'Truhe';

  @override
  String get fridgeFreezerDescription => 'im Kühlschrank';

  @override
  String drawerName(int number) {
    return 'Schublade $number';
  }

  @override
  String basketName(int number) {
    return 'Korb $number';
  }

  @override
  String compartmentName(int number) {
    return 'Fach $number';
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
  String compartmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fächer',
      one: '1 Fach',
    );
    return '$_temp0';
  }

  @override
  String get addDrawer => 'Schublade hinzufügen';

  @override
  String get addBasket => 'Korb hinzufügen';

  @override
  String get addCompartment => 'Fach hinzufügen';

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
