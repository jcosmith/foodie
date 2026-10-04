// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'restock_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class RestockLocalizationsEn extends RestockLocalizations {
  RestockLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationLabel => 'List';

  @override
  String get shoppingListTitle => 'Shopping list';

  @override
  String get shoppingListSubtitle => 'Running-low items are added automatically';

  @override
  String get originRestock => 'Running low';

  @override
  String get originManual => 'Added by you';

  @override
  String putTickedInStoragePlace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Put $count ticked items in the freezer',
      one: 'Put 1 ticked item in the freezer',
    );
    return '$_temp0';
  }

  @override
  String get nothingTicked => 'Tick what you bought';

  @override
  String itemsPutInStoragePlace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items are in the freezer now',
      one: '1 item is in the freezer now',
      zero: 'Ticked items removed from the list',
    );
    return '$_temp0';
  }

  @override
  String get addToListButton => 'Add';

  @override
  String get emptyListTitle => 'Your shopping list is empty';

  @override
  String get emptyListMessage =>
      'Products with a minimum quantity show up here when they run low. Add anything else with the button below.';

  @override
  String get entryRemoved => 'Removed from the list';

  @override
  String get runningLowTitle => 'Running low';

  @override
  String get shoppingListLink => 'Shopping list';

  @override
  String get runningLowEmpty => 'Everything is stocked.';

  @override
  String get configSectionTitle => 'Restock';

  @override
  String get configSectionExplanation =>
      'Set a minimum for food you always want at home. When the freezer holds less, it goes on the shopping list.';

  @override
  String get minimumQuantitiesRow => 'Minimum quantities';

  @override
  String ruleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'None yet',
    );
    return '$_temp0';
  }

  @override
  String get rulesEmptyTitle => 'No minimum quantities yet';

  @override
  String get rulesEmptyMessage => 'Add a product you always want in the freezer.';

  @override
  String get addRuleButton => 'Add product';

  @override
  String ruleSummary(String minimum, String stock) {
    return 'Keep at least $minimum · $stock in the freezer';
  }

  @override
  String ruleSummaryWithTarget(String minimum, String target, String stock) {
    return 'Keep at least $minimum, buy up to $target · $stock in the freezer';
  }

  @override
  String get minimumLabel => 'Keep at least';

  @override
  String get targetLabel => 'Buy up to (optional)';

  @override
  String get minimumNotPositive => 'Enter an amount above zero.';

  @override
  String get targetBelowMinimum => 'This must be at least the minimum.';

  @override
  String get noStoragePlaceForBoughtItems => 'Set up your freezer first, then put the items in.';

  @override
  String get automaticEntryCannotBeRemoved =>
      'This item follows its minimum quantity. Change the minimum to take it off the list.';

  @override
  String get genericFailure => 'That did not work. Please try again.';

  @override
  String get forecastTitle => 'Runs out in';

  @override
  String get forecastSubtitle => 'From the last 60 days of eating';

  @override
  String forecastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '≈ $count days',
      one: '≈ 1 day',
    );
    return '$_temp0';
  }

  @override
  String get forecastNever => 'no recent use';

  @override
  String get forecastEmpty => 'Set a minimum quantity for a product to see when it runs out.';

  @override
  String get forecastNoMatch => 'No product with a minimum quantity matches these filters.';

  @override
  String get forecastTableProduct => 'Product';

  @override
  String get forecastTableStock => 'In freezer';

  @override
  String get forecastTableDays => 'Days left';

  @override
  String forecastAddedToList(String productName) {
    return '$productName is on the shopping list';
  }
}
