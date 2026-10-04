import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'household_supplies_localizations_de.dart';
import 'household_supplies_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of HouseholdSuppliesLocalizations
/// returned by `HouseholdSuppliesLocalizations.of(context)`.
///
/// Applications need to include `HouseholdSuppliesLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/household_supplies_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: HouseholdSuppliesLocalizations.localizationsDelegates,
///   supportedLocales: HouseholdSuppliesLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the HouseholdSuppliesLocalizations.supportedLocales
/// property.
abstract class HouseholdSuppliesLocalizations {
  HouseholdSuppliesLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static HouseholdSuppliesLocalizations of(BuildContext context) {
    return Localizations.of<HouseholdSuppliesLocalizations>(
      context,
      HouseholdSuppliesLocalizations,
    )!;
  }

  static const LocalizationsDelegate<HouseholdSuppliesLocalizations> delegate =
      _HouseholdSuppliesLocalizationsDelegate();

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
  /// **'Household'**
  String get domainLabel;

  /// No description provided for @domainDescription.
  ///
  /// In en, this message translates to:
  /// **'Cleaning, laundry, bathroom and kitchen paper'**
  String get domainDescription;

  /// No description provided for @storedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Bought on'**
  String get storedOnLabel;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add supplies'**
  String get addTitle;

  /// No description provided for @bestBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get bestBeforeLabel;

  /// No description provided for @cleaningCupboardName.
  ///
  /// In en, this message translates to:
  /// **'Cleaning cupboard'**
  String get cleaningCupboardName;

  /// No description provided for @cleaningCupboardDescription.
  ///
  /// In en, this message translates to:
  /// **'cleaning cupboard'**
  String get cleaningCupboardDescription;

  /// No description provided for @bathroomCabinetName.
  ///
  /// In en, this message translates to:
  /// **'Bathroom cabinet'**
  String get bathroomCabinetName;

  /// No description provided for @bathroomCabinetDescription.
  ///
  /// In en, this message translates to:
  /// **'bathroom cabinet'**
  String get bathroomCabinetDescription;

  /// No description provided for @laundryRoomName.
  ///
  /// In en, this message translates to:
  /// **'Laundry room'**
  String get laundryRoomName;

  /// No description provided for @laundryRoomDescription.
  ///
  /// In en, this message translates to:
  /// **'laundry room'**
  String get laundryRoomDescription;

  /// No description provided for @gardenShedName.
  ///
  /// In en, this message translates to:
  /// **'Garden shed'**
  String get gardenShedName;

  /// No description provided for @gardenShedDescription.
  ///
  /// In en, this message translates to:
  /// **'garden shed'**
  String get gardenShedDescription;

  /// No description provided for @garageName.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garageName;

  /// No description provided for @garageDescription.
  ///
  /// In en, this message translates to:
  /// **'garage'**
  String get garageDescription;

  /// No description provided for @storageRoomName.
  ///
  /// In en, this message translates to:
  /// **'Storage room'**
  String get storageRoomName;

  /// No description provided for @storageRoomDescription.
  ///
  /// In en, this message translates to:
  /// **'storage room'**
  String get storageRoomDescription;

  /// No description provided for @firstAidBoxName.
  ///
  /// In en, this message translates to:
  /// **'First-aid box'**
  String get firstAidBoxName;

  /// No description provided for @firstAidBoxDescription.
  ///
  /// In en, this message translates to:
  /// **'first-aid box'**
  String get firstAidBoxDescription;

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

  /// No description provided for @boxName.
  ///
  /// In en, this message translates to:
  /// **'Box {number}'**
  String boxName(int number);

  /// No description provided for @boxCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 box} other{{count} boxes}}'**
  String boxCount(int count);

  /// No description provided for @addBox.
  ///
  /// In en, this message translates to:
  /// **'Add box'**
  String get addBox;

  /// No description provided for @templateCleaningCupboard.
  ///
  /// In en, this message translates to:
  /// **'Cleaning cupboard with 3 shelves'**
  String get templateCleaningCupboard;

  /// No description provided for @templateBathroomCabinet.
  ///
  /// In en, this message translates to:
  /// **'Bathroom cabinet with 3 shelves'**
  String get templateBathroomCabinet;

  /// No description provided for @templateLaundryRoom.
  ///
  /// In en, this message translates to:
  /// **'Laundry room with 2 shelves'**
  String get templateLaundryRoom;

  /// No description provided for @templateGardenShed.
  ///
  /// In en, this message translates to:
  /// **'Garden shed with 2 shelves'**
  String get templateGardenShed;

  /// No description provided for @templateGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage with 3 shelves'**
  String get templateGarage;

  /// No description provided for @templateStorageRoom.
  ///
  /// In en, this message translates to:
  /// **'Storage room with 4 shelves'**
  String get templateStorageRoom;

  /// No description provided for @templateFirstAidBox.
  ///
  /// In en, this message translates to:
  /// **'One first-aid box'**
  String get templateFirstAidBox;

  /// No description provided for @categoryCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get categoryCleaning;

  /// No description provided for @categoryLaundry.
  ///
  /// In en, this message translates to:
  /// **'Laundry'**
  String get categoryLaundry;

  /// No description provided for @categoryBathroomAndCare.
  ///
  /// In en, this message translates to:
  /// **'Bathroom and personal care'**
  String get categoryBathroomAndCare;

  /// No description provided for @categoryKitchenPaperAndWrap.
  ///
  /// In en, this message translates to:
  /// **'Kitchen paper and wrap'**
  String get categoryKitchenPaperAndWrap;

  /// No description provided for @productDishSoap.
  ///
  /// In en, this message translates to:
  /// **'Dish soap'**
  String get productDishSoap;

  /// No description provided for @productDishwasherTabs.
  ///
  /// In en, this message translates to:
  /// **'Dishwasher tabs'**
  String get productDishwasherTabs;

  /// No description provided for @productAllPurposeCleaner.
  ///
  /// In en, this message translates to:
  /// **'All-purpose cleaner'**
  String get productAllPurposeCleaner;

  /// No description provided for @productGlassCleaner.
  ///
  /// In en, this message translates to:
  /// **'Glass cleaner'**
  String get productGlassCleaner;

  /// No description provided for @productDescaler.
  ///
  /// In en, this message translates to:
  /// **'Descaler'**
  String get productDescaler;

  /// No description provided for @productSpongesAndCloths.
  ///
  /// In en, this message translates to:
  /// **'Sponges and cloths'**
  String get productSpongesAndCloths;

  /// No description provided for @productBinBags.
  ///
  /// In en, this message translates to:
  /// **'Bin bags'**
  String get productBinBags;

  /// No description provided for @productDetergent.
  ///
  /// In en, this message translates to:
  /// **'Detergent'**
  String get productDetergent;

  /// No description provided for @productSoftener.
  ///
  /// In en, this message translates to:
  /// **'Softener'**
  String get productSoftener;

  /// No description provided for @productStainRemover.
  ///
  /// In en, this message translates to:
  /// **'Stain remover'**
  String get productStainRemover;

  /// No description provided for @productToiletPaper.
  ///
  /// In en, this message translates to:
  /// **'Toilet paper'**
  String get productToiletPaper;

  /// No description provided for @productHandSoap.
  ///
  /// In en, this message translates to:
  /// **'Hand soap'**
  String get productHandSoap;

  /// No description provided for @productToothpaste.
  ///
  /// In en, this message translates to:
  /// **'Toothpaste'**
  String get productToothpaste;

  /// No description provided for @productToothbrushes.
  ///
  /// In en, this message translates to:
  /// **'Toothbrushes'**
  String get productToothbrushes;

  /// No description provided for @productShampoo.
  ///
  /// In en, this message translates to:
  /// **'Shampoo'**
  String get productShampoo;

  /// No description provided for @productShowerGel.
  ///
  /// In en, this message translates to:
  /// **'Shower gel'**
  String get productShowerGel;

  /// No description provided for @productDeodorant.
  ///
  /// In en, this message translates to:
  /// **'Deodorant'**
  String get productDeodorant;

  /// No description provided for @productRazorBlades.
  ///
  /// In en, this message translates to:
  /// **'Razor blades'**
  String get productRazorBlades;

  /// No description provided for @productCottonPads.
  ///
  /// In en, this message translates to:
  /// **'Cotton pads'**
  String get productCottonPads;

  /// No description provided for @productSanitaryProducts.
  ///
  /// In en, this message translates to:
  /// **'Sanitary products'**
  String get productSanitaryProducts;

  /// No description provided for @productKitchenRoll.
  ///
  /// In en, this message translates to:
  /// **'Kitchen roll'**
  String get productKitchenRoll;

  /// No description provided for @productTissues.
  ///
  /// In en, this message translates to:
  /// **'Tissues'**
  String get productTissues;

  /// No description provided for @productAluminiumFoil.
  ///
  /// In en, this message translates to:
  /// **'Aluminium foil'**
  String get productAluminiumFoil;

  /// No description provided for @productClingFilm.
  ///
  /// In en, this message translates to:
  /// **'Cling film'**
  String get productClingFilm;

  /// No description provided for @productBakingPaper.
  ///
  /// In en, this message translates to:
  /// **'Baking paper'**
  String get productBakingPaper;

  /// No description provided for @productFreezerBags.
  ///
  /// In en, this message translates to:
  /// **'Freezer bags'**
  String get productFreezerBags;
}

class _HouseholdSuppliesLocalizationsDelegate
    extends LocalizationsDelegate<HouseholdSuppliesLocalizations> {
  const _HouseholdSuppliesLocalizationsDelegate();

  @override
  Future<HouseholdSuppliesLocalizations> load(Locale locale) {
    return SynchronousFuture<HouseholdSuppliesLocalizations>(
      lookupHouseholdSuppliesLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_HouseholdSuppliesLocalizationsDelegate old) => false;
}

HouseholdSuppliesLocalizations lookupHouseholdSuppliesLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return HouseholdSuppliesLocalizationsDe();
    case 'en':
      return HouseholdSuppliesLocalizationsEn();
  }

  throw FlutterError(
    'HouseholdSuppliesLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
