import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'onboarding_localizations_de.dart';
import 'onboarding_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of OnboardingLocalizations
/// returned by `OnboardingLocalizations.of(context)`.
///
/// Applications need to include `OnboardingLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/onboarding_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: OnboardingLocalizations.localizationsDelegates,
///   supportedLocales: OnboardingLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the OnboardingLocalizations.supportedLocales
/// property.
abstract class OnboardingLocalizations {
  OnboardingLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static OnboardingLocalizations of(BuildContext context) {
    return Localizations.of<OnboardingLocalizations>(context, OnboardingLocalizations)!;
  }

  static const LocalizationsDelegate<OnboardingLocalizations> delegate =
      _OnboardingLocalizationsDelegate();

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

  /// No description provided for @stepOfSteps.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {stepCount}'**
  String stepOfSteps(int step, int stepCount);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep track of what is in your freezer, fridge and pantry, use things before they go off, and know what to buy.'**
  String get welcomeMessage;

  /// No description provided for @chooseLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Which language should the app use?'**
  String get chooseLanguagePrompt;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @storagePlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your freezer'**
  String get storagePlaceTitle;

  /// No description provided for @storagePlacePrompt.
  ///
  /// In en, this message translates to:
  /// **'Which one is closest to yours? You can rename, add and remove compartments later in Options.'**
  String get storagePlacePrompt;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data stays here'**
  String get privacyTitle;

  /// No description provided for @privacyMessage.
  ///
  /// In en, this message translates to:
  /// **'The app has no internet access and no account. Everything you enter stays on this phone, encrypted.'**
  String get privacyMessage;

  /// No description provided for @backupHint.
  ///
  /// In en, this message translates to:
  /// **'Because nothing is stored online, save a backup now and then. The app will remind you.'**
  String get backupHint;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so the app can tell you once a day what should be used soon. Item names stay hidden on the lock screen.'**
  String get remindersMessage;

  /// No description provided for @allowNotificationsButton.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotificationsButton;

  /// No description provided for @notNowButton.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNowButton;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;
}

class _OnboardingLocalizationsDelegate extends LocalizationsDelegate<OnboardingLocalizations> {
  const _OnboardingLocalizationsDelegate();

  @override
  Future<OnboardingLocalizations> load(Locale locale) {
    return SynchronousFuture<OnboardingLocalizations>(lookupOnboardingLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_OnboardingLocalizationsDelegate old) => false;
}

OnboardingLocalizations lookupOnboardingLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return OnboardingLocalizationsDe();
    case 'en':
      return OnboardingLocalizationsEn();
  }

  throw FlutterError(
    'OnboardingLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
