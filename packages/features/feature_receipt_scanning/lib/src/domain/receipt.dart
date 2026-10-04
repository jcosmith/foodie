import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

import 'receipt_line_matcher.dart';
import 'receipt_parser.dart';

typedef ReceiptIdentifier = TypedIdentifier<Receipt>;
typedef ReceiptLineIdentifier = TypedIdentifier<ReceiptLine>;

/// One priced row of an archived receipt.
@immutable
final class ReceiptLine {
  const ReceiptLine({
    required this.identifier,
    required this.receiptIdentifier,
    required this.position,
    required this.kind,
    required this.recognizedText,
    required this.quantity,
    required this.lineTotalInCents,
    required this.status,
    this.correctedText,
    this.unitPriceInCents,
    this.weightInGrams,
    this.productIdentifier,
    this.stockBatchIdentifier,
  });

  final ReceiptLineIdentifier identifier;
  final ReceiptIdentifier receiptIdentifier;
  final int position;
  final ReceiptLineKind kind;

  /// As recognised, kept for reference after a correction.
  final String recognizedText;

  /// What the user corrected a misread line to.
  final String? correctedText;
  final int quantity;
  final int? unitPriceInCents;
  final int lineTotalInCents;
  final int? weightInGrams;
  final ReceiptLineStatus status;
  final ProductIdentifier? productIdentifier;

  /// The batch this line added.
  final StockBatchIdentifier? stockBatchIdentifier;

  /// The text shown, indexed and learned.
  String get text => correctedText ?? recognizedText;

  /// The line as the parser saw it, for suggesting what to add later.
  ParsedReceiptLine get parsed => ParsedReceiptLine(
    position: position,
    kind: kind,
    text: text,
    lineTotalInCents: lineTotalInCents,
    quantity: quantity,
    unitPriceInCents: unitPriceInCents,
    weightInGrams: weightInGrams,
  );

  /// An item that was neither added nor ignored: flagged on the receipt until
  /// the user resolves it.
  bool get isOpen =>
      kind == ReceiptLineKind.item &&
      status != ReceiptLineStatus.ignored &&
      stockBatchIdentifier == null;

  ReceiptLine resolved({
    required ReceiptLineStatus status,
    ProductIdentifier? productIdentifier,
    StockBatchIdentifier? stockBatchIdentifier,
    String? correctedText,
  }) => ReceiptLine(
    identifier: identifier,
    receiptIdentifier: receiptIdentifier,
    position: position,
    kind: kind,
    recognizedText: recognizedText,
    correctedText: correctedText ?? this.correctedText,
    quantity: quantity,
    unitPriceInCents: unitPriceInCents,
    lineTotalInCents: lineTotalInCents,
    weightInGrams: weightInGrams,
    status: status,
    productIdentifier: productIdentifier,
    stockBatchIdentifier: stockBatchIdentifier,
  );
}

/// A receipt in the archive list.
@immutable
final class ReceiptSummary {
  const ReceiptSummary({
    required this.identifier,
    required this.pageCount,
    required this.createdAt,
    required this.openLineCount,
    this.storeName,
    this.purchasedOn,
    this.totalInCents,
  });

  final ReceiptIdentifier identifier;
  final String? storeName;
  final CalendarDate? purchasedOn;
  final int? totalInCents;
  final int pageCount;
  final DateTime createdAt;

  /// Items still waiting for the user to add or ignore them.
  final int openLineCount;
}

/// A page of an archived receipt.
@immutable
final class ReceiptPage {
  const ReceiptPage({
    required this.pageNumber,
    required this.rawRecognizedText,
    this.pictureReference,
  });

  final int pageNumber;
  final String? pictureReference;
  final String rawRecognizedText;
}

/// An archived receipt with its pages and lines.
@immutable
final class Receipt {
  const Receipt({
    required this.summary,
    required this.text,
    required this.pages,
    required this.lines,
  });

  final ReceiptSummary summary;

  /// Every row, with card and loyalty numbers masked.
  final String text;
  final List<ReceiptPage> pages;
  final List<ReceiptLine> lines;

  ReceiptIdentifier get identifier => summary.identifier;
  String? get storeName => summary.storeName;
  CalendarDate? get purchasedOn => summary.purchasedOn;
  int? get totalInCents => summary.totalInCents;

  List<ReceiptLine> get openLines => [
    for (final line in lines)
      if (line.isOpen) line,
  ];
}

/// One search result: the receipt, and the line that matched when it was a
/// line rather than the store name or the rest of the text.
@immutable
final class ReceiptSearchHit {
  const ReceiptSearchHit({required this.receipt, this.matchingLine});

  final ReceiptSummary receipt;
  final ReceiptLine? matchingLine;
}
