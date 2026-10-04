// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'freezer_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FreezerLocalizationsEn extends FreezerLocalizations {
  FreezerLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get domainLabel => 'Freezer';

  @override
  String get domainDescription => 'Frozen food, drawers and baskets';

  @override
  String get storedOnLabel => 'Frozen on';

  @override
  String get addTitle => 'Add to the freezer';

  @override
  String get uprightName => 'Freezer';

  @override
  String get chestName => 'Chest freezer';

  @override
  String get fridgeFreezerName => 'Fridge freezer';

  @override
  String get uprightDescription => 'upright';

  @override
  String get chestDescription => 'chest freezer';

  @override
  String get fridgeFreezerDescription => 'in the fridge';

  @override
  String drawerName(int number) {
    return 'Drawer $number';
  }

  @override
  String basketName(int number) {
    return 'Basket $number';
  }

  @override
  String compartmentName(int number) {
    return 'Compartment $number';
  }

  @override
  String drawerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drawers',
      one: '1 drawer',
    );
    return '$_temp0';
  }

  @override
  String basketCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baskets',
      one: '1 basket',
    );
    return '$_temp0';
  }

  @override
  String compartmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count compartments',
      one: '1 compartment',
    );
    return '$_temp0';
  }

  @override
  String get addDrawer => 'Add drawer';

  @override
  String get addBasket => 'Add basket';

  @override
  String get addCompartment => 'Add compartment';

  @override
  String get templateUprightWithThreeDrawers => 'Upright freezer with 3 drawers';

  @override
  String get templateUprightWithFiveDrawers => 'Upright freezer with 5 drawers';

  @override
  String get templateUprightWithSevenDrawers => 'Upright freezer with 7 drawers';

  @override
  String get templateChestWithBaskets => 'Chest freezer with 3 baskets';

  @override
  String get templateFridgeFreezerCompartment => 'Freezer compartment of a fridge';

  @override
  String get templateEmpty => 'Start with one drawer and add the rest yourself';

  @override
  String get categoryVegetables => 'Vegetables';

  @override
  String get categoryFruit => 'Fruit';

  @override
  String get categoryMeatAndFish => 'Meat & fish';

  @override
  String get categoryMeals => 'Meals';

  @override
  String get categoryBakery => 'Bakery';

  @override
  String get categoryDesserts => 'Desserts';

  @override
  String get categoryOther => 'Other';

  @override
  String get productLeafSpinach => 'Leaf spinach';

  @override
  String get productGardenPeas => 'Garden peas';

  @override
  String get productBroccoli => 'Broccoli';

  @override
  String get productMixedVegetables => 'Mixed vegetables';

  @override
  String get productHerbs => 'Herbs';

  @override
  String get productFrenchFries => 'French fries';

  @override
  String get productMixedBerries => 'Mixed berries';

  @override
  String get productStrawberries => 'Strawberries';

  @override
  String get productMango => 'Mango';

  @override
  String get productChickenBreast => 'Chicken breast';

  @override
  String get productMincedMeat => 'Minced meat';

  @override
  String get productSalmonFillet => 'Salmon fillet';

  @override
  String get productFishFingers => 'Fish fingers';

  @override
  String get productPrawns => 'Prawns';

  @override
  String get productBologneseHomemade => 'Bolognese (homemade)';

  @override
  String get productSoupHomemade => 'Soup (homemade)';

  @override
  String get productLasagne => 'Lasagne';

  @override
  String get productPizzaMargherita => 'Pizza Margherita';

  @override
  String get productWholegrainBread => 'Wholegrain bread';

  @override
  String get productBreadRolls => 'Bread rolls';

  @override
  String get productCroissants => 'Croissants';

  @override
  String get productVanillaIceCream => 'Vanilla ice cream';

  @override
  String get productCake => 'Cake';

  @override
  String get productButter => 'Butter';
}
