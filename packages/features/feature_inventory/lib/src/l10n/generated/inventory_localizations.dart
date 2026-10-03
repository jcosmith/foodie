import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'inventory_localizations_de.dart';
import 'inventory_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of InventoryLocalizations
/// returned by `InventoryLocalizations.of(context)`.
///
/// Applications need to include `InventoryLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/inventory_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: InventoryLocalizations.localizationsDelegates,
///   supportedLocales: InventoryLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the InventoryLocalizations.supportedLocales
/// property.
abstract class InventoryLocalizations {
  InventoryLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static InventoryLocalizations of(BuildContext context) {
    return Localizations.of<InventoryLocalizations>(context, InventoryLocalizations)!;
  }

  static const LocalizationsDelegate<InventoryLocalizations> delegate =
      _InventoryLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en')];

  /// No description provided for @navigationLabel.
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get navigationLabel;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'My freezer'**
  String get overviewTitle;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @drawerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drawer} other{{count} drawers}}'**
  String drawerCount(int count);

  /// No description provided for @itemsInDrawers.
  ///
  /// In en, this message translates to:
  /// **'{items} in {drawers}'**
  String itemsInDrawers(String items, String drawers);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchHint;

  /// No description provided for @sortByDrawer.
  ///
  /// In en, this message translates to:
  /// **'By drawer'**
  String get sortByDrawer;

  /// No description provided for @sortByEatBefore.
  ///
  /// In en, this message translates to:
  /// **'Eat first'**
  String get sortByEatBefore;

  /// No description provided for @expandAllDrawers.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get expandAllDrawers;

  /// No description provided for @collapseAllDrawers.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get collapseAllDrawers;

  /// No description provided for @frozenAgo.
  ///
  /// In en, this message translates to:
  /// **'frozen {age}'**
  String frozenAgo(String age);

  /// No description provided for @ofInitial.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {initial}'**
  String ofInitial(String remaining, String initial);

  /// No description provided for @remainingShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% left'**
  String remainingShare(int percent);

  /// No description provided for @noFreezerTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your freezer first'**
  String get noFreezerTitle;

  /// No description provided for @noFreezerMessage.
  ///
  /// In en, this message translates to:
  /// **'Tell the app which drawers your freezer has, then add what is inside.'**
  String get noFreezerMessage;

  /// No description provided for @setUpFreezerButton.
  ///
  /// In en, this message translates to:
  /// **'Set up freezer'**
  String get setUpFreezerButton;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your freezer is empty'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add what you freeze, and the app keeps track of how long it has been in there.'**
  String get emptyMessage;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”.'**
  String noSearchResults(String query);

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @quickActionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to freezer'**
  String get quickActionAdd;

  /// No description provided for @takeTitle.
  ///
  /// In en, this message translates to:
  /// **'How much are you taking?'**
  String get takeTitle;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'How much are you throwing away?'**
  String get discardTitle;

  /// No description provided for @leftAfter.
  ///
  /// In en, this message translates to:
  /// **'{amount} stays in the freezer'**
  String leftAfter(String amount);

  /// No description provided for @allTaken.
  ///
  /// In en, this message translates to:
  /// **'Bag is used up'**
  String get allTaken;

  /// No description provided for @amountSliderLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountSliderLabel;

  /// No description provided for @exactAmount.
  ///
  /// In en, this message translates to:
  /// **'Exact amount'**
  String get exactAmount;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @takeAmountButton.
  ///
  /// In en, this message translates to:
  /// **'Take {amount}'**
  String takeAmountButton(String amount);

  /// No description provided for @tookSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Took {amount} of {product}'**
  String tookSnackbar(String amount, String product);

  /// No description provided for @discardAction.
  ///
  /// In en, this message translates to:
  /// **'Throw away'**
  String get discardAction;

  /// No description provided for @moveAction.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveAction;

  /// No description provided for @correctAction.
  ///
  /// In en, this message translates to:
  /// **'Correct amount'**
  String get correctAction;

  /// No description provided for @discardReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get discardReasonLabel;

  /// No description provided for @reasonTooOld.
  ///
  /// In en, this message translates to:
  /// **'Stored too long'**
  String get reasonTooOld;

  /// No description provided for @reasonFreezerBurn.
  ///
  /// In en, this message translates to:
  /// **'Freezer burn'**
  String get reasonFreezerBurn;

  /// No description provided for @reasonUnwanted.
  ///
  /// In en, this message translates to:
  /// **'Nobody wanted it'**
  String get reasonUnwanted;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @discardAmountButton.
  ///
  /// In en, this message translates to:
  /// **'Throw away {amount}'**
  String discardAmountButton(String amount);

  /// No description provided for @discardedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Threw away {amount} of {product}'**
  String discardedSnackbar(String amount, String product);

  /// No description provided for @moveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to another drawer'**
  String get moveTitle;

  /// No description provided for @moveDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get moveDestinationLabel;

  /// No description provided for @moveAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get moveAmountLabel;

  /// No description provided for @moveAmountButton.
  ///
  /// In en, this message translates to:
  /// **'Move {amount}'**
  String moveAmountButton(String amount);

  /// No description provided for @movedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Moved {amount} of {product} to {compartment}'**
  String movedSnackbar(String amount, String product, String compartment);

  /// No description provided for @noOtherCompartment.
  ///
  /// In en, this message translates to:
  /// **'Add another drawer in the freezer layout to move things.'**
  String get noOtherCompartment;

  /// No description provided for @correctTitle.
  ///
  /// In en, this message translates to:
  /// **'How much is really left?'**
  String get correctTitle;

  /// No description provided for @correctHint.
  ///
  /// In en, this message translates to:
  /// **'For when you took more or less than you recorded.'**
  String get correctHint;

  /// No description provided for @correctedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{product}: {amount} left'**
  String correctedSnackbar(String product, String amount);

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to freezer'**
  String get addTitle;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @chooseProduct.
  ///
  /// In en, this message translates to:
  /// **'Choose a product'**
  String get chooseProduct;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get quantityLabel;

  /// No description provided for @packageHint.
  ///
  /// In en, this message translates to:
  /// **'Package: {amount}'**
  String packageHint(String amount);

  /// No description provided for @frozenOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Frozen on'**
  String get frozenOnLabel;

  /// No description provided for @compartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer'**
  String get compartmentLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteLabel;

  /// No description provided for @addedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Added {amount} of {product} to {compartment}'**
  String addedSnackbar(String amount, String product, String compartment);

  /// No description provided for @quantityNotPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero.'**
  String get quantityNotPositive;

  /// No description provided for @quantityExceedsRemaining.
  ///
  /// In en, this message translates to:
  /// **'That is more than is left.'**
  String get quantityExceedsRemaining;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number.'**
  String get invalidAmount;

  /// No description provided for @productMissing.
  ///
  /// In en, this message translates to:
  /// **'Choose a product first.'**
  String get productMissing;

  /// No description provided for @compartmentMissing.
  ///
  /// In en, this message translates to:
  /// **'Choose a drawer.'**
  String get compartmentMissing;

  /// No description provided for @frozenOnInFuture.
  ///
  /// In en, this message translates to:
  /// **'The freezing date cannot be in the future.'**
  String get frozenOnInFuture;

  /// No description provided for @genericFailure.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get genericFailure;

  /// No description provided for @batchPhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Photo of this bag'**
  String get batchPhotoButton;
}

class _InventoryLocalizationsDelegate extends LocalizationsDelegate<InventoryLocalizations> {
  const _InventoryLocalizationsDelegate();

  @override
  Future<InventoryLocalizations> load(Locale locale) {
    return SynchronousFuture<InventoryLocalizations>(lookupInventoryLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_InventoryLocalizationsDelegate old) => false;
}

InventoryLocalizations lookupInventoryLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return InventoryLocalizationsDe();
    case 'en':
      return InventoryLocalizationsEn();
  }

  throw FlutterError(
    'InventoryLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
