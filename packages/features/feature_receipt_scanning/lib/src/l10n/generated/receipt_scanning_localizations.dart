import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'receipt_scanning_localizations_de.dart';
import 'receipt_scanning_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ReceiptScanningLocalizations
/// returned by `ReceiptScanningLocalizations.of(context)`.
///
/// Applications need to include `ReceiptScanningLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/receipt_scanning_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ReceiptScanningLocalizations.localizationsDelegates,
///   supportedLocales: ReceiptScanningLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ReceiptScanningLocalizations.supportedLocales
/// property.
abstract class ReceiptScanningLocalizations {
  ReceiptScanningLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ReceiptScanningLocalizations of(BuildContext context) {
    return Localizations.of<ReceiptScanningLocalizations>(context, ReceiptScanningLocalizations)!;
  }

  static const LocalizationsDelegate<ReceiptScanningLocalizations> delegate =
      _ReceiptScanningLocalizationsDelegate();

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
  /// **'Receipt scanning'**
  String get optionalFeatureTitle;

  /// No description provided for @optionalFeatureDetail.
  ///
  /// In en, this message translates to:
  /// **'Read receipts on this phone only'**
  String get optionalFeatureDetail;

  /// No description provided for @quickActionScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get quickActionScanReceipt;

  /// No description provided for @segmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get segmentTitle;

  /// No description provided for @segmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receipts are kept on this phone, encrypted'**
  String get segmentSubtitle;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanTitle;

  /// No description provided for @scanPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Read on this phone. Nothing is sent anywhere.'**
  String get scanPrivacy;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Lay the receipt flat in good light. Take a long receipt as several photos, top to bottom.'**
  String get scanHint;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get pickFromGallery;

  /// No description provided for @pageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pageCount(int count);

  /// No description provided for @readReceipt.
  ///
  /// In en, this message translates to:
  /// **'Read receipt'**
  String get readReceipt;

  /// No description provided for @noTextOnPhoto.
  ///
  /// In en, this message translates to:
  /// **'No text found on this photo. Try again with more light.'**
  String get noTextOnPhoto;

  /// No description provided for @unreadablePhoto.
  ///
  /// In en, this message translates to:
  /// **'This photo could not be read.'**
  String get unreadablePhoto;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found on this receipt. It is kept and can be searched.'**
  String get noItemsFound;

  /// No description provided for @unknownStore.
  ///
  /// In en, this message translates to:
  /// **'Unknown store'**
  String get unknownStore;

  /// No description provided for @needsYou.
  ///
  /// In en, this message translates to:
  /// **'Needs you · {count}'**
  String needsYou(int count);

  /// No description provided for @recognisedSection.
  ///
  /// In en, this message translates to:
  /// **'Recognised · {count}'**
  String recognisedSection(int count);

  /// No description provided for @notAddedSection.
  ///
  /// In en, this message translates to:
  /// **'Not added · {count}'**
  String notAddedSection(int count);

  /// No description provided for @unknownLine.
  ///
  /// In en, this message translates to:
  /// **'We don\'t know this line yet.'**
  String get unknownLine;

  /// No description provided for @suggestedProduct.
  ///
  /// In en, this message translates to:
  /// **'{product}?'**
  String suggestedProduct(String product);

  /// No description provided for @confirmSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get confirmSuggestion;

  /// No description provided for @pickProduct.
  ///
  /// In en, this message translates to:
  /// **'Pick product'**
  String get pickProduct;

  /// No description provided for @ignoreLine.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignoreLine;

  /// No description provided for @ignoreAtStore.
  ///
  /// In en, this message translates to:
  /// **'Ignore at this store'**
  String get ignoreAtStore;

  /// No description provided for @setAmountAndPlace.
  ///
  /// In en, this message translates to:
  /// **'Set amount and place'**
  String get setAmountAndPlace;

  /// No description provided for @addItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 item} other{Add {count} items}}'**
  String addItems(int count);

  /// No description provided for @addedItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Receipt kept} =1{Added 1 item} other{Added {count} items}}'**
  String addedItems(int count);

  /// No description provided for @keepReceipt.
  ///
  /// In en, this message translates to:
  /// **'Keep receipt'**
  String get keepReceipt;

  /// No description provided for @editLineTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount and place'**
  String get editLineTitle;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount ({unit})'**
  String amountLabel(String unit);

  /// No description provided for @compartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get compartmentLabel;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero'**
  String get invalidAmount;

  /// No description provided for @openLines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing left open} =1{1 line still open} other{{count} lines still open}}'**
  String openLines(int count);

  /// No description provided for @openBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String openBadge(int count);

  /// No description provided for @lineAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get lineAdded;

  /// No description provided for @lineNotAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get lineNotAdded;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search receipts'**
  String get searchHint;

  /// No description provided for @noReceipts.
  ///
  /// In en, this message translates to:
  /// **'No receipts yet. Scan one from the add button.'**
  String get noReceipts;

  /// No description provided for @noSearchHits.
  ///
  /// In en, this message translates to:
  /// **'No receipt mentions this.'**
  String get noSearchHits;

  /// No description provided for @deleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Delete receipt'**
  String get deleteReceipt;

  /// No description provided for @deleteReceiptQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this receipt? What it added stays in storage.'**
  String get deleteReceiptQuestion;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @receiptDeleted.
  ///
  /// In en, this message translates to:
  /// **'Receipt deleted'**
  String get receiptDeleted;

  /// No description provided for @receiptGone.
  ///
  /// In en, this message translates to:
  /// **'This receipt was deleted.'**
  String get receiptGone;

  /// No description provided for @lineWithPrice.
  ///
  /// In en, this message translates to:
  /// **'{text} · {price}'**
  String lineWithPrice(String text, String price);

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total {amount}'**
  String totalAmount(String amount);

  /// No description provided for @pageImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageImageLabel(int number);

  /// No description provided for @lineNotOpen.
  ///
  /// In en, this message translates to:
  /// **'This line was already resolved.'**
  String get lineNotOpen;

  /// No description provided for @photoRetentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep receipt photos'**
  String get photoRetentionLabel;

  /// No description provided for @photoRetentionExplanation.
  ///
  /// In en, this message translates to:
  /// **'The text of every receipt stays searchable; older photos are deleted to save space.'**
  String get photoRetentionExplanation;

  /// No description provided for @photoRetentionForever.
  ///
  /// In en, this message translates to:
  /// **'Until I delete the receipt'**
  String get photoRetentionForever;

  /// No description provided for @photoRetentionMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String photoRetentionMonths(int months);

  /// No description provided for @correctText.
  ///
  /// In en, this message translates to:
  /// **'Correct text'**
  String get correctText;

  /// No description provided for @correctTextHint.
  ///
  /// In en, this message translates to:
  /// **'As printed on the receipt'**
  String get correctTextHint;

  /// No description provided for @recognisedAs.
  ///
  /// In en, this message translates to:
  /// **'Recognised as: {text}'**
  String recognisedAs(String text);

  /// No description provided for @filterAllStores.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get filterAllStores;

  /// No description provided for @filterAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get filterAnyTime;

  /// No description provided for @filterLastMonths.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{Last month} other{Last {months} months}}'**
  String filterLastMonths(int months);

  /// No description provided for @filterAnyAmount.
  ///
  /// In en, this message translates to:
  /// **'Any amount'**
  String get filterAnyAmount;

  /// No description provided for @filterUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount}'**
  String filterUpTo(String amount);

  /// No description provided for @filterOver.
  ///
  /// In en, this message translates to:
  /// **'Over {amount}'**
  String filterOver(String amount);

  /// No description provided for @noFilteredReceipts.
  ///
  /// In en, this message translates to:
  /// **'No receipt matches these filters.'**
  String get noFilteredReceipts;
}

class _ReceiptScanningLocalizationsDelegate
    extends LocalizationsDelegate<ReceiptScanningLocalizations> {
  const _ReceiptScanningLocalizationsDelegate();

  @override
  Future<ReceiptScanningLocalizations> load(Locale locale) {
    return SynchronousFuture<ReceiptScanningLocalizations>(
      lookupReceiptScanningLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ReceiptScanningLocalizationsDelegate old) => false;
}

ReceiptScanningLocalizations lookupReceiptScanningLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return ReceiptScanningLocalizationsDe();
    case 'en':
      return ReceiptScanningLocalizationsEn();
  }

  throw FlutterError(
    'ReceiptScanningLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
