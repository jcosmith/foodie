// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fridge_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FridgeLocalizationsDe extends FridgeLocalizations {
  FridgeLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get domainLabel => 'Kühlschrank';

  @override
  String get domainDescription => 'Frisches, das sich Tage hält';

  @override
  String get storedOnLabel => 'Gekauft am';

  @override
  String get addTitle => 'In den Kühlschrank legen';

  @override
  String get fridgeName => 'Kühlschrank';

  @override
  String get drinksFridgeName => 'Getränkekühlschrank';

  @override
  String get wineFridgeName => 'Weinkühlschrank';

  @override
  String get fridgeDescription => 'Kühlschrank';

  @override
  String get drinksFridgeDescription => 'Getränkekühlschrank';

  @override
  String get wineFridgeDescription => 'Weinkühlschrank';

  @override
  String shelfName(int number) {
    return 'Fach $number';
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
  String get addShelf => 'Fach hinzufügen';

  @override
  String rackName(int number) {
    return 'Ebene $number';
  }

  @override
  String rackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ebenen',
      one: '1 Ebene',
    );
    return '$_temp0';
  }

  @override
  String get addRack => 'Ebene hinzufügen';

  @override
  String get templateThreeShelves => 'Kühlschrank mit 3 Fächern';

  @override
  String get templateFiveShelves => 'Kühlschrank mit 5 Fächern';

  @override
  String get templateDrinks => 'Getränkekühlschrank mit 3 Fächern';

  @override
  String get templateWine => 'Weinkühlschrank mit 4 Ebenen';

  @override
  String get categoryDairy => 'Milchprodukte und Eier';

  @override
  String get categoryFreshProduce => 'Obst und Gemüse';

  @override
  String get categoryFreshMeatAndFish => 'Frisches Fleisch und Fisch';

  @override
  String get categoryLeftovers => 'Reste';

  @override
  String get categoryChilledOther => 'Sonstiges Gekühltes';

  @override
  String get productMilk => 'Milch';

  @override
  String get productYoghurt => 'Joghurt';

  @override
  String get productCream => 'Sahne';

  @override
  String get productSlicedCheese => 'Käsescheiben';

  @override
  String get productMozzarella => 'Mozzarella';

  @override
  String get productEggs => 'Eier';

  @override
  String get productLettuce => 'Kopfsalat';

  @override
  String get productTomatoes => 'Tomaten';

  @override
  String get productCucumber => 'Gurke';

  @override
  String get productFreshHerbs => 'Frische Kräuter';

  @override
  String get productFreshMincedMeat => 'Frisches Hackfleisch';

  @override
  String get productFreshChickenBreast => 'Frische Hähnchenbrust';

  @override
  String get productFreshFish => 'Frischer Fisch';

  @override
  String get productColdCuts => 'Aufschnitt';

  @override
  String get productLeftovers => 'Reste';

  @override
  String get productPesto => 'Pesto';
}
