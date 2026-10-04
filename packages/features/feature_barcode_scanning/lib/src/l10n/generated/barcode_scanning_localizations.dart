import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'barcode_scanning_localizations_de.dart';
import 'barcode_scanning_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of BarcodeScanningLocalizations
/// returned by `BarcodeScanningLocalizations.of(context)`.
///
/// Applications need to include `BarcodeScanningLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/barcode_scanning_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: BarcodeScanningLocalizations.localizationsDelegates,
///   supportedLocales: BarcodeScanningLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the BarcodeScanningLocalizations.supportedLocales
/// property.
abstract class BarcodeScanningLocalizations {
  BarcodeScanningLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static BarcodeScanningLocalizations of(BuildContext context) {
    return Localizations.of<BarcodeScanningLocalizations>(context, BarcodeScanningLocalizations)!;
  }

  static const LocalizationsDelegate<BarcodeScanningLocalizations> delegate =
      _BarcodeScanningLocalizationsDelegate();

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

  /// No description provided for @optionalFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Barcode scanning'**
  String get optionalFeatureTitle;

  /// No description provided for @optionalFeatureDetail.
  ///
  /// In en, this message translates to:
  /// **'Uses the camera, on this phone only'**
  String get optionalFeatureDetail;

  /// No description provided for @quickActionScanToAdd.
  ///
  /// In en, this message translates to:
  /// **'Scan to add'**
  String get quickActionScanToAdd;

  /// No description provided for @quickActionScanToRemove.
  ///
  /// In en, this message translates to:
  /// **'Scan to remove'**
  String get quickActionScanToRemove;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scannerTitle;

  /// No description provided for @scanModeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get scanModeAdd;

  /// No description provided for @scanModeRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get scanModeRemove;

  /// No description provided for @scannerHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the barcode inside the frame'**
  String get scannerHint;

  /// No description provided for @scannerPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Scanned on this phone. Nothing is sent anywhere.'**
  String get scannerPrivacy;

  /// No description provided for @recognized.
  ///
  /// In en, this message translates to:
  /// **'Recognised'**
  String get recognized;

  /// No description provided for @amountInStoragePlace.
  ///
  /// In en, this message translates to:
  /// **'{amount} in the freezer'**
  String amountInStoragePlace(String amount);

  /// No description provided for @weightInCode.
  ///
  /// In en, this message translates to:
  /// **'Weight in the code: {weight}'**
  String weightInCode(String weight);

  /// No description provided for @addToDrawer.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} to {drawer}'**
  String addToDrawer(String amount, String drawer);

  /// No description provided for @changeDetails.
  ///
  /// In en, this message translates to:
  /// **'Change details'**
  String get changeDetails;

  /// No description provided for @addedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Added {amount} of {product} to {drawer}'**
  String addedSnackbar(String amount, String product, String drawer);

  /// No description provided for @bagsInStoragePlace.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bag in the freezer. Take from it?} other{{count} bags in the freezer. Take from the oldest?}}'**
  String bagsInStoragePlace(int count);

  /// No description provided for @chooseAmount.
  ///
  /// In en, this message translates to:
  /// **'Choose amount'**
  String get chooseAmount;

  /// No description provided for @otherBags.
  ///
  /// In en, this message translates to:
  /// **'Or another bag'**
  String get otherBags;

  /// No description provided for @notInStoragePlace.
  ///
  /// In en, this message translates to:
  /// **'None of this product is in the freezer.'**
  String get notInStoragePlace;

  /// No description provided for @unknownCode.
  ///
  /// In en, this message translates to:
  /// **'New code {code}. Which product is this?'**
  String unknownCode(String code);

  /// No description provided for @chooseProduct.
  ///
  /// In en, this message translates to:
  /// **'Choose product'**
  String get chooseProduct;

  /// No description provided for @learnedCode.
  ///
  /// In en, this message translates to:
  /// **'Learned. Next time this code is recognised instantly.'**
  String get learnedCode;

  /// No description provided for @wrongProduct.
  ///
  /// In en, this message translates to:
  /// **'Not this product?'**
  String get wrongProduct;

  /// No description provided for @scanNext.
  ///
  /// In en, this message translates to:
  /// **'Scan next'**
  String get scanNext;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off. Allow it in the phone\'s settings to scan.'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The camera cannot be started.'**
  String get cameraUnavailable;

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This product is no longer available.'**
  String get productUnavailable;

  /// No description provided for @scanSeveral.
  ///
  /// In en, this message translates to:
  /// **'Several in a row'**
  String get scanSeveral;

  /// No description provided for @unpackingListTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Scan your groceries one after another} =1{1 item to put away} other{{count} items to put away}}'**
  String unpackingListTitle(int count);

  /// No description provided for @amountNeeded.
  ///
  /// In en, this message translates to:
  /// **'Amount needed'**
  String get amountNeeded;

  /// No description provided for @noStoragePlaceYet.
  ///
  /// In en, this message translates to:
  /// **'Set up a freezer first'**
  String get noStoragePlaceYet;

  /// No description provided for @putAwayButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Put 1 item in the freezer} other{Put {count} items in the freezer}}'**
  String putAwayButton(int count);

  /// No description provided for @putAwaySnackbar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item put in the freezer} other{{count} items put in the freezer}}'**
  String putAwaySnackbar(int count);

  /// No description provided for @removeFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove from the list'**
  String get removeFromList;

  /// No description provided for @amountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'How much is it?'**
  String get amountDialogTitle;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero.'**
  String get invalidAmount;

  /// No description provided for @discardListTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard the scanned items?'**
  String get discardListTitle;

  /// No description provided for @discardListMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item is not in the freezer yet.} other{{count} items are not in the freezer yet.}}'**
  String discardListMessage(int count);

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;
}

class _BarcodeScanningLocalizationsDelegate
    extends LocalizationsDelegate<BarcodeScanningLocalizations> {
  const _BarcodeScanningLocalizationsDelegate();

  @override
  Future<BarcodeScanningLocalizations> load(Locale locale) {
    return SynchronousFuture<BarcodeScanningLocalizations>(
      lookupBarcodeScanningLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_BarcodeScanningLocalizationsDelegate old) => false;
}

BarcodeScanningLocalizations lookupBarcodeScanningLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return BarcodeScanningLocalizationsDe();
    case 'en':
      return BarcodeScanningLocalizationsEn();
  }

  throw FlutterError(
    'BarcodeScanningLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
