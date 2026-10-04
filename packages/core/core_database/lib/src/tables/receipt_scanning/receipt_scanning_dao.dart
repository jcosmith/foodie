import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'receipt_scanning_tables.dart';

part 'receipt_scanning_dao.g.dart';

/// A receipt as one search hit: the receipt, and the line that matched, if
/// it was a line rather than the store or the whole text.
typedef ReceiptSearchRow = ({String receiptIdentifier, String? receiptLineIdentifier});

/// Receipts, their pages and lines, learned receipt texts and the full-text
/// index (architecture document, section 10.10).
@DriftAccessor(
  tables: [Receipts, ReceiptPages, ReceiptLines, ReceiptTextMappings],
  include: {'receipt_search_index.drift'},
)
class ReceiptScanningDao extends DatabaseAccessor<ApplicationDatabase>
    with _$ReceiptScanningDaoMixin {
  ReceiptScanningDao(super.attachedDatabase);

  /// Items neither added nor ignored; mirrors `ReceiptLine.isOpen` of the
  /// receipt module.
  static const String _openLineCondition =
      "kind = 'item' AND status <> 'ignored' AND stock_batch_identifier IS NULL";

  /// Newest first, each with the number of its open lines; updates when a
  /// line is resolved, too.
  Stream<List<(ReceiptRow, int)>> watchReceiptsWithOpenLineCounts() =>
      customSelect(
        'SELECT receipts.*, (SELECT COUNT(*) FROM receipt_lines '
        'WHERE receipt_lines.receipt_identifier = receipts.receipt_identifier AND $_openLineCondition) '
        'AS open_line_count FROM receipts ORDER BY created_at DESC',
        readsFrom: {receipts, receiptLines},
      ).watch().map(
        (rows) => [
          for (final row in rows) (receipts.map(row.data), row.read<int>('open_line_count')),
        ],
      );

  Future<Map<String, int>> readOpenLineCounts(Iterable<String> receiptIdentifiers) async {
    final identifiers = receiptIdentifiers.toList();
    if (identifiers.isEmpty) return const {};
    final rows = await customSelect(
      'SELECT receipt_identifier, COUNT(*) AS open_line_count FROM receipt_lines '
      'WHERE receipt_identifier IN (${List.filled(identifiers.length, '?').join(', ')}) '
      'AND $_openLineCondition GROUP BY receipt_identifier',
      variables: [for (final identifier in identifiers) Variable.withString(identifier)],
      readsFrom: {receiptLines},
    ).get();
    return {
      for (final row in rows)
        row.read<String>('receipt_identifier'): row.read<int>('open_line_count'),
    };
  }

  Future<ReceiptRow?> readReceipt(String receiptIdentifier) => (select(
    receipts,
  )..where((receipt) => receipt.receiptIdentifier.equals(receiptIdentifier))).getSingleOrNull();

  Future<List<ReceiptRow>> readReceiptsWithIdentifiers(Iterable<String> receiptIdentifiers) =>
      (select(
        receipts,
      )..where((receipt) => receipt.receiptIdentifier.isIn(receiptIdentifiers))).get();

  Future<List<ReceiptLineRow>> readLinesOfReceipt(String receiptIdentifier) =>
      (select(receiptLines)
            ..where((line) => line.receiptIdentifier.equals(receiptIdentifier))
            ..orderBy([(line) => OrderingTerm.asc(line.position)]))
          .get();

  Future<List<ReceiptLineRow>> readLinesWithIdentifiers(Iterable<String> lineIdentifiers) =>
      (select(
        receiptLines,
      )..where((line) => line.receiptLineIdentifier.isIn(lineIdentifiers))).get();

  Future<ReceiptLineRow?> readLine(String receiptLineIdentifier) => (select(
    receiptLines,
  )..where((line) => line.receiptLineIdentifier.equals(receiptLineIdentifier))).getSingleOrNull();

  Future<List<ReceiptPageRow>> readPagesOfReceipt(String receiptIdentifier) =>
      (select(receiptPages)
            ..where((page) => page.receiptIdentifier.equals(receiptIdentifier))
            ..orderBy([(page) => OrderingTerm.asc(page.pageNumber)]))
          .get();

  /// Every page image still referred to, for the orphan sweep.
  Future<Set<String>> readPictureReferences() async {
    final query = selectOnly(receiptPages)
      ..addColumns([receiptPages.pictureReference])
      ..where(receiptPages.pictureReference.isNotNull());
    return {for (final row in await query.get()) row.read(receiptPages.pictureReference)!};
  }

  Future<void> insertReceipt(ReceiptRow receipt) => into(receipts).insert(receipt);

  Future<void> insertPage(ReceiptPageRow page) => into(receiptPages).insert(page);

  Future<void> insertLine(ReceiptLineRow line) => into(receiptLines).insert(line);

  Future<void> replaceLine(ReceiptLineRow line) => update(receiptLines).replace(line);

  /// Removes a receipt with its pages, lines and index rows. The batches its
  /// lines added stay in storage.
  Future<void> deleteReceipt(String receiptIdentifier) async {
    await (delete(
      receiptSearchIndex,
    )..where((row) => row.receiptIdentifier.equals(receiptIdentifier))).go();
    await (delete(
      receiptLines,
    )..where((line) => line.receiptIdentifier.equals(receiptIdentifier))).go();
    await (delete(
      receiptPages,
    )..where((page) => page.receiptIdentifier.equals(receiptIdentifier))).go();
    await (delete(
      receipts,
    )..where((receipt) => receipt.receiptIdentifier.equals(receiptIdentifier))).go();
  }

  Future<List<ReceiptTextMappingRow>> readMappingsOfStore(String storeName) =>
      (select(receiptTextMappings)..where((mapping) => mapping.storeName.equals(storeName))).get();

  Future<void> saveMapping(ReceiptTextMappingRow mapping) =>
      into(receiptTextMappings).insertOnConflictUpdate(mapping);

  /// Adds one row to the full-text index; [body] is already normalised.
  Future<void> indexText({
    required String receiptIdentifier,
    required String? receiptLineIdentifier,
    required String body,
  }) => into(receiptSearchIndex).insert(
    ReceiptSearchIndexCompanion.insert(
      receiptIdentifier: receiptIdentifier,
      // FTS5 columns cannot be NULL: an empty identifier marks the row of
      // the receipt itself.
      receiptLineIdentifier: receiptLineIdentifier ?? '',
      body: body,
    ),
  );

  /// Replaces the index row of one line, after it was corrected or resolved.
  Future<void> reindexLine({
    required String receiptIdentifier,
    required String receiptLineIdentifier,
    required String body,
  }) async {
    await (delete(
      receiptSearchIndex,
    )..where((row) => row.receiptLineIdentifier.equals(receiptLineIdentifier))).go();
    await indexText(
      receiptIdentifier: receiptIdentifier,
      receiptLineIdentifier: receiptLineIdentifier,
      body: body,
    );
  }

  /// Rows matching an FTS5 [matchExpression], best first.
  Future<List<ReceiptSearchRow>> search(String matchExpression) async {
    final rows = await customSelect(
      'SELECT receipt_identifier, receipt_line_identifier FROM receipt_search_index '
      'WHERE receipt_search_index MATCH ? ORDER BY rank',
      variables: [Variable.withString(matchExpression)],
      readsFrom: {receiptSearchIndex},
    ).get();
    return [
      for (final row in rows)
        (
          receiptIdentifier: row.read<String>('receipt_identifier'),
          receiptLineIdentifier: switch (row.read<String>('receipt_line_identifier')) {
            '' => null,
            final identifier => identifier,
          },
        ),
    ];
  }
}
