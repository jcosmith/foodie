// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fridge_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FridgeLocalizationsEn extends FridgeLocalizations {
  FridgeLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get domainLabel => 'Fridge';

  @override
  String get domainDescription => 'Fresh food that keeps for days';

  @override
  String get storedOnLabel => 'Bought on';

  @override
  String get addTitle => 'Add to the fridge';

  @override
  String get bestBeforeLabel => 'Best before';

  @override
  String get fridgeName => 'Fridge';

  @override
  String get drinksFridgeName => 'Drinks fridge';

  @override
  String get wineFridgeName => 'Wine fridge';

  @override
  String get fridgeDescription => 'fridge';

  @override
  String get drinksFridgeDescription => 'drinks fridge';

  @override
  String get wineFridgeDescription => 'wine fridge';

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
  String rackName(int number) {
    return 'Rack $number';
  }

  @override
  String rackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count racks',
      one: '1 rack',
    );
    return '$_temp0';
  }

  @override
  String get addRack => 'Add rack';

  @override
  String get templateThreeShelves => 'Fridge with 3 shelves';

  @override
  String get templateFiveShelves => 'Fridge with 5 shelves';

  @override
  String get templateDrinks => 'Drinks fridge with 3 shelves';

  @override
  String get templateWine => 'Wine fridge with 4 racks';

  @override
  String get categoryDairy => 'Dairy and eggs';

  @override
  String get categoryFreshProduce => 'Fruit and vegetables';

  @override
  String get categoryFreshMeatAndFish => 'Fresh meat and fish';

  @override
  String get categoryLeftovers => 'Leftovers';

  @override
  String get categoryChilledOther => 'Other chilled food';

  @override
  String get productMilk => 'Milk';

  @override
  String get productYoghurt => 'Yoghurt';

  @override
  String get productCream => 'Cream';

  @override
  String get productSlicedCheese => 'Sliced cheese';

  @override
  String get productMozzarella => 'Mozzarella';

  @override
  String get productEggs => 'Eggs';

  @override
  String get productLettuce => 'Lettuce';

  @override
  String get productTomatoes => 'Tomatoes';

  @override
  String get productCucumber => 'Cucumber';

  @override
  String get productFreshHerbs => 'Fresh herbs';

  @override
  String get productFreshMincedMeat => 'Fresh minced meat';

  @override
  String get productFreshChickenBreast => 'Fresh chicken breast';

  @override
  String get productFreshFish => 'Fresh fish';

  @override
  String get productColdCuts => 'Cold cuts';

  @override
  String get productLeftovers => 'Leftovers';

  @override
  String get productPesto => 'Pesto';
}
