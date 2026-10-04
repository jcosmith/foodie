import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'pantry_localizations_de.dart';
import 'pantry_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of PantryLocalizations
/// returned by `PantryLocalizations.of(context)`.
///
/// Applications need to include `PantryLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/pantry_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: PantryLocalizations.localizationsDelegates,
///   supportedLocales: PantryLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the PantryLocalizations.supportedLocales
/// property.
abstract class PantryLocalizations {
  PantryLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static PantryLocalizations of(BuildContext context) {
    return Localizations.of<PantryLocalizations>(context, PantryLocalizations)!;
  }

  static const LocalizationsDelegate<PantryLocalizations> delegate = _PantryLocalizationsDelegate();

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
  /// **'Pantry'**
  String get domainLabel;

  /// No description provided for @domainDescription.
  ///
  /// In en, this message translates to:
  /// **'Dry goods, tins, bread and drinks'**
  String get domainDescription;

  /// No description provided for @storedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Bought on'**
  String get storedOnLabel;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to the pantry'**
  String get addTitle;

  /// No description provided for @pantryName.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantryName;

  /// No description provided for @pantryDescription.
  ///
  /// In en, this message translates to:
  /// **'pantry'**
  String get pantryDescription;

  /// No description provided for @kitchenCupboardName.
  ///
  /// In en, this message translates to:
  /// **'Kitchen cupboard'**
  String get kitchenCupboardName;

  /// No description provided for @kitchenCupboardDescription.
  ///
  /// In en, this message translates to:
  /// **'kitchen cupboard'**
  String get kitchenCupboardDescription;

  /// No description provided for @cellarName.
  ///
  /// In en, this message translates to:
  /// **'Cellar'**
  String get cellarName;

  /// No description provided for @cellarDescription.
  ///
  /// In en, this message translates to:
  /// **'cellar'**
  String get cellarDescription;

  /// No description provided for @drinksCrateName.
  ///
  /// In en, this message translates to:
  /// **'Drinks crates'**
  String get drinksCrateName;

  /// No description provided for @drinksCrateDescription.
  ///
  /// In en, this message translates to:
  /// **'drinks crates'**
  String get drinksCrateDescription;

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

  /// No description provided for @crateName.
  ///
  /// In en, this message translates to:
  /// **'Crate {number}'**
  String crateName(int number);

  /// No description provided for @crateCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 crate} other{{count} crates}}'**
  String crateCount(int count);

  /// No description provided for @addCrate.
  ///
  /// In en, this message translates to:
  /// **'Add crate'**
  String get addCrate;

  /// No description provided for @templatePantryShelves.
  ///
  /// In en, this message translates to:
  /// **'Pantry with 4 shelves'**
  String get templatePantryShelves;

  /// No description provided for @templateKitchenCupboard.
  ///
  /// In en, this message translates to:
  /// **'Kitchen cupboard with 2 shelves'**
  String get templateKitchenCupboard;

  /// No description provided for @templateCellar.
  ///
  /// In en, this message translates to:
  /// **'Cellar with 3 shelves'**
  String get templateCellar;

  /// No description provided for @templateDrinksCrate.
  ///
  /// In en, this message translates to:
  /// **'One drinks crate'**
  String get templateDrinksCrate;

  /// No description provided for @categoryBreadAndBakery.
  ///
  /// In en, this message translates to:
  /// **'Bread and bakery'**
  String get categoryBreadAndBakery;

  /// No description provided for @categoryDryGoods.
  ///
  /// In en, this message translates to:
  /// **'Pasta, rice and grains'**
  String get categoryDryGoods;

  /// No description provided for @categoryTinsAndJars.
  ///
  /// In en, this message translates to:
  /// **'Tins and jars'**
  String get categoryTinsAndJars;

  /// No description provided for @categorySpicesAndCondiments.
  ///
  /// In en, this message translates to:
  /// **'Spices and sauces'**
  String get categorySpicesAndCondiments;

  /// No description provided for @categoryOilsAndVinegar.
  ///
  /// In en, this message translates to:
  /// **'Oil and vinegar'**
  String get categoryOilsAndVinegar;

  /// No description provided for @categoryBaking.
  ///
  /// In en, this message translates to:
  /// **'Baking'**
  String get categoryBaking;

  /// No description provided for @categoryBreakfastAndSpreads.
  ///
  /// In en, this message translates to:
  /// **'Breakfast and spreads'**
  String get categoryBreakfastAndSpreads;

  /// No description provided for @categorySnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks and sweets'**
  String get categorySnacks;

  /// No description provided for @categoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get categoryDrinks;

  /// No description provided for @productFreshBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get productFreshBread;

  /// No description provided for @productToastBread.
  ///
  /// In en, this message translates to:
  /// **'Toast bread'**
  String get productToastBread;

  /// No description provided for @productPasta.
  ///
  /// In en, this message translates to:
  /// **'Pasta'**
  String get productPasta;

  /// No description provided for @productRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get productRice;

  /// No description provided for @productOats.
  ///
  /// In en, this message translates to:
  /// **'Oats'**
  String get productOats;

  /// No description provided for @productCannedTomatoes.
  ///
  /// In en, this message translates to:
  /// **'Chopped tomatoes'**
  String get productCannedTomatoes;

  /// No description provided for @productChickpeas.
  ///
  /// In en, this message translates to:
  /// **'Chickpeas'**
  String get productChickpeas;

  /// No description provided for @productTuna.
  ///
  /// In en, this message translates to:
  /// **'Tuna'**
  String get productTuna;

  /// No description provided for @productSalt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get productSalt;

  /// No description provided for @productPepper.
  ///
  /// In en, this message translates to:
  /// **'Pepper'**
  String get productPepper;

  /// No description provided for @productKetchup.
  ///
  /// In en, this message translates to:
  /// **'Ketchup'**
  String get productKetchup;

  /// No description provided for @productMustard.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get productMustard;

  /// No description provided for @productOliveOil.
  ///
  /// In en, this message translates to:
  /// **'Olive oil'**
  String get productOliveOil;

  /// No description provided for @productVinegar.
  ///
  /// In en, this message translates to:
  /// **'Vinegar'**
  String get productVinegar;

  /// No description provided for @productFlour.
  ///
  /// In en, this message translates to:
  /// **'Flour'**
  String get productFlour;

  /// No description provided for @productSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get productSugar;

  /// No description provided for @productCornflakes.
  ///
  /// In en, this message translates to:
  /// **'Cornflakes'**
  String get productCornflakes;

  /// No description provided for @productJam.
  ///
  /// In en, this message translates to:
  /// **'Jam'**
  String get productJam;

  /// No description provided for @productHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get productHoney;

  /// No description provided for @productChocolateSpread.
  ///
  /// In en, this message translates to:
  /// **'Chocolate spread'**
  String get productChocolateSpread;

  /// No description provided for @productCrisps.
  ///
  /// In en, this message translates to:
  /// **'Crisps'**
  String get productCrisps;

  /// No description provided for @productBiscuits.
  ///
  /// In en, this message translates to:
  /// **'Biscuits'**
  String get productBiscuits;

  /// No description provided for @productMineralWater.
  ///
  /// In en, this message translates to:
  /// **'Mineral water'**
  String get productMineralWater;

  /// No description provided for @productOrangeJuice.
  ///
  /// In en, this message translates to:
  /// **'Orange juice'**
  String get productOrangeJuice;
}

class _PantryLocalizationsDelegate extends LocalizationsDelegate<PantryLocalizations> {
  const _PantryLocalizationsDelegate();

  @override
  Future<PantryLocalizations> load(Locale locale) {
    return SynchronousFuture<PantryLocalizations>(lookupPantryLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_PantryLocalizationsDelegate old) => false;
}

PantryLocalizations lookupPantryLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return PantryLocalizationsDe();
    case 'en':
      return PantryLocalizationsEn();
  }

  throw FlutterError(
    'PantryLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
