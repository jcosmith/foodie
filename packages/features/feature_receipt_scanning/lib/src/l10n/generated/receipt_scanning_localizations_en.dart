// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'receipt_scanning_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ReceiptScanningLocalizationsEn extends ReceiptScanningLocalizations {
  ReceiptScanningLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get optionalFeatureTitle => 'Receipt scanning';

  @override
  String get optionalFeatureDetail => 'Read receipts on this phone only';

  @override
  String get quickActionScanReceipt => 'Scan receipt';

  @override
  String get segmentTitle => 'Receipts';

  @override
  String get segmentSubtitle => 'Receipts are kept on this phone, encrypted';

  @override
  String get scanTitle => 'Scan receipt';

  @override
  String get scanPrivacy => 'Read on this phone. Nothing is sent anywhere.';

  @override
  String get scanHint =>
      'Lay the receipt flat in good light. Take a long receipt as several photos, top to bottom.';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get pickFromGallery => 'From gallery';

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get readReceipt => 'Read receipt';

  @override
  String get noTextOnPhoto => 'No text found on this photo. Try again with more light.';

  @override
  String get unreadablePhoto => 'This photo could not be read.';

  @override
  String get noItemsFound => 'No items found on this receipt. It is kept and can be searched.';

  @override
  String get unknownStore => 'Unknown store';

  @override
  String needsYou(int count) {
    return 'Needs you · $count';
  }

  @override
  String recognisedSection(int count) {
    return 'Recognised · $count';
  }

  @override
  String notAddedSection(int count) {
    return 'Not added · $count';
  }

  @override
  String get unknownLine => 'We don\'t know this line yet.';

  @override
  String suggestedProduct(String product) {
    return '$product?';
  }

  @override
  String get confirmSuggestion => 'Yes';

  @override
  String get pickProduct => 'Pick product';

  @override
  String get ignoreLine => 'Ignore';

  @override
  String get ignoreAtStore => 'Ignore at this store';

  @override
  String get setAmountAndPlace => 'Set amount and place';

  @override
  String addItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count items',
      one: 'Add 1 item',
    );
    return '$_temp0';
  }

  @override
  String addedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count items',
      one: 'Added 1 item',
      zero: 'Receipt kept',
    );
    return '$_temp0';
  }

  @override
  String get keepReceipt => 'Keep receipt';

  @override
  String get editLineTitle => 'Amount and place';

  @override
  String amountLabel(String unit) {
    return 'Amount ($unit)';
  }

  @override
  String get compartmentLabel => 'Place';

  @override
  String get invalidAmount => 'Enter an amount above zero';

  @override
  String openLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines still open',
      one: '1 line still open',
      zero: 'Nothing left open',
    );
    return '$_temp0';
  }

  @override
  String openBadge(int count) {
    return '$count open';
  }

  @override
  String get lineAdded => 'Added';

  @override
  String get lineNotAdded => 'Not added';

  @override
  String get searchHint => 'Search receipts';

  @override
  String get noReceipts => 'No receipts yet. Scan one from the add button.';

  @override
  String get noSearchHits => 'No receipt mentions this.';

  @override
  String get deleteReceipt => 'Delete receipt';

  @override
  String get deleteReceiptQuestion => 'Delete this receipt? What it added stays in storage.';

  @override
  String get delete => 'Delete';

  @override
  String get receiptDeleted => 'Receipt deleted';

  @override
  String get receiptGone => 'This receipt was deleted.';

  @override
  String lineWithPrice(String text, String price) {
    return '$text · $price';
  }

  @override
  String totalAmount(String amount) {
    return 'Total $amount';
  }

  @override
  String pageImageLabel(int number) {
    return 'Page $number';
  }

  @override
  String get lineNotOpen => 'This line was already resolved.';
}
