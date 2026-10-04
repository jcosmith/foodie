import '../domain/receipt.dart';
import '../domain/receipt_repository.dart';
import '../domain/receipt_text.dart';

/// Reads the receipt archive.
final class ReceiptQueryService {
  const ReceiptQueryService(this._repository);

  final ReceiptRepository _repository;

  /// Newest first.
  Stream<List<ReceiptSummary>> watchReceipts() => _repository.watchReceipts();

  Future<Receipt?> readReceipt(ReceiptIdentifier receiptIdentifier) =>
      _repository.readReceipt(receiptIdentifier);

  /// Receipts whose store, text or lines contain every word of [query],
  /// each word also as the start of a longer one ("gard" finds "garden"),
  /// best first, one hit per receipt.
  Future<List<ReceiptSearchHit>> search(String query) {
    final words = ReceiptText.normalize(query).split(' ').where((word) => word.isNotEmpty).toList();
    return words.isEmpty ? Future.value(const []) : _repository.search(words);
  }
}
