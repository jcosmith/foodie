import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:meta/meta.dart';

import '../domain/receipt_line_matcher.dart';
import '../domain/receipt_parser.dart';
import '../domain/receipt_rows.dart';
import '../domain/receipt_text.dart';

/// One photographed page as on-device text recognition read it.
@immutable
final class RecognizedReceiptPage {
  const RecognizedReceiptPage({required this.lines, this.pictureReference});

  final List<RecognizedTextLine> lines;

  /// The encrypted page image, once it is stored.
  final String? pictureReference;

  /// The page's text as recognised, kept for reference; card and loyalty
  /// numbers are masked here too, as nothing stored may keep them.
  String get rawText => [
    for (final row in ReceiptRows.fromLines(lines)) ReceiptText.maskPrivateNumbers(row.text),
  ].join('\n');
}

/// One priced row on the review list, with what the app suggests for it.
@immutable
final class ReceiptReviewLine {
  const ReceiptReviewLine({
    required this.parsed,
    required this.status,
    this.product,
    this.quantity,
    this.compartment,
    this.bestBeforeOn,
  });

  final ParsedReceiptLine parsed;
  final ReceiptLineStatus status;

  /// The matched or suggested product.
  final Product? product;
  final Quantity? quantity;
  final Compartment? compartment;

  /// Suggested from the shelf life where the place keeps best-before dates.
  final CalendarDate? bestBeforeOn;

  int get position => parsed.position;
  String get text => parsed.text;
  ReceiptLineKind get kind => parsed.kind;
  int get lineTotalInCents => parsed.lineTotalInCents;

  /// Ready to be added without typing anything.
  bool get canAddAsSuggested => product != null && quantity != null && compartment != null;

  /// The suggestion confirmed, or changed by the user.
  ReceiptReviewLine copyWith({
    ReceiptLineStatus? status,
    Quantity? quantity,
    Compartment? compartment,
  }) => ReceiptReviewLine(
    parsed: parsed,
    status: status ?? this.status,
    product: product,
    quantity: quantity ?? this.quantity,
    compartment: compartment ?? this.compartment,
    bestBeforeOn: bestBeforeOn,
  );
}

/// A scanned receipt before anything is added or archived.
@immutable
final class ReceiptReview {
  const ReceiptReview({
    required this.pages,
    required this.text,
    required this.lines,
    this.storeName,
    this.purchasedOn,
    this.totalInCents,
  });

  final List<RecognizedReceiptPage> pages;
  final String? storeName;
  final CalendarDate? purchasedOn;
  final int? totalInCents;

  /// Every row, with card and loyalty numbers masked.
  final String text;

  /// Unrecognised lines first, then suggested, matched and ignored ones,
  /// each in receipt order (architecture 10.10, step 5).
  final List<ReceiptReviewLine> lines;
}

/// What the user decided for one line.
sealed class ReceiptLineDecision {
  const ReceiptLineDecision({this.correctedText});

  /// The line as the user corrected a misreading; learned and indexed
  /// instead of the recognised text.
  final String? correctedText;
}

/// Put the line's purchase into storage.
final class AddReceiptLine extends ReceiptLineDecision {
  const AddReceiptLine({
    required this.productIdentifier,
    required this.compartmentIdentifier,
    required this.quantity,
    this.bestBeforeOn,
    super.correctedText,
  });

  /// Adds exactly what the review suggested for [line].
  factory AddReceiptLine.suggested(ReceiptReviewLine line) {
    if (!line.canAddAsSuggested) {
      throw ArgumentError.value(line.text, 'line', 'has no complete suggestion');
    }
    return AddReceiptLine(
      productIdentifier: line.product!.identifier,
      compartmentIdentifier: line.compartment!.identifier,
      quantity: line.quantity!,
      bestBeforeOn: line.bestBeforeOn,
    );
  }

  final ProductIdentifier productIdentifier;
  final CompartmentIdentifier compartmentIdentifier;
  final Quantity quantity;
  final CalendarDate? bestBeforeOn;
}

/// Not something to keep, such as a magazine; [remember] ignores the same
/// text at the same store from now on.
final class IgnoreReceiptLine extends ReceiptLineDecision {
  const IgnoreReceiptLine({this.remember = false, super.correctedText});

  final bool remember;
}
