import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'freezer_localizations_de.dart';
import 'freezer_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FreezerLocalizations
/// returned by `FreezerLocalizations.of(context)`.
///
/// Applications need to include `FreezerLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/freezer_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FreezerLocalizations.localizationsDelegates,
///   supportedLocales: FreezerLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FreezerLocalizations.supportedLocales
/// property.
abstract class FreezerLocalizations {
  FreezerLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FreezerLocalizations of(BuildContext context) {
    return Localizations.of<FreezerLocalizations>(context, FreezerLocalizations)!;
  }

  static const LocalizationsDelegate<FreezerLocalizations> delegate =
      _FreezerLocalizationsDelegate();

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
  /// **'Freezer'**
  String get domainLabel;

  /// No description provided for @domainDescription.
  ///
  /// In en, this message translates to:
  /// **'Frozen food, drawers and baskets'**
  String get domainDescription;

  /// No description provided for @storedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Frozen on'**
  String get storedOnLabel;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to the freezer'**
  String get addTitle;

  /// No description provided for @uprightName.
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get uprightName;

  /// No description provided for @chestName.
  ///
  /// In en, this message translates to:
  /// **'Chest freezer'**
  String get chestName;

  /// No description provided for @fridgeFreezerName.
  ///
  /// In en, this message translates to:
  /// **'Fridge freezer'**
  String get fridgeFreezerName;

  /// No description provided for @uprightDescription.
  ///
  /// In en, this message translates to:
  /// **'upright'**
  String get uprightDescription;

  /// No description provided for @chestDescription.
  ///
  /// In en, this message translates to:
  /// **'chest freezer'**
  String get chestDescription;

  /// No description provided for @fridgeFreezerDescription.
  ///
  /// In en, this message translates to:
  /// **'in the fridge'**
  String get fridgeFreezerDescription;

  /// No description provided for @drawerName.
  ///
  /// In en, this message translates to:
  /// **'Drawer {number}'**
  String drawerName(int number);

  /// No description provided for @basketName.
  ///
  /// In en, this message translates to:
  /// **'Basket {number}'**
  String basketName(int number);

  /// No description provided for @compartmentName.
  ///
  /// In en, this message translates to:
  /// **'Compartment {number}'**
  String compartmentName(int number);

  /// No description provided for @drawerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drawer} other{{count} drawers}}'**
  String drawerCount(int count);

  /// No description provided for @basketCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 basket} other{{count} baskets}}'**
  String basketCount(int count);

  /// No description provided for @compartmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 compartment} other{{count} compartments}}'**
  String compartmentCount(int count);

  /// No description provided for @addDrawer.
  ///
  /// In en, this message translates to:
  /// **'Add drawer'**
  String get addDrawer;

  /// No description provided for @addBasket.
  ///
  /// In en, this message translates to:
  /// **'Add basket'**
  String get addBasket;

  /// No description provided for @addCompartment.
  ///
  /// In en, this message translates to:
  /// **'Add compartment'**
  String get addCompartment;

  /// No description provided for @templateUprightWithThreeDrawers.
  ///
  /// In en, this message translates to:
  /// **'Upright freezer with 3 drawers'**
  String get templateUprightWithThreeDrawers;

  /// No description provided for @templateUprightWithFiveDrawers.
  ///
  /// In en, this message translates to:
  /// **'Upright freezer with 5 drawers'**
  String get templateUprightWithFiveDrawers;

  /// No description provided for @templateUprightWithSevenDrawers.
  ///
  /// In en, this message translates to:
  /// **'Upright freezer with 7 drawers'**
  String get templateUprightWithSevenDrawers;

  /// No description provided for @templateChestWithBaskets.
  ///
  /// In en, this message translates to:
  /// **'Chest freezer with 3 baskets'**
  String get templateChestWithBaskets;

  /// No description provided for @templateFridgeFreezerCompartment.
  ///
  /// In en, this message translates to:
  /// **'Freezer compartment of a fridge'**
  String get templateFridgeFreezerCompartment;

  /// No description provided for @templateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start with one drawer and add the rest yourself'**
  String get templateEmpty;

  /// No description provided for @categoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoryVegetables;

  /// No description provided for @categoryFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get categoryFruit;

  /// No description provided for @categoryMeatAndFish.
  ///
  /// In en, this message translates to:
  /// **'Meat & fish'**
  String get categoryMeatAndFish;

  /// No description provided for @categoryMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get categoryMeals;

  /// No description provided for @categoryBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get categoryBakery;

  /// No description provided for @categoryDesserts.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get categoryDesserts;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @productLeafSpinach.
  ///
  /// In en, this message translates to:
  /// **'Leaf spinach'**
  String get productLeafSpinach;

  /// No description provided for @productGardenPeas.
  ///
  /// In en, this message translates to:
  /// **'Garden peas'**
  String get productGardenPeas;

  /// No description provided for @productBroccoli.
  ///
  /// In en, this message translates to:
  /// **'Broccoli'**
  String get productBroccoli;

  /// No description provided for @productMixedVegetables.
  ///
  /// In en, this message translates to:
  /// **'Mixed vegetables'**
  String get productMixedVegetables;

  /// No description provided for @productHerbs.
  ///
  /// In en, this message translates to:
  /// **'Herbs'**
  String get productHerbs;

  /// No description provided for @productFrenchFries.
  ///
  /// In en, this message translates to:
  /// **'French fries'**
  String get productFrenchFries;

  /// No description provided for @productMixedBerries.
  ///
  /// In en, this message translates to:
  /// **'Mixed berries'**
  String get productMixedBerries;

  /// No description provided for @productStrawberries.
  ///
  /// In en, this message translates to:
  /// **'Strawberries'**
  String get productStrawberries;

  /// No description provided for @productMango.
  ///
  /// In en, this message translates to:
  /// **'Mango'**
  String get productMango;

  /// No description provided for @productChickenBreast.
  ///
  /// In en, this message translates to:
  /// **'Chicken breast'**
  String get productChickenBreast;

  /// No description provided for @productMincedMeat.
  ///
  /// In en, this message translates to:
  /// **'Minced meat'**
  String get productMincedMeat;

  /// No description provided for @productSalmonFillet.
  ///
  /// In en, this message translates to:
  /// **'Salmon fillet'**
  String get productSalmonFillet;

  /// No description provided for @productFishFingers.
  ///
  /// In en, this message translates to:
  /// **'Fish fingers'**
  String get productFishFingers;

  /// No description provided for @productPrawns.
  ///
  /// In en, this message translates to:
  /// **'Prawns'**
  String get productPrawns;

  /// No description provided for @productBologneseHomemade.
  ///
  /// In en, this message translates to:
  /// **'Bolognese (homemade)'**
  String get productBologneseHomemade;

  /// No description provided for @productSoupHomemade.
  ///
  /// In en, this message translates to:
  /// **'Soup (homemade)'**
  String get productSoupHomemade;

  /// No description provided for @productLasagne.
  ///
  /// In en, this message translates to:
  /// **'Lasagne'**
  String get productLasagne;

  /// No description provided for @productPizzaMargherita.
  ///
  /// In en, this message translates to:
  /// **'Pizza Margherita'**
  String get productPizzaMargherita;

  /// No description provided for @productWholegrainBread.
  ///
  /// In en, this message translates to:
  /// **'Wholegrain bread'**
  String get productWholegrainBread;

  /// No description provided for @productBreadRolls.
  ///
  /// In en, this message translates to:
  /// **'Bread rolls'**
  String get productBreadRolls;

  /// No description provided for @productCroissants.
  ///
  /// In en, this message translates to:
  /// **'Croissants'**
  String get productCroissants;

  /// No description provided for @productVanillaIceCream.
  ///
  /// In en, this message translates to:
  /// **'Vanilla ice cream'**
  String get productVanillaIceCream;

  /// No description provided for @productCake.
  ///
  /// In en, this message translates to:
  /// **'Cake'**
  String get productCake;

  /// No description provided for @productButter.
  ///
  /// In en, this message translates to:
  /// **'Butter'**
  String get productButter;
}

class _FreezerLocalizationsDelegate extends LocalizationsDelegate<FreezerLocalizations> {
  const _FreezerLocalizationsDelegate();

  @override
  Future<FreezerLocalizations> load(Locale locale) {
    return SynchronousFuture<FreezerLocalizations>(lookupFreezerLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_FreezerLocalizationsDelegate old) => false;
}

FreezerLocalizations lookupFreezerLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FreezerLocalizationsDe();
    case 'en':
      return FreezerLocalizationsEn();
  }

  throw FlutterError(
    'FreezerLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
