// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'inventory_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class InventoryLocalizationsEn extends InventoryLocalizations {
  InventoryLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get overviewTitle => 'At home';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String drawerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count compartments',
      one: '1 compartment',
    );
    return '$_temp0';
  }

  @override
  String itemsInDrawers(String items, String drawers) {
    return '$items in $drawers';
  }

  @override
  String get searchHint => 'Search products';

  @override
  String get sortByDrawer => 'By place';

  @override
  String get sortByEatBefore => 'Use first';

  @override
  String get expandAllDrawers => 'Expand all';

  @override
  String get collapseAllDrawers => 'Collapse all';

  @override
  String frozenAgo(String age) {
    return 'added $age';
  }

  @override
  String openedAgo(String age) {
    return 'opened $age';
  }

  @override
  String bestBeforeHint(String shelfLife) {
    return 'Usually keeps $shelfLife';
  }

  @override
  String get bestBeforeToday => 'Today';

  @override
  String get bestBeforePlusOneDay => '+1 day';

  @override
  String get bestBeforePlusThreeDays => '+3 days';

  @override
  String get bestBeforePlusOneWeek => '+1 week';

  @override
  String get bestBeforeNone => 'None';

  @override
  String get bestBeforePickDate => 'Date';

  @override
  String get noBestBefore => 'No date';

  @override
  String get markOpenedAction => 'Mark as opened';

  @override
  String get markNotOpenedAction => 'Mark as not opened';

  @override
  String markedOpenedSnackbar(String product) {
    return '$product marked as opened';
  }

  @override
  String get useToday => 'Use today';

  @override
  String get useByTomorrow => 'Use by tomorrow';

  @override
  String useByWeekday(String weekday) {
    return 'Use by $weekday';
  }

  @override
  String get pastBestBefore => 'Past best before';

  @override
  String ofInitial(String remaining, String initial) {
    return '$remaining of $initial';
  }

  @override
  String remainingShare(int percent) {
    return '$percent% left';
  }

  @override
  String get noStoragePlaceTitle => 'Set up a storage place first';

  @override
  String get noStoragePlaceMessage =>
      'Tell the app where you keep things and how it is divided, then add what is inside.';

  @override
  String get setUpStoragePlaceButton => 'Add storage place';

  @override
  String get emptyTitle => 'Nothing in here yet';

  @override
  String get emptyMessage =>
      'Add what you put away, and the app keeps track of how long it has been there.';

  @override
  String noSearchResults(String query) {
    return 'Nothing matches “$query”.';
  }

  @override
  String get addButton => 'Add';

  @override
  String get quickActionAdd => 'Add item';

  @override
  String get takeTitle => 'How much are you taking?';

  @override
  String get discardTitle => 'How much are you throwing away?';

  @override
  String leftAfter(String amount) {
    return '$amount stays';
  }

  @override
  String get allTaken => 'Bag is used up';

  @override
  String get amountSliderLabel => 'Amount';

  @override
  String get exactAmount => 'Exact amount';

  @override
  String get all => 'All';

  @override
  String takeAmountButton(String amount) {
    return 'Take $amount';
  }

  @override
  String tookSnackbar(String amount, String product) {
    return 'Took $amount of $product';
  }

  @override
  String get discardAction => 'Throw away';

  @override
  String get moveAction => 'Move';

  @override
  String get correctAction => 'Correct amount';

  @override
  String get discardReasonLabel => 'Why?';

  @override
  String get reasonTooOld => 'Stored too long';

  @override
  String get reasonFreezerBurn => 'Freezer burn';

  @override
  String get reasonExpired => 'Past its date';

  @override
  String get reasonSpoiled => 'Gone off';

  @override
  String get reasonUnwanted => 'Nobody wanted it';

  @override
  String get reasonOther => 'Other';

  @override
  String discardAmountButton(String amount) {
    return 'Throw away $amount';
  }

  @override
  String discardedSnackbar(String amount, String product) {
    return 'Threw away $amount of $product';
  }

  @override
  String get moveTitle => 'Move to another compartment';

  @override
  String get moveDestinationLabel => 'Move to';

  @override
  String get moveAmountLabel => 'How much?';

  @override
  String moveAmountButton(String amount) {
    return 'Move $amount';
  }

  @override
  String movedSnackbar(String amount, String product, String compartment) {
    return 'Moved $amount of $product to $compartment';
  }

  @override
  String get noOtherCompartment => 'Add another compartment to move things.';

  @override
  String get correctTitle => 'How much is really left?';

  @override
  String get correctHint => 'For when you took more or less than you recorded.';

  @override
  String correctedSnackbar(String product, String amount) {
    return '$product: $amount left';
  }

  @override
  String get addTitle => 'Add';

  @override
  String get productLabel => 'Product';

  @override
  String get chooseProduct => 'Choose a product';

  @override
  String get quantityLabel => 'Amount';

  @override
  String packageHint(String amount) {
    return 'Package: $amount';
  }

  @override
  String get storedOnLabel => 'Stored on';

  @override
  String get compartmentLabel => 'Where';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String addedSnackbar(String amount, String product, String compartment) {
    return 'Added $amount of $product to $compartment';
  }

  @override
  String get quantityNotPositive => 'Enter an amount above zero.';

  @override
  String get quantityExceedsRemaining => 'That is more than is left.';

  @override
  String get invalidAmount => 'Please enter a number.';

  @override
  String get productMissing => 'Choose a product first.';

  @override
  String get compartmentMissing => 'Choose where it goes.';

  @override
  String get storedOnInFuture => 'The date cannot be in the future.';

  @override
  String get genericFailure => 'That did not work. Please try again.';

  @override
  String get batchPhotoButton => 'Photo of this bag';

  @override
  String usualAmountHint(String amount) {
    return 'Usually $amount';
  }
}
