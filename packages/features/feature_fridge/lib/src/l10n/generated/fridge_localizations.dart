import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fridge_localizations_de.dart';
import 'fridge_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FridgeLocalizations
/// returned by `FridgeLocalizations.of(context)`.
///
/// Applications need to include `FridgeLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/fridge_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FridgeLocalizations.localizationsDelegates,
///   supportedLocales: FridgeLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FridgeLocalizations.supportedLocales
/// property.
abstract class FridgeLocalizations {
  FridgeLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FridgeLocalizations of(BuildContext context) {
    return Localizations.of<FridgeLocalizations>(context, FridgeLocalizations)!;
  }

  static const LocalizationsDelegate<FridgeLocalizations> delegate = _FridgeLocalizationsDelegate();

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

  /// No description provided for @domainLabel.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get domainLabel;

  /// No description provided for @domainDescription.
  ///
  /// In en, this message translates to:
  /// **'Fresh food that keeps for days'**
  String get domainDescription;

  /// No description provided for @storedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Bought on'**
  String get storedOnLabel;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to the fridge'**
  String get addTitle;

  /// No description provided for @fridgeName.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get fridgeName;

  /// No description provided for @drinksFridgeName.
  ///
  /// In en, this message translates to:
  /// **'Drinks fridge'**
  String get drinksFridgeName;

  /// No description provided for @wineFridgeName.
  ///
  /// In en, this message translates to:
  /// **'Wine fridge'**
  String get wineFridgeName;

  /// No description provided for @fridgeDescription.
  ///
  /// In en, this message translates to:
  /// **'fridge'**
  String get fridgeDescription;

  /// No description provided for @drinksFridgeDescription.
  ///
  /// In en, this message translates to:
  /// **'drinks fridge'**
  String get drinksFridgeDescription;

  /// No description provided for @wineFridgeDescription.
  ///
  /// In en, this message translates to:
  /// **'wine fridge'**
  String get wineFridgeDescription;

  /// No description provided for @shelfName.
  ///
  /// In en, this message translates to:
  /// **'Shelf {number}'**
  String shelfName(int number);

  /// No description provided for @shelfCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shelf} other{{count} shelves}}'**
  String shelfCount(int count);

  /// No description provided for @addShelf.
  ///
  /// In en, this message translates to:
  /// **'Add shelf'**
  String get addShelf;

  /// No description provided for @rackName.
  ///
  /// In en, this message translates to:
  /// **'Rack {number}'**
  String rackName(int number);

  /// No description provided for @rackCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rack} other{{count} racks}}'**
  String rackCount(int count);

  /// No description provided for @addRack.
  ///
  /// In en, this message translates to:
  /// **'Add rack'**
  String get addRack;

  /// No description provided for @templateThreeShelves.
  ///
  /// In en, this message translates to:
  /// **'Fridge with 3 shelves'**
  String get templateThreeShelves;

  /// No description provided for @templateFiveShelves.
  ///
  /// In en, this message translates to:
  /// **'Fridge with 5 shelves'**
  String get templateFiveShelves;

  /// No description provided for @templateDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks fridge with 3 shelves'**
  String get templateDrinks;

  /// No description provided for @templateWine.
  ///
  /// In en, this message translates to:
  /// **'Wine fridge with 4 racks'**
  String get templateWine;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy and eggs'**
  String get categoryDairy;

  /// No description provided for @categoryFreshProduce.
  ///
  /// In en, this message translates to:
  /// **'Fruit and vegetables'**
  String get categoryFreshProduce;

  /// No description provided for @categoryFreshMeatAndFish.
  ///
  /// In en, this message translates to:
  /// **'Fresh meat and fish'**
  String get categoryFreshMeatAndFish;

  /// No description provided for @categoryLeftovers.
  ///
  /// In en, this message translates to:
  /// **'Leftovers'**
  String get categoryLeftovers;

  /// No description provided for @categoryChilledOther.
  ///
  /// In en, this message translates to:
  /// **'Other chilled food'**
  String get categoryChilledOther;

  /// No description provided for @productMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get productMilk;

  /// No description provided for @productYoghurt.
  ///
  /// In en, this message translates to:
  /// **'Yoghurt'**
  String get productYoghurt;

  /// No description provided for @productCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get productCream;

  /// No description provided for @productSlicedCheese.
  ///
  /// In en, this message translates to:
  /// **'Sliced cheese'**
  String get productSlicedCheese;

  /// No description provided for @productMozzarella.
  ///
  /// In en, this message translates to:
  /// **'Mozzarella'**
  String get productMozzarella;

  /// No description provided for @productEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get productEggs;

  /// No description provided for @productLettuce.
  ///
  /// In en, this message translates to:
  /// **'Lettuce'**
  String get productLettuce;

  /// No description provided for @productTomatoes.
  ///
  /// In en, this message translates to:
  /// **'Tomatoes'**
  String get productTomatoes;

  /// No description provided for @productCucumber.
  ///
  /// In en, this message translates to:
  /// **'Cucumber'**
  String get productCucumber;

  /// No description provided for @productFreshHerbs.
  ///
  /// In en, this message translates to:
  /// **'Fresh herbs'**
  String get productFreshHerbs;

  /// No description provided for @productFreshMincedMeat.
  ///
  /// In en, this message translates to:
  /// **'Fresh minced meat'**
  String get productFreshMincedMeat;

  /// No description provided for @productFreshChickenBreast.
  ///
  /// In en, this message translates to:
  /// **'Fresh chicken breast'**
  String get productFreshChickenBreast;

  /// No description provided for @productFreshFish.
  ///
  /// In en, this message translates to:
  /// **'Fresh fish'**
  String get productFreshFish;

  /// No description provided for @productColdCuts.
  ///
  /// In en, this message translates to:
  /// **'Cold cuts'**
  String get productColdCuts;

  /// No description provided for @productLeftovers.
  ///
  /// In en, this message translates to:
  /// **'Leftovers'**
  String get productLeftovers;

  /// No description provided for @productPesto.
  ///
  /// In en, this message translates to:
  /// **'Pesto'**
  String get productPesto;
}

class _FridgeLocalizationsDelegate extends LocalizationsDelegate<FridgeLocalizations> {
  const _FridgeLocalizationsDelegate();

  @override
  Future<FridgeLocalizations> load(Locale locale) {
    return SynchronousFuture<FridgeLocalizations>(lookupFridgeLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_FridgeLocalizationsDelegate old) => false;
}

FridgeLocalizations lookupFridgeLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FridgeLocalizationsDe();
    case 'en':
      return FridgeLocalizationsEn();
  }

  throw FlutterError(
    'FridgeLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
