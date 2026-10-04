import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'data_portability_localizations_de.dart';
import 'data_portability_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of DataPortabilityLocalizations
/// returned by `DataPortabilityLocalizations.of(context)`.
///
/// Applications need to include `DataPortabilityLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/data_portability_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: DataPortabilityLocalizations.localizationsDelegates,
///   supportedLocales: DataPortabilityLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the DataPortabilityLocalizations.supportedLocales
/// property.
abstract class DataPortabilityLocalizations {
  DataPortabilityLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DataPortabilityLocalizations of(BuildContext context) {
    return Localizations.of<DataPortabilityLocalizations>(context, DataPortabilityLocalizations)!;
  }

  static const LocalizationsDelegate<DataPortabilityLocalizations> delegate =
      _DataPortabilityLocalizationsDelegate();

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
  /// **'Backup and export'**
  String get configSectionTitle;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup {date}'**
  String lastBackup(String date);

  /// No description provided for @noBackupYet.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get noBackupYet;

  /// No description provided for @backupExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your data exists only on this phone. A backup is a file, protected by a password if you like, that you keep somewhere safe, for example on a computer or in your own cloud storage.'**
  String get backupExplanation;

  /// No description provided for @saveBackupButton.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get saveBackupButton;

  /// No description provided for @restoreBackupButton.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackupButton;

  /// No description provided for @exportContentsButton.
  ///
  /// In en, this message translates to:
  /// **'Export contents as CSV'**
  String get exportContentsButton;

  /// No description provided for @exportHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'Export history as CSV'**
  String get exportHistoryButton;

  /// No description provided for @passwordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your backup'**
  String get passwordDialogTitle;

  /// No description provided for @protectWithPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Protect with a password'**
  String get protectWithPasswordLabel;

  /// No description provided for @unprotectedBackupWarning.
  ///
  /// In en, this message translates to:
  /// **'Anyone who gets this file can read your data.'**
  String get unprotectedBackupWarning;

  /// No description provided for @passwordDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a password of at least {count} characters. Nobody can open the backup without it, and it cannot be recovered.'**
  String passwordDialogMessage(int count);

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @repeatPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPasswordLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters.'**
  String passwordTooShort(int count);

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords are different.'**
  String get passwordsDoNotMatch;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @backupNotSaved.
  ///
  /// In en, this message translates to:
  /// **'The backup could not be saved.'**
  String get backupNotSaved;

  /// No description provided for @workingOnBackup.
  ///
  /// In en, this message translates to:
  /// **'Working on your backup…'**
  String get workingOnBackup;

  /// No description provided for @restorePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Open backup'**
  String get restorePasswordTitle;

  /// No description provided for @restorePasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the password you chose when you saved this backup.'**
  String get restorePasswordMessage;

  /// No description provided for @openButton.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openButton;

  /// No description provided for @backupNotReadable.
  ///
  /// In en, this message translates to:
  /// **'This file cannot be opened with that password. Check the password, and that the file is a backup of this app.'**
  String get backupNotReadable;

  /// No description provided for @notABackupOfThisApp.
  ///
  /// In en, this message translates to:
  /// **'This file is not a backup of this app.'**
  String get notABackupOfThisApp;

  /// No description provided for @backupNeedsNewerApp.
  ///
  /// In en, this message translates to:
  /// **'This backup was made with a newer version of the app ({version}). Please update the app first.'**
  String backupNeedsNewerApp(String version);

  /// No description provided for @confirmRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace everything?'**
  String get confirmRestoreTitle;

  /// No description provided for @confirmRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'The backup from {date} replaces everything that is in the app now. This cannot be undone.'**
  String confirmRestoreMessage(String date);

  /// No description provided for @restoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreButton;

  /// No description provided for @fileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved'**
  String get fileSaved;

  /// No description provided for @reminderCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a backup'**
  String get reminderCardTitle;

  /// No description provided for @reminderCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Foodie data is only on this phone. Save a backup so that a lost or broken phone does not take it with it.'**
  String get reminderCardMessage;

  /// No description provided for @csvColumnProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get csvColumnProduct;

  /// No description provided for @csvColumnCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get csvColumnCategory;

  /// No description provided for @csvColumnAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get csvColumnAmount;

  /// No description provided for @csvColumnUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get csvColumnUnit;

  /// No description provided for @csvColumnStoredOn.
  ///
  /// In en, this message translates to:
  /// **'Stored on'**
  String get csvColumnStoredOn;

  /// No description provided for @csvColumnDrawer.
  ///
  /// In en, this message translates to:
  /// **'Compartment'**
  String get csvColumnDrawer;

  /// No description provided for @csvColumnNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get csvColumnNote;

  /// No description provided for @csvColumnTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get csvColumnTime;

  /// No description provided for @csvColumnChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get csvColumnChange;

  /// No description provided for @csvColumnReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get csvColumnReason;

  /// No description provided for @movementAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get movementAdded;

  /// No description provided for @movementConsumed.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get movementConsumed;

  /// No description provided for @movementDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Thrown away'**
  String get movementDiscarded;

  /// No description provided for @movementMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get movementMoved;

  /// No description provided for @movementCorrected.
  ///
  /// In en, this message translates to:
  /// **'Corrected'**
  String get movementCorrected;

  /// No description provided for @reasonTooOld.
  ///
  /// In en, this message translates to:
  /// **'Stored too long'**
  String get reasonTooOld;

  /// No description provided for @reasonFreezerBurn.
  ///
  /// In en, this message translates to:
  /// **'Freezer burn'**
  String get reasonFreezerBurn;

  /// No description provided for @reasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Past its date'**
  String get reasonExpired;

  /// No description provided for @reasonSpoiled.
  ///
  /// In en, this message translates to:
  /// **'Gone off'**
  String get reasonSpoiled;

  /// No description provided for @reasonUnwanted.
  ///
  /// In en, this message translates to:
  /// **'Nobody wanted it'**
  String get reasonUnwanted;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @backupNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a backup'**
  String get backupNotificationTitle;

  /// No description provided for @backupNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Everything in this app exists only on this phone. Save a backup so that a lost phone does not take your lists with it.'**
  String get backupNotificationBody;

  /// No description provided for @includePicturesLabel.
  ///
  /// In en, this message translates to:
  /// **'Include photos'**
  String get includePicturesLabel;

  /// No description provided for @includePicturesHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo, about 300 KB. Leave it out for a smaller file.} other{{count} photos, about 300 KB each. Leave them out for a smaller file.}}'**
  String includePicturesHint(int count);

  /// No description provided for @restoreIncludesPictures.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{It contains no photos.} =1{It contains 1 photo.} other{It contains {count} photos.}}'**
  String restoreIncludesPictures(int count);
}

class _DataPortabilityLocalizationsDelegate
    extends LocalizationsDelegate<DataPortabilityLocalizations> {
  const _DataPortabilityLocalizationsDelegate();

  @override
  Future<DataPortabilityLocalizations> load(Locale locale) {
    return SynchronousFuture<DataPortabilityLocalizations>(
      lookupDataPortabilityLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_DataPortabilityLocalizationsDelegate old) => false;
}

DataPortabilityLocalizations lookupDataPortabilityLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return DataPortabilityLocalizationsDe();
    case 'en':
      return DataPortabilityLocalizationsEn();
  }

  throw FlutterError(
    'DataPortabilityLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
