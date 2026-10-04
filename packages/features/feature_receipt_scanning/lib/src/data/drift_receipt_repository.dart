import 'package:core_database/core_database.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';

import '../domain/receipt.dart';
import '../domain/receipt_line_matcher.dart';
import '../domain/receipt_parser.dart';
import '../domain/receipt_repository.dart';
import '../domain/receipt_text.dart';

final class DriftReceiptRepository implements ReceiptRepository {
  DriftReceiptRepository({
    required ReceiptScanningDao receiptScanningDao,
    required TransactionRunner transactionRunner,
  }) : _dao = receiptScanningDao,
       _transactionRunner = transactionRunner;

  final ReceiptScanningDao _dao;
  final TransactionRunner _transactionRunner;

  @override
  Stream<List<ReceiptSummary>> watchReceipts() => _dao.watchReceiptsWithOpenLineCounts().map(
    (rows) => [for (final (row, openLineCount) in rows) _summaryFromRow(row, openLineCount)],
  );

  @override
  Future<Receipt?> readReceipt(ReceiptIdentifier receiptIdentifier) async {
    final row = await _dao.readReceipt(receiptIdentifier.value);
    if (row == null) return null;
    final lines = (await _dao.readLinesOfReceipt(row.receiptIdentifier)).map(_lineFromRow).toList();
    final pages = await _dao.readPagesOfReceipt(row.receiptIdentifier);
    return Receipt(
      summary: _summaryFromRow(row, lines.where((line) => line.isOpen).length),
      text: row.recognizedText,
      pages: [
        for (final page in pages)
          ReceiptPage(
            pageNumber: page.pageNumber,
            pictureReference: page.pictureReference,
            rawRecognizedText: page.rawRecognizedText,
          ),
      ],
      lines: List.unmodifiable(lines),
    );
  }

  @override
  Future<ReceiptLine?> readLine(ReceiptLineIdentifier receiptLineIdentifier) async {
    final row = await _dao.readLine(receiptLineIdentifier.value);
    return row == null ? null : _lineFromRow(row);
  }

  @override
  Future<void> insertReceipt(
    Receipt receipt, {
    required Map<ReceiptLineIdentifier, String> lineSearchTexts,
  }) => _transactionRunner.runInTransaction(() async {
    final receiptIdentifier = receipt.identifier.value;
    await _dao.insertReceipt(
      ReceiptRow(
        receiptIdentifier: receiptIdentifier,
        storeName: receipt.storeName,
        purchasedOn: receipt.purchasedOn,
        totalInCents: receipt.totalInCents,
        pageCount: receipt.summary.pageCount,
        recognizedText: receipt.text,
        createdAt: receipt.summary.createdAt,
      ),
    );
    for (final page in receipt.pages) {
      await _dao.insertPage(
        ReceiptPageRow(
          receiptIdentifier: receiptIdentifier,
          pageNumber: page.pageNumber,
          pictureReference: page.pictureReference,
          rawRecognizedText: page.rawRecognizedText,
        ),
      );
    }
    for (final line in receipt.lines) {
      await _dao.insertLine(_rowFromLine(line));
    }
    await _dao.indexText(
      receiptIdentifier: receiptIdentifier,
      receiptLineIdentifier: null,
      body: ReceiptText.normalize('${receipt.storeName ?? ''}\n${receipt.text}'),
    );
    for (final MapEntry(key: lineIdentifier, value: searchText) in lineSearchTexts.entries) {
      await _dao.indexText(
        receiptIdentifier: receiptIdentifier,
        receiptLineIdentifier: lineIdentifier.value,
        body: ReceiptText.normalize(searchText),
      );
    }
  });

  @override
  Future<void> replaceLine(ReceiptLine line, {required String searchText}) =>
      _transactionRunner.runInTransaction(() async {
        await _dao.replaceLine(_rowFromLine(line));
        await _dao.reindexLine(
          receiptIdentifier: line.receiptIdentifier.value,
          receiptLineIdentifier: line.identifier.value,
          body: ReceiptText.normalize(searchText),
        );
      });

  @override
  Future<void> deleteReceipt(ReceiptIdentifier receiptIdentifier) =>
      _transactionRunner.runInTransaction(() => _dao.deleteReceipt(receiptIdentifier.value));

  @override
  Future<Set<String>> readPictureReferences() => _dao.readPictureReferences();

  @override
  Future<List<String>> forgetPicturesCreatedBefore(DateTime instant) =>
      _transactionRunner.runInTransaction(() async {
        final pages = await _dao.readPagesWithPicturesCreatedBefore(instant);
        for (final page in pages) {
          await _dao.clearPictureReference(page.receiptIdentifier, page.pageNumber);
        }
        return [for (final page in pages) page.pictureReference!];
      });

  @override
  Future<List<ReceiptSearchHit>> search(List<String> tokens) async {
    final words = [
      for (final token in tokens)
        for (final word in ReceiptText.normalize(token).split(' '))
          if (word.isNotEmpty) word,
    ];
    if (words.isEmpty) return const [];
    // Each word as a quoted prefix, so nothing the user types is read as
    // FTS5 syntax.
    final rows = await _dao.search(words.map((word) => '"$word"*').join(' '));
    // One hit per receipt: the best matching line, else the receipt itself.
    final hitLineOfReceipt = <String, String?>{};
    for (final row in rows) {
      final known = hitLineOfReceipt.containsKey(row.receiptIdentifier);
      if (!known ||
          (hitLineOfReceipt[row.receiptIdentifier] == null && row.receiptLineIdentifier != null)) {
        hitLineOfReceipt[row.receiptIdentifier] = row.receiptLineIdentifier;
      }
    }
    if (hitLineOfReceipt.isEmpty) return const [];
    final receipts = {
      for (final row in await _dao.readReceiptsWithIdentifiers(hitLineOfReceipt.keys))
        row.receiptIdentifier: row,
    };
    final lines = {
      for (final row in await _dao.readLinesWithIdentifiers(hitLineOfReceipt.values.nonNulls))
        row.receiptLineIdentifier: _lineFromRow(row),
    };
    final openCounts = await _dao.readOpenLineCounts(receipts.keys);
    return [
      for (final MapEntry(key: receiptIdentifier, value: lineIdentifier)
          in hitLineOfReceipt.entries)
        if (receipts[receiptIdentifier] case final receipt?)
          ReceiptSearchHit(
            receipt: _summaryFromRow(receipt, openCounts[receiptIdentifier] ?? 0),
            matchingLine: lines[lineIdentifier],
          ),
    ];
  }

  @override
  Future<List<ReceiptTextMapping>> readMappingsOfStore(String normalizedStoreName) async => [
    for (final row in await _dao.readMappingsOfStore(normalizedStoreName))
      ReceiptTextMapping(
        storeName: row.storeName,
        lineText: row.lineText,
        productIdentifier: switch (row.productIdentifier) {
          final identifier? => ProductIdentifier(identifier),
          null => null,
        },
        learnedAt: row.learnedAt.toUtc(),
      ),
  ];

  @override
  Future<void> saveMapping(ReceiptTextMapping mapping) => _dao.saveMapping(
    ReceiptTextMappingRow(
      storeName: mapping.storeName,
      lineText: mapping.lineText,
      productIdentifier: mapping.productIdentifier?.value,
      learnedAt: mapping.learnedAt ?? (throw ArgumentError('A learned mapping needs learnedAt')),
    ),
  );

  static ReceiptSummary _summaryFromRow(ReceiptRow row, int openLineCount) => ReceiptSummary(
    identifier: ReceiptIdentifier(row.receiptIdentifier),
    storeName: row.storeName,
    purchasedOn: row.purchasedOn,
    totalInCents: row.totalInCents,
    pageCount: row.pageCount,
    createdAt: row.createdAt.toUtc(),
    openLineCount: openLineCount,
  );

  static ReceiptLine _lineFromRow(ReceiptLineRow row) => ReceiptLine(
    identifier: ReceiptLineIdentifier(row.receiptLineIdentifier),
    receiptIdentifier: ReceiptIdentifier(row.receiptIdentifier),
    position: row.position,
    kind: ReceiptLineKind.values.byName(row.kind),
    recognizedText: row.recognizedText,
    correctedText: row.correctedText,
    quantity: row.quantity,
    unitPriceInCents: row.unitPriceInCents,
    lineTotalInCents: row.lineTotalInCents,
    weightInGrams: row.weightInGrams,
    status: ReceiptLineStatus.values.byName(row.status),
    productIdentifier: switch (row.productIdentifier) {
      final identifier? => ProductIdentifier(identifier),
      null => null,
    },
    stockBatchIdentifier: switch (row.stockBatchIdentifier) {
      final identifier? => StockBatchIdentifier(identifier),
      null => null,
    },
  );

  static ReceiptLineRow _rowFromLine(ReceiptLine line) => ReceiptLineRow(
    receiptLineIdentifier: line.identifier.value,
    receiptIdentifier: line.receiptIdentifier.value,
    position: line.position,
    kind: line.kind.name,
    recognizedText: line.recognizedText,
    correctedText: line.correctedText,
    quantity: line.quantity,
    unitPriceInCents: line.unitPriceInCents,
    lineTotalInCents: line.lineTotalInCents,
    weightInGrams: line.weightInGrams,
    status: line.status.name,
    productIdentifier: line.productIdentifier?.value,
    stockBatchIdentifier: line.stockBatchIdentifier?.value,
  );
}
