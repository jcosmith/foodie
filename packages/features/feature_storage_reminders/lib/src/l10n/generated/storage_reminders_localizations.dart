import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'storage_reminders_localizations_de.dart';
import 'storage_reminders_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of StorageRemindersLocalizations
/// returned by `StorageRemindersLocalizations.of(context)`.
///
/// Applications need to include `StorageRemindersLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/storage_reminders_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: StorageRemindersLocalizations.localizationsDelegates,
///   supportedLocales: StorageRemindersLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the StorageRemindersLocalizations.supportedLocales
/// property.
abstract class StorageRemindersLocalizations {
  StorageRemindersLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static StorageRemindersLocalizations of(BuildContext context) {
    return Localizations.of<StorageRemindersLocalizations>(context, StorageRemindersLocalizations)!;
  }

  static const LocalizationsDelegate<StorageRemindersLocalizations> delegate =
      _StorageRemindersLocalizationsDelegate();

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

  /// No description provided for @configSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get configSectionTitle;

  /// No description provided for @eatSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Eat soon'**
  String get eatSoonTitle;

  /// No description provided for @eatSoonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing urgent. Well done!'**
  String get eatSoonEmpty;

  /// No description provided for @eatSoonScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to eat soon'**
  String get eatSoonScreenEmptyTitle;

  /// No description provided for @eatSoonScreenEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything in your freezer keeps for a while yet.'**
  String get eatSoonScreenEmptyMessage;

  /// No description provided for @eatSoonScreenExplanation.
  ///
  /// In en, this message translates to:
  /// **'Food shows up here once 60 % of its storage time has passed. Tap an item to take some out.'**
  String get eatSoonScreenExplanation;

  /// No description provided for @digestTitle.
  ///
  /// In en, this message translates to:
  /// **'Eat soon'**
  String get digestTitle;

  /// No description provided for @digestBodyWithCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item in your freezer should be eaten soon.} other{{count} items in your freezer should be eaten soon.}}'**
  String digestBodyWithCount(int count);

  /// No description provided for @productNameSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get productNameSeparator;

  /// No description provided for @productNamesWithMore.
  ///
  /// In en, this message translates to:
  /// **'{names} and {count} more'**
  String productNamesWithMore(String names, int count);

  /// No description provided for @dailyDigestSwitch.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyDigestSwitch;

  /// No description provided for @dailyDigestDetail.
  ///
  /// In en, this message translates to:
  /// **'One notification on the days something should be eaten soon'**
  String get dailyDigestDetail;

  /// No description provided for @digestTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get digestTimeLabel;

  /// No description provided for @showNamesSwitch.
  ///
  /// In en, this message translates to:
  /// **'Show food names in notifications'**
  String get showNamesSwitch;

  /// No description provided for @showNamesDetail.
  ///
  /// In en, this message translates to:
  /// **'Names may then be readable on the lock screen.'**
  String get showNamesDetail;

  /// No description provided for @notificationsOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications are switched off for this app, so reminders cannot appear.'**
  String get notificationsOffMessage;

  /// No description provided for @allowNotificationsButton.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allowNotificationsButton;

  /// No description provided for @storageLimitsRow.
  ///
  /// In en, this message translates to:
  /// **'Storage limits'**
  String get storageLimitsRow;

  /// No description provided for @storageLimitsDetail.
  ///
  /// In en, this message translates to:
  /// **'How long each category keeps in the freezer'**
  String get storageLimitsDetail;

  /// No description provided for @storageLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage limits'**
  String get storageLimitsTitle;

  /// No description provided for @storageLimitsExplanation.
  ///
  /// In en, this message translates to:
  /// **'Food is marked “eat soon” once 85 % of its storage time has passed. A product can have its own time in the product editor.'**
  String get storageLimitsExplanation;

  /// No description provided for @storageMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String storageMonths(int count);

  /// No description provided for @storageMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep for at most, in months'**
  String get storageMonthsLabel;

  /// No description provided for @storageMonthsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 1 to {maximum}.'**
  String storageMonthsInvalid(int maximum);
}

class _StorageRemindersLocalizationsDelegate
    extends LocalizationsDelegate<StorageRemindersLocalizations> {
  const _StorageRemindersLocalizationsDelegate();

  @override
  Future<StorageRemindersLocalizations> load(Locale locale) {
    return SynchronousFuture<StorageRemindersLocalizations>(
      lookupStorageRemindersLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_StorageRemindersLocalizationsDelegate old) => false;
}

StorageRemindersLocalizations lookupStorageRemindersLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return StorageRemindersLocalizationsDe();
    case 'en':
      return StorageRemindersLocalizationsEn();
  }

  throw FlutterError(
    'StorageRemindersLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
