import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'item_pictures_localizations_de.dart';
import 'item_pictures_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ItemPicturesLocalizations
/// returned by `ItemPicturesLocalizations.of(context)`.
///
/// Applications need to include `ItemPicturesLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/item_pictures_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ItemPicturesLocalizations.localizationsDelegates,
///   supportedLocales: ItemPicturesLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ItemPicturesLocalizations.supportedLocales
/// property.
abstract class ItemPicturesLocalizations {
  ItemPicturesLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ItemPicturesLocalizations of(BuildContext context) {
    return Localizations.of<ItemPicturesLocalizations>(context, ItemPicturesLocalizations)!;
  }

  static const LocalizationsDelegate<ItemPicturesLocalizations> delegate =
      _ItemPicturesLocalizationsDelegate();

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
  /// **'Item pictures'**
  String get optionalFeatureTitle;

  /// No description provided for @optionalFeatureDetail.
  ///
  /// In en, this message translates to:
  /// **'Photos of products and leftovers'**
  String get optionalFeatureDetail;

  /// No description provided for @takeOrChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'📷 Take or choose a photo'**
  String get takeOrChoosePhoto;

  /// No description provided for @photoOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional. Location data is removed from photos.'**
  String get photoOptional;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added · location data removed'**
  String get photoAdded;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromPhotos.
  ///
  /// In en, this message translates to:
  /// **'Choose from your photos'**
  String get chooseFromPhotos;

  /// No description provided for @viewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewPhoto;

  /// No description provided for @replacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replacePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removePhoto;

  /// No description provided for @removePhotoQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove this photo?'**
  String get removePhotoQuestion;

  /// No description provided for @removePhotoExplanation.
  ///
  /// In en, this message translates to:
  /// **'The photo is deleted from this phone.'**
  String get removePhotoExplanation;

  /// No description provided for @photoNotReadable.
  ///
  /// In en, this message translates to:
  /// **'This photo cannot be read. Try another one.'**
  String get photoNotReadable;

  /// No description provided for @photoSourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The camera or your photos are not available.'**
  String get photoSourceUnavailable;

  /// No description provided for @photoProcessing.
  ///
  /// In en, this message translates to:
  /// **'Removing location data…'**
  String get photoProcessing;

  /// No description provided for @photoSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoSemanticsLabel;

  /// No description provided for @photoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoSectionTitle;

  /// No description provided for @batchPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Without its own photo, this bag shows the product\'s photo.'**
  String get batchPhotoHint;
}

class _ItemPicturesLocalizationsDelegate extends LocalizationsDelegate<ItemPicturesLocalizations> {
  const _ItemPicturesLocalizationsDelegate();

  @override
  Future<ItemPicturesLocalizations> load(Locale locale) {
    return SynchronousFuture<ItemPicturesLocalizations>(lookupItemPicturesLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ItemPicturesLocalizationsDelegate old) => false;
}

ItemPicturesLocalizations lookupItemPicturesLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return ItemPicturesLocalizationsDe();
    case 'en':
      return ItemPicturesLocalizationsEn();
  }

  throw FlutterError(
    'ItemPicturesLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
