import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'configuration_localizations_de.dart';
import 'configuration_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ConfigurationLocalizations
/// returned by `ConfigurationLocalizations.of(context)`.
///
/// Applications need to include `ConfigurationLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/configuration_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ConfigurationLocalizations.localizationsDelegates,
///   supportedLocales: ConfigurationLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ConfigurationLocalizations.supportedLocales
/// property.
abstract class ConfigurationLocalizations {
  ConfigurationLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ConfigurationLocalizations of(BuildContext context) {
    return Localizations.of<ConfigurationLocalizations>(context, ConfigurationLocalizations)!;
  }

  static const LocalizationsDelegate<ConfigurationLocalizations> delegate =
      _ConfigurationLocalizationsDelegate();

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

  /// No description provided for @screenTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get screenTitle;

  /// No description provided for @moreEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tabs, optional features, language, appearance, reminders, backup'**
  String get moreEntrySubtitle;

  /// No description provided for @tabsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get tabsSectionTitle;

  /// No description provided for @lastTabHint.
  ///
  /// In en, this message translates to:
  /// **'At least one tab stays on.'**
  String get lastTabHint;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// No description provided for @systemLanguageDetail.
  ///
  /// In en, this message translates to:
  /// **'Follows your phone: {languageName}'**
  String systemLanguageDetail(String languageName);

  /// No description provided for @appearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @textSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Text size follows your phone\'s settings.'**
  String get textSizeHint;

  /// No description provided for @optionalFeaturesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional features'**
  String get optionalFeaturesSectionTitle;

  /// No description provided for @aboutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'About and privacy'**
  String get aboutSectionTitle;

  /// No description provided for @privacyStatementTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves this phone'**
  String get privacyStatementTitle;

  /// No description provided for @privacyStatementMessage.
  ///
  /// In en, this message translates to:
  /// **'No account, no cloud, no tracking. The app has no internet access at all. Backups go only where you save them yourself.'**
  String get privacyStatementMessage;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @licencesButton.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get licencesButton;
}

class _ConfigurationLocalizationsDelegate
    extends LocalizationsDelegate<ConfigurationLocalizations> {
  const _ConfigurationLocalizationsDelegate();

  @override
  Future<ConfigurationLocalizations> load(Locale locale) {
    return SynchronousFuture<ConfigurationLocalizations>(lookupConfigurationLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ConfigurationLocalizationsDelegate old) => false;
}

ConfigurationLocalizations lookupConfigurationLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return ConfigurationLocalizationsDe();
    case 'en':
      return ConfigurationLocalizationsEn();
  }

  throw FlutterError(
    'ConfigurationLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
