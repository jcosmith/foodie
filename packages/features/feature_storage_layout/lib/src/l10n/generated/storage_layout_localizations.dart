import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'storage_layout_localizations_de.dart';
import 'storage_layout_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of StorageLayoutLocalizations
/// returned by `StorageLayoutLocalizations.of(context)`.
///
/// Applications need to include `StorageLayoutLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/storage_layout_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: StorageLayoutLocalizations.localizationsDelegates,
///   supportedLocales: StorageLayoutLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the StorageLayoutLocalizations.supportedLocales
/// property.
abstract class StorageLayoutLocalizations {
  StorageLayoutLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static StorageLayoutLocalizations of(BuildContext context) {
    return Localizations.of<StorageLayoutLocalizations>(context, StorageLayoutLocalizations)!;
  }

  static const LocalizationsDelegate<StorageLayoutLocalizations> delegate =
      _StorageLayoutLocalizationsDelegate();

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
  /// **'Freezer layout'**
  String get configSectionTitle;

  /// No description provided for @layoutOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Freezer layout'**
  String get layoutOverviewTitle;

  /// No description provided for @defaultFreezerName.
  ///
  /// In en, this message translates to:
  /// **'{storageKind, select, chest{Chest freezer} fridgeFreezerCompartment{Fridge freezer} other{Freezer}}'**
  String defaultFreezerName(String storageKind);

  /// No description provided for @defaultCompartmentName.
  ///
  /// In en, this message translates to:
  /// **'{storageKind, select, chest{Basket {number}} fridgeFreezerCompartment{Compartment {number}} other{Drawer {number}}}'**
  String defaultCompartmentName(String storageKind, int number);

  /// No description provided for @removedName.
  ///
  /// In en, this message translates to:
  /// **'{name} (removed)'**
  String removedName(String name);

  /// No description provided for @storageKindDescription.
  ///
  /// In en, this message translates to:
  /// **'{storageKind, select, chest{chest freezer} fridgeFreezerCompartment{in the fridge} other{upright}}'**
  String storageKindDescription(String storageKind);

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

  /// No description provided for @shelfCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 compartment} other{{count} compartments}}'**
  String shelfCount(int count);

  /// No description provided for @freezerSummary.
  ///
  /// In en, this message translates to:
  /// **'{kind} · {compartments}'**
  String freezerSummary(String kind, String compartments);

  /// No description provided for @addFreezerButton.
  ///
  /// In en, this message translates to:
  /// **'Add freezer'**
  String get addFreezerButton;

  /// No description provided for @newFreezerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a freezer'**
  String get newFreezerTitle;

  /// No description provided for @templatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Which one is closest to yours? You can change everything later.'**
  String get templatePrompt;

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

  /// No description provided for @freezerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get freezerNameLabel;

  /// No description provided for @freezerNameHelper.
  ///
  /// In en, this message translates to:
  /// **'For example \"Kitchen\" or \"Cellar\". Leave empty to use \"{defaultName}\".'**
  String freezerNameHelper(String defaultName);

  /// No description provided for @addCompartmentButton.
  ///
  /// In en, this message translates to:
  /// **'{storageKind, select, chest{Add basket} fridgeFreezerCompartment{Add compartment} other{Add drawer}}'**
  String addCompartmentButton(String storageKind);

  /// No description provided for @compartmentItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Empty} =1{1 item} other{{count} items}}'**
  String compartmentItemCount(int count);

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @removeCompartment.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeCompartment;

  /// No description provided for @changeColor.
  ///
  /// In en, this message translates to:
  /// **'Change colour'**
  String get changeColor;

  /// No description provided for @compartmentNameTaken.
  ///
  /// In en, this message translates to:
  /// **'Another drawer already has this name.'**
  String get compartmentNameTaken;

  /// No description provided for @freezerNameTaken.
  ///
  /// In en, this message translates to:
  /// **'Another freezer already has this name.'**
  String get freezerNameTaken;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 30 characters.'**
  String get nameTooLong;

  /// No description provided for @removeCompartmentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeCompartmentDialogTitle(String name);

  /// No description provided for @removeCompartmentDialogText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{It holds 1 item. Where should it go?} other{It holds {count} items. Where should they go?}}'**
  String removeCompartmentDialogText(int count);

  /// No description provided for @moveDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get moveDestinationLabel;

  /// No description provided for @moveAndRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Move and remove'**
  String get moveAndRemoveButton;

  /// No description provided for @removedCompartmentsNote.
  ///
  /// In en, this message translates to:
  /// **'Removed (kept for your statistics): {names}'**
  String removedCompartmentsNote(String names);

  /// No description provided for @lastCompartmentHint.
  ///
  /// In en, this message translates to:
  /// **'A freezer needs at least one drawer.'**
  String get lastCompartmentHint;

  /// No description provided for @layoutHint.
  ///
  /// In en, this message translates to:
  /// **'Untouched names follow the app language. Names you type stay as you wrote them.'**
  String get layoutHint;

  /// No description provided for @renameFreezerAction.
  ///
  /// In en, this message translates to:
  /// **'Rename freezer'**
  String get renameFreezerAction;

  /// No description provided for @renameFreezerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename freezer'**
  String get renameFreezerDialogTitle;

  /// No description provided for @removeFreezerAction.
  ///
  /// In en, this message translates to:
  /// **'Remove freezer'**
  String get removeFreezerAction;

  /// No description provided for @removeFreezerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeFreezerDialogTitle(String name);

  /// No description provided for @removeFreezerDialogText.
  ///
  /// In en, this message translates to:
  /// **'It disappears from the app. Its drawers are kept for your statistics.'**
  String get removeFreezerDialogText;

  /// No description provided for @freezerNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Take out or move the 1 item in this freezer first.} other{Take out or move the {count} items in this freezer first.}}'**
  String freezerNotEmpty(int count);

  /// No description provided for @lastFreezerCannotBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'You need at least one freezer.'**
  String get lastFreezerCannotBeRemoved;

  /// No description provided for @freezerNotFound.
  ///
  /// In en, this message translates to:
  /// **'This freezer was removed.'**
  String get freezerNotFound;

  /// No description provided for @noFreezerTitle.
  ///
  /// In en, this message translates to:
  /// **'No freezer yet'**
  String get noFreezerTitle;

  /// No description provided for @noFreezerMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your freezer and its drawers, then start filling it.'**
  String get noFreezerMessage;

  /// No description provided for @genericFailure.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get genericFailure;
}

class _StorageLayoutLocalizationsDelegate
    extends LocalizationsDelegate<StorageLayoutLocalizations> {
  const _StorageLayoutLocalizationsDelegate();

  @override
  Future<StorageLayoutLocalizations> load(Locale locale) {
    return SynchronousFuture<StorageLayoutLocalizations>(lookupStorageLayoutLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_StorageLayoutLocalizationsDelegate old) => false;
}

StorageLayoutLocalizations lookupStorageLayoutLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return StorageLayoutLocalizationsDe();
    case 'en':
      return StorageLayoutLocalizationsEn();
  }

  throw FlutterError(
    'StorageLayoutLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
