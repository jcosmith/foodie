import 'receipt.dart';
import 'receipt_line_matcher.dart';

/// Stores receipts, their search index and learned receipt texts.
abstract interface class ReceiptRepository {
  Stream<List<ReceiptSummary>> watchReceipts();

  Future<Receipt?> readReceipt(ReceiptIdentifier receiptIdentifier);

  Future<ReceiptLine?> readLine(ReceiptLineIdentifier receiptLineIdentifier);

  /// Saves a new receipt with its pages and lines and indexes it.
  Future<void> insertReceipt(
    Receipt receipt, {
    required Map<ReceiptLineIdentifier, String> lineSearchTexts,
  });

  /// Saves a changed line and reindexes it with [searchText].
  Future<void> replaceLine(ReceiptLine line, {required String searchText});

  Future<void> deleteReceipt(ReceiptIdentifier receiptIdentifier);

  /// Every page image a receipt refers to.
  Future<Set<String>> readPictureReferences();

  /// Search hits for [tokens], each a normalised word matched as a prefix;
  /// all of them must occur in the same receipt row or line.
  Future<List<ReceiptSearchHit>> search(List<String> tokens);

  /// Everything learned for a store, by its normalised name.
  Future<List<ReceiptTextMapping>> readMappingsOfStore(String normalizedStoreName);

  Future<void> saveMapping(ReceiptTextMapping mapping);
}
