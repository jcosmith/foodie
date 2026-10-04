import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'application_shell_localizations_de.dart';
import 'application_shell_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ApplicationShellLocalizations
/// returned by `ApplicationShellLocalizations.of(context)`.
///
/// Applications need to include `ApplicationShellLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/application_shell_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ApplicationShellLocalizations.localizationsDelegates,
///   supportedLocales: ApplicationShellLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ApplicationShellLocalizations.supportedLocales
/// property.
abstract class ApplicationShellLocalizations {
  ApplicationShellLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ApplicationShellLocalizations of(BuildContext context) {
    return Localizations.of<ApplicationShellLocalizations>(context, ApplicationShellLocalizations)!;
  }

  static const LocalizationsDelegate<ApplicationShellLocalizations> delegate =
      _ApplicationShellLocalizationsDelegate();

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

  /// No description provided for @applicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Foodie'**
  String get applicationTitle;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get navigationLists;

  /// No description provided for @navigationMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navigationMore;

  /// No description provided for @listsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get listsTitle;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @privacyPromise.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves this phone.'**
  String get privacyPromise;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeDashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your household at a glance'**
  String get homeDashboardEmptyTitle;

  /// No description provided for @homeDashboardEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'What to use first and what is running low will appear here.'**
  String get homeDashboardEmptyMessage;

  /// No description provided for @quickActionsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickActionsMenuTitle;

  /// No description provided for @startupLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening Foodie'**
  String get startupLoadingLabel;

  /// No description provided for @startupFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'The app could not start'**
  String get startupFailureTitle;

  /// No description provided for @startupFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while opening your data. Your data has not been changed.'**
  String get startupFailureMessage;

  /// No description provided for @startupKeyLostTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data cannot be unlocked'**
  String get startupKeyLostTitle;

  /// No description provided for @startupKeyLostMessage.
  ///
  /// In en, this message translates to:
  /// **'The key that protects your Foodie data on this phone is gone, for example after the phone\'s secure storage was reset. Restoring a backup will be possible from here.'**
  String get startupKeyLostMessage;

  /// No description provided for @notificationChannelStorageRemindersName.
  ///
  /// In en, this message translates to:
  /// **'Storage reminders'**
  String get notificationChannelStorageRemindersName;

  /// No description provided for @notificationChannelStorageRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'A daily summary of items to use soon'**
  String get notificationChannelStorageRemindersDescription;

  /// No description provided for @notificationChannelBackupRemindersName.
  ///
  /// In en, this message translates to:
  /// **'Backup reminders'**
  String get notificationChannelBackupRemindersName;

  /// No description provided for @notificationChannelBackupRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'An occasional reminder to save a backup of your data'**
  String get notificationChannelBackupRemindersDescription;
}

class _ApplicationShellLocalizationsDelegate
    extends LocalizationsDelegate<ApplicationShellLocalizations> {
  const _ApplicationShellLocalizationsDelegate();

  @override
  Future<ApplicationShellLocalizations> load(Locale locale) {
    return SynchronousFuture<ApplicationShellLocalizations>(
      lookupApplicationShellLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ApplicationShellLocalizationsDelegate old) => false;
}

ApplicationShellLocalizations lookupApplicationShellLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return ApplicationShellLocalizationsDe();
    case 'en':
      return ApplicationShellLocalizationsEn();
  }

  throw FlutterError(
    'ApplicationShellLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
