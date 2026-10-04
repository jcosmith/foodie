// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'pantry_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class PantryLocalizationsEn extends PantryLocalizations {
  PantryLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get domainLabel => 'Pantry';

  @override
  String get domainDescription => 'Dry goods, tins, bread and drinks';

  @override
  String get storedOnLabel => 'Bought on';

  @override
  String get addTitle => 'Add to the pantry';

  @override
  String get pantryName => 'Pantry';

  @override
  String get pantryDescription => 'pantry';

  @override
  String get kitchenCupboardName => 'Kitchen cupboard';

  @override
  String get kitchenCupboardDescription => 'kitchen cupboard';

  @override
  String get cellarName => 'Cellar';

  @override
  String get cellarDescription => 'cellar';

  @override
  String get drinksCrateName => 'Drinks crates';

  @override
  String get drinksCrateDescription => 'drinks crates';

  @override
  String shelfName(int number) {
    return 'Shelf $number';
  }

  @override
  String shelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shelves',
      one: '1 shelf',
    );
    return '$_temp0';
  }

  @override
  String get addShelf => 'Add shelf';

  @override
  String crateName(int number) {
    return 'Crate $number';
  }

  @override
  String crateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crates',
      one: '1 crate',
    );
    return '$_temp0';
  }

  @override
  String get addCrate => 'Add crate';

  @override
  String get templatePantryShelves => 'Pantry with 4 shelves';

  @override
  String get templateKitchenCupboard => 'Kitchen cupboard with 2 shelves';

  @override
  String get templateCellar => 'Cellar with 3 shelves';

  @override
  String get templateDrinksCrate => 'One drinks crate';

  @override
  String get categoryBreadAndBakery => 'Bread and bakery';

  @override
  String get categoryDryGoods => 'Pasta, rice and grains';

  @override
  String get categoryTinsAndJars => 'Tins and jars';

  @override
  String get categorySpicesAndCondiments => 'Spices and sauces';

  @override
  String get categoryOilsAndVinegar => 'Oil and vinegar';

  @override
  String get categoryBaking => 'Baking';

  @override
  String get categoryBreakfastAndSpreads => 'Breakfast and spreads';

  @override
  String get categorySnacks => 'Snacks and sweets';

  @override
  String get categoryDrinks => 'Drinks';

  @override
  String get productFreshBread => 'Bread';

  @override
  String get productToastBread => 'Toast bread';

  @override
  String get productPasta => 'Pasta';

  @override
  String get productRice => 'Rice';

  @override
  String get productOats => 'Oats';

  @override
  String get productCannedTomatoes => 'Chopped tomatoes';

  @override
  String get productChickpeas => 'Chickpeas';

  @override
  String get productTuna => 'Tuna';

  @override
  String get productSalt => 'Salt';

  @override
  String get productPepper => 'Pepper';

  @override
  String get productKetchup => 'Ketchup';

  @override
  String get productMustard => 'Mustard';

  @override
  String get productOliveOil => 'Olive oil';

  @override
  String get productVinegar => 'Vinegar';

  @override
  String get productFlour => 'Flour';

  @override
  String get productSugar => 'Sugar';

  @override
  String get productCornflakes => 'Cornflakes';

  @override
  String get productJam => 'Jam';

  @override
  String get productHoney => 'Honey';

  @override
  String get productChocolateSpread => 'Chocolate spread';

  @override
  String get productCrisps => 'Crisps';

  @override
  String get productBiscuits => 'Biscuits';

  @override
  String get productMineralWater => 'Mineral water';

  @override
  String get productOrangeJuice => 'Orange juice';
}
