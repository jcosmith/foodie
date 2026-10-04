// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'pantry_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class PantryLocalizationsDe extends PantryLocalizations {
  PantryLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get domainLabel => 'Vorrat';

  @override
  String get domainDescription => 'Trockenes, Konserven, Brot und Getränke';

  @override
  String get storedOnLabel => 'Gekauft am';

  @override
  String get addTitle => 'In den Vorrat legen';

  @override
  String get pantryName => 'Vorratskammer';

  @override
  String get pantryDescription => 'Vorratskammer';

  @override
  String get kitchenCupboardName => 'Küchenschrank';

  @override
  String get kitchenCupboardDescription => 'Küchenschrank';

  @override
  String get cellarName => 'Keller';

  @override
  String get cellarDescription => 'Keller';

  @override
  String get drinksCrateName => 'Getränkekisten';

  @override
  String get drinksCrateDescription => 'Getränkekisten';

  @override
  String shelfName(int number) {
    return 'Regal $number';
  }

  @override
  String shelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Regale',
      one: '1 Regal',
    );
    return '$_temp0';
  }

  @override
  String get addShelf => 'Regal hinzufügen';

  @override
  String crateName(int number) {
    return 'Kiste $number';
  }

  @override
  String crateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kisten',
      one: '1 Kiste',
    );
    return '$_temp0';
  }

  @override
  String get addCrate => 'Kiste hinzufügen';

  @override
  String get templatePantryShelves => 'Vorratskammer mit 4 Regalen';

  @override
  String get templateKitchenCupboard => 'Küchenschrank mit 2 Regalen';

  @override
  String get templateCellar => 'Keller mit 3 Regalen';

  @override
  String get templateDrinksCrate => 'Eine Getränkekiste';

  @override
  String get categoryBreadAndBakery => 'Brot und Gebäck';

  @override
  String get categoryDryGoods => 'Nudeln, Reis und Getreide';

  @override
  String get categoryTinsAndJars => 'Konserven und Gläser';

  @override
  String get categorySpicesAndCondiments => 'Gewürze und Soßen';

  @override
  String get categoryOilsAndVinegar => 'Öl und Essig';

  @override
  String get categoryBaking => 'Backen';

  @override
  String get categoryBreakfastAndSpreads => 'Frühstück und Aufstriche';

  @override
  String get categorySnacks => 'Snacks und Süßes';

  @override
  String get categoryDrinks => 'Getränke';

  @override
  String get productFreshBread => 'Brot';

  @override
  String get productToastBread => 'Toastbrot';

  @override
  String get productPasta => 'Nudeln';

  @override
  String get productRice => 'Reis';

  @override
  String get productOats => 'Haferflocken';

  @override
  String get productCannedTomatoes => 'Gehackte Tomaten';

  @override
  String get productChickpeas => 'Kichererbsen';

  @override
  String get productTuna => 'Thunfisch';

  @override
  String get productSalt => 'Salz';

  @override
  String get productPepper => 'Pfeffer';

  @override
  String get productKetchup => 'Ketchup';

  @override
  String get productMustard => 'Senf';

  @override
  String get productOliveOil => 'Olivenöl';

  @override
  String get productVinegar => 'Essig';

  @override
  String get productFlour => 'Mehl';

  @override
  String get productSugar => 'Zucker';

  @override
  String get productCornflakes => 'Cornflakes';

  @override
  String get productJam => 'Marmelade';

  @override
  String get productHoney => 'Honig';

  @override
  String get productChocolateSpread => 'Nuss-Nougat-Creme';

  @override
  String get productCrisps => 'Chips';

  @override
  String get productBiscuits => 'Kekse';

  @override
  String get productMineralWater => 'Mineralwasser';

  @override
  String get productOrangeJuice => 'Orangensaft';
}
