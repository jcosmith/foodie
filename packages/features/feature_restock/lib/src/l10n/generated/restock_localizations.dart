import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'restock_localizations_de.dart';
import 'restock_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of RestockLocalizations
/// returned by `RestockLocalizations.of(context)`.
///
/// Applications need to include `RestockLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/restock_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: RestockLocalizations.localizationsDelegates,
///   supportedLocales: RestockLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the RestockLocalizations.supportedLocales
/// property.
abstract class RestockLocalizations {
  RestockLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static RestockLocalizations of(BuildContext context) {
    return Localizations.of<RestockLocalizations>(context, RestockLocalizations)!;
  }

  static const LocalizationsDelegate<RestockLocalizations> delegate =
      _RestockLocalizationsDelegate();

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
  /// **'List'**
  String get navigationLabel;

  /// No description provided for @shoppingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingListTitle;

  /// No description provided for @shoppingListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Running-low items are added automatically'**
  String get shoppingListSubtitle;

  /// No description provided for @originRestock.
  ///
  /// In en, this message translates to:
  /// **'Running low'**
  String get originRestock;

  /// No description provided for @originManual.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get originManual;

  /// No description provided for @putTickedInFreezer.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Put 1 ticked item in the freezer} other{Put {count} ticked items in the freezer}}'**
  String putTickedInFreezer(int count);

  /// No description provided for @nothingTicked.
  ///
  /// In en, this message translates to:
  /// **'Tick what you bought'**
  String get nothingTicked;

  /// No description provided for @itemsPutInFreezer.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Ticked items removed from the list} =1{1 item is in the freezer now} other{{count} items are in the freezer now}}'**
  String itemsPutInFreezer(int count);

  /// No description provided for @addToListButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToListButton;

  /// No description provided for @emptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list is empty'**
  String get emptyListTitle;

  /// No description provided for @emptyListMessage.
  ///
  /// In en, this message translates to:
  /// **'Products with a minimum quantity show up here when they run low. Add anything else with the button below.'**
  String get emptyListMessage;

  /// No description provided for @entryRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from the list'**
  String get entryRemoved;

  /// No description provided for @runningLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Running low'**
  String get runningLowTitle;

  /// No description provided for @shoppingListLink.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingListLink;

  /// No description provided for @runningLowEmpty.
  ///
  /// In en, this message translates to:
  /// **'Everything is stocked.'**
  String get runningLowEmpty;

  /// No description provided for @configSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get configSectionTitle;

  /// No description provided for @configSectionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Set a minimum for food you always want at home. When the freezer holds less, it goes on the shopping list.'**
  String get configSectionExplanation;

  /// No description provided for @minimumQuantitiesRow.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantities'**
  String get minimumQuantitiesRow;

  /// No description provided for @ruleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None yet} =1{1 product} other{{count} products}}'**
  String ruleCount(int count);

  /// No description provided for @rulesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No minimum quantities yet'**
  String get rulesEmptyTitle;

  /// No description provided for @rulesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a product you always want in the freezer.'**
  String get rulesEmptyMessage;

  /// No description provided for @addRuleButton.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addRuleButton;

  /// No description provided for @ruleSummary.
  ///
  /// In en, this message translates to:
  /// **'Keep at least {minimum} · {stock} in the freezer'**
  String ruleSummary(String minimum, String stock);

  /// No description provided for @ruleSummaryWithTarget.
  ///
  /// In en, this message translates to:
  /// **'Keep at least {minimum}, buy up to {target} · {stock} in the freezer'**
  String ruleSummaryWithTarget(String minimum, String target, String stock);

  /// No description provided for @minimumLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep at least'**
  String get minimumLabel;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy up to (optional)'**
  String get targetLabel;

  /// No description provided for @minimumNotPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero.'**
  String get minimumNotPositive;

  /// No description provided for @targetBelowMinimum.
  ///
  /// In en, this message translates to:
  /// **'This must be at least the minimum.'**
  String get targetBelowMinimum;

  /// No description provided for @noFreezerForBoughtItems.
  ///
  /// In en, this message translates to:
  /// **'Set up your freezer first, then put the items in.'**
  String get noFreezerForBoughtItems;

  /// No description provided for @automaticEntryCannotBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'This item follows its minimum quantity. Change the minimum to take it off the list.'**
  String get automaticEntryCannotBeRemoved;

  /// No description provided for @genericFailure.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get genericFailure;

  /// No description provided for @forecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Runs out in'**
  String get forecastTitle;

  /// No description provided for @forecastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From the last 60 days of eating'**
  String get forecastSubtitle;

  /// No description provided for @forecastDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{≈ 1 day} other{≈ {count} days}}'**
  String forecastDays(int count);

  /// No description provided for @forecastNever.
  ///
  /// In en, this message translates to:
  /// **'no recent use'**
  String get forecastNever;

  /// No description provided for @forecastEmpty.
  ///
  /// In en, this message translates to:
  /// **'Set a minimum quantity for a product to see when it runs out.'**
  String get forecastEmpty;

  /// No description provided for @forecastNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No product with a minimum quantity matches these filters.'**
  String get forecastNoMatch;

  /// No description provided for @forecastTableProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get forecastTableProduct;

  /// No description provided for @forecastTableStock.
  ///
  /// In en, this message translates to:
  /// **'In freezer'**
  String get forecastTableStock;

  /// No description provided for @forecastTableDays.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get forecastTableDays;

  /// No description provided for @forecastAddedToList.
  ///
  /// In en, this message translates to:
  /// **'{productName} is on the shopping list'**
  String forecastAddedToList(String productName);
}

class _RestockLocalizationsDelegate extends LocalizationsDelegate<RestockLocalizations> {
  const _RestockLocalizationsDelegate();

  @override
  Future<RestockLocalizations> load(Locale locale) {
    return SynchronousFuture<RestockLocalizations>(lookupRestockLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_RestockLocalizationsDelegate old) => false;
}

RestockLocalizations lookupRestockLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return RestockLocalizationsDe();
    case 'en':
      return RestockLocalizationsEn();
  }

  throw FlutterError(
    'RestockLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
