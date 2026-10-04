import 'package:drift/drift.dart';

import '../../converters/calendar_date_converter.dart';
import '../inventory/inventory_tables.dart';
import '../product_catalog/product_catalog_tables.dart';

/// Scanned receipts, owned by feature_receipt_scanning (architecture
/// document, section 10.10). Kept until the user deletes them.
@DataClassName('ReceiptRow')
@TableIndex(name: 'receipts_by_creation', columns: {#createdAt})
class Receipts extends Table {
  TextColumn get receiptIdentifier => text()();

  /// As printed at the top of the receipt; `null` when none was found.
  TextColumn get storeName => text().nullable()();

  TextColumn get purchasedOn => text().map(const CalendarDateTextConverter()).nullable()();

  IntColumn get totalInCents => integer().nullable()();

  IntColumn get pageCount => integer()();

  /// Every recognised row, top to bottom, with card and loyalty numbers
  /// masked.
  TextColumn get recognizedText => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {receiptIdentifier};
}

/// The photographed pages of a receipt.
@DataClassName('ReceiptPageRow')
class ReceiptPages extends Table {
  TextColumn get receiptIdentifier => text().references(Receipts, #receiptIdentifier)();

  /// From 1.
  IntColumn get pageNumber => integer()();

  /// The encrypted page image (decision D11), or `null` once retention has
  /// deleted it or when none was kept.
  TextColumn get pictureReference => text().nullable()();

  /// The page's text exactly as recognition returned it, for reference.
  TextColumn get rawRecognizedText => text()();

  @override
  Set<Column<Object>> get primaryKey => {receiptIdentifier, pageNumber};
}

/// The priced rows of a receipt, each linked to the batch it created.
@DataClassName('ReceiptLineRow')
@TableIndex(name: 'receipt_lines_by_receipt', columns: {#receiptIdentifier, #position})
class ReceiptLines extends Table {
  TextColumn get receiptLineIdentifier => text()();

  TextColumn get receiptIdentifier => text().references(Receipts, #receiptIdentifier)();

  /// Order on the receipt, from 0.
  IntColumn get position => integer()();

  /// `item`, `discount` or `deposit`.
  TextColumn get kind => text()();

  TextColumn get recognizedText => text()();

  /// What the user corrected a misread line to; indexed and learned instead.
  TextColumn get correctedText => text().nullable()();

  IntColumn get quantity => integer()();

  IntColumn get unitPriceInCents => integer().nullable()();

  /// Negative for discounts.
  IntColumn get lineTotalInCents => integer()();

  IntColumn get weightInGrams => integer().nullable()();

  /// `matched`, `suggested`, `unrecognised` or `ignored`.
  TextColumn get status => text()();

  TextColumn get productIdentifier => text().references(Products, #productIdentifier).nullable()();

  /// The batch this line added; `null` while the line is open or ignored.
  TextColumn get stockBatchIdentifier =>
      text().references(StockBatches, #stockBatchIdentifier).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {receiptLineIdentifier};
}

/// What a store prints for a product, learned from confirmed and corrected
/// lines; without a product, the line is ignored at that store.
@DataClassName('ReceiptTextMappingRow')
class ReceiptTextMappings extends Table {
  /// Both normalised: lower case, accents folded, punctuation as spaces.
  TextColumn get storeName => text()();

  TextColumn get lineText => text()();

  TextColumn get productIdentifier => text().references(Products, #productIdentifier).nullable()();

  DateTimeColumn get learnedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {storeName, lineText};
}
