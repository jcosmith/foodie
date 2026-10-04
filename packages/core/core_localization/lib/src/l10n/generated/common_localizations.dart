import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'common_localizations_de.dart';
import 'common_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CommonLocalizations
/// returned by `CommonLocalizations.of(context)`.
///
/// Applications need to include `CommonLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/common_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CommonLocalizations.localizationsDelegates,
///   supportedLocales: CommonLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the CommonLocalizations.supportedLocales
/// property.
abstract class CommonLocalizations {
  CommonLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CommonLocalizations of(BuildContext context) {
    return Localizations.of<CommonLocalizations>(context, CommonLocalizations)!;
  }

  static const LocalizationsDelegate<CommonLocalizations> delegate = _CommonLocalizationsDelegate();

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

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @quantityGrams.
  ///
  /// In en, this message translates to:
  /// **'{amount} g'**
  String quantityGrams(String amount);

  /// No description provided for @quantityKilograms.
  ///
  /// In en, this message translates to:
  /// **'{amount} kg'**
  String quantityKilograms(String amount);

  /// No description provided for @quantityMilliliters.
  ///
  /// In en, this message translates to:
  /// **'{amount} ml'**
  String quantityMilliliters(String amount);

  /// No description provided for @quantityLiters.
  ///
  /// In en, this message translates to:
  /// **'{amount} l'**
  String quantityLiters(String amount);

  /// No description provided for @quantityPieces.
  ///
  /// In en, this message translates to:
  /// **'{amount} pcs'**
  String quantityPieces(String amount);

  /// No description provided for @quantityPortions.
  ///
  /// In en, this message translates to:
  /// **'{amount} {count, plural, =1{portion} other{portions}}'**
  String quantityPortions(String amount, num count);

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get unitGram;

  /// No description provided for @unitMilliliter.
  ///
  /// In en, this message translates to:
  /// **'Millilitres'**
  String get unitMilliliter;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get unitPiece;

  /// No description provided for @unitPortion.
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get unitPortion;

  /// No description provided for @unitSymbolGram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitSymbolGram;

  /// No description provided for @unitSymbolMilliliter.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitSymbolMilliliter;

  /// No description provided for @unitSymbolPiece.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitSymbolPiece;

  /// No description provided for @unitSymbolPortion.
  ///
  /// In en, this message translates to:
  /// **'portions'**
  String get unitSymbolPortion;

  /// No description provided for @relativeAgeToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get relativeAgeToday;

  /// No description provided for @relativeAgeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeAgeYesterday;

  /// No description provided for @relativeAgeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String relativeAgeDays(int count);

  /// No description provided for @relativeAgeWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String relativeAgeWeeks(int count);

  /// No description provided for @relativeAgeMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String relativeAgeMonths(int count);

  /// No description provided for @relativeAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String relativeAgeYears(int count);

  /// No description provided for @shelfLifeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String shelfLifeDays(int count);

  /// No description provided for @shelfLifeWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String shelfLifeWeeks(int count);

  /// No description provided for @shelfLifeMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String shelfLifeMonths(int count);

  /// No description provided for @shelfLifeAboutWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{about 1 week} other{about {count} weeks}}'**
  String shelfLifeAboutWeeks(int count);

  /// No description provided for @shelfLifeAboutMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{about 1 month} other{about {count} months}}'**
  String shelfLifeAboutMonths(int count);

  /// No description provided for @shelfLifeUnitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get shelfLifeUnitDays;

  /// No description provided for @shelfLifeUnitWeeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get shelfLifeUnitWeeks;

  /// No description provided for @shelfLifeUnitMonths.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get shelfLifeUnitMonths;

  /// No description provided for @shelfLifeUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get shelfLifeUnitLabel;

  /// No description provided for @shelfLifeOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Enter between 1 day and 36 months.'**
  String get shelfLifeOutOfRange;

  /// No description provided for @storageAgeFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get storageAgeFresh;

  /// No description provided for @storageAgeAging.
  ///
  /// In en, this message translates to:
  /// **'Use soon'**
  String get storageAgeAging;

  /// No description provided for @storageAgeUrgent.
  ///
  /// In en, this message translates to:
  /// **'Eat now'**
  String get storageAgeUrgent;

  /// No description provided for @storageAgeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get storageAgeOverdue;

  /// No description provided for @emptyStateNothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateNothingHereYet;

  /// No description provided for @privacyPromise.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves this phone'**
  String get privacyPromise;

  /// No description provided for @chartShowTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get chartShowTable;

  /// No description provided for @chartShowChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chartShowChart;
}

class _CommonLocalizationsDelegate extends LocalizationsDelegate<CommonLocalizations> {
  const _CommonLocalizationsDelegate();

  @override
  Future<CommonLocalizations> load(Locale locale) {
    return SynchronousFuture<CommonLocalizations>(lookupCommonLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_CommonLocalizationsDelegate old) => false;
}

CommonLocalizations lookupCommonLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return CommonLocalizationsDe();
    case 'en':
      return CommonLocalizationsEn();
  }

  throw FlutterError(
    'CommonLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
