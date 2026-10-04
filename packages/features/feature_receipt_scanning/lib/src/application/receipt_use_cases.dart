import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';

import '../domain/receipt.dart';
import '../domain/receipt_line_matcher.dart';
import '../domain/receipt_parser.dart';
import '../domain/receipt_quantity_policy.dart';
import '../domain/receipt_repository.dart';
import '../domain/receipt_rows.dart';
import '../domain/receipt_scanning_failure.dart';
import '../domain/receipt_text.dart';
import 'receipt_review.dart';

/// Reads, parses and matches the pages of one receipt (architecture 10.10,
/// steps 3 to 5). Nothing is stored yet.
final class PrepareReceiptReviewUseCase {
  const PrepareReceiptReviewUseCase({
    required ReceiptRepository repository,
    required ProductCatalogQueryService productCatalog,
    required InventoryQueryService inventory,
    required StorageLayoutQueryService storageLayout,
    required Clock clock,
    required Set<StorageDomainIdentifier> Function() readPausedDomains,
    required Set<StorageDomainIdentifier> Function() readDomainsWithBestBefore,
  }) : _repository = repository,
       _productCatalog = productCatalog,
       _inventory = inventory,
       _storageLayout = storageLayout,
       _clock = clock,
       _readPausedDomains = readPausedDomains,
       _readDomainsWithBestBefore = readDomainsWithBestBefore;

  final ReceiptRepository _repository;
  final ProductCatalogQueryService _productCatalog;
  final InventoryQueryService _inventory;
  final StorageLayoutQueryService _storageLayout;
  final Clock _clock;

  /// Switched-off domains, whose places are never suggested.
  final Set<StorageDomainIdentifier> Function() _readPausedDomains;

  /// Domains that keep best-before dates, such as the pantry.
  final Set<StorageDomainIdentifier> Function() _readDomainsWithBestBefore;

  static const List<ReceiptLineStatus> _reviewOrder = [
    ReceiptLineStatus.unrecognised,
    ReceiptLineStatus.suggested,
    ReceiptLineStatus.matched,
    ReceiptLineStatus.ignored,
  ];

  /// [names] gives products their names in the language the user reads.
  Future<ReceiptReview> execute({
    required List<RecognizedReceiptPage> pages,
    required ProductDisplayNameResolver names,
  }) async {
    final parsed = ReceiptParser.parse(_pagesOneBelowTheOther(pages));
    final catalog = await _productCatalog.readCatalog();
    final layout = (await _storageLayout.readStorageLayout()).withoutDomains(_readPausedDomains());
    final domainsWithBestBefore = _readDomainsWithBestBefore();
    final storeName = parsed.storeName;
    final matcher = ReceiptLineMatcher(
      candidates: [
        for (final product in catalog.activeProducts)
          ReceiptMatchCandidate(
            productIdentifier: product.identifier,
            name: names.productName(product),
          ),
      ],
      mappings: storeName == null
          ? const []
          : await _repository.readMappingsOfStore(ReceiptText.normalize(storeName)),
    );
    final productsByIdentifier = {
      for (final product in catalog.activeProducts) product.identifier: product,
    };
    final lines = <ReceiptReviewLine>[];
    for (final line in parsed.lines) {
      if (line.kind != ReceiptLineKind.item) {
        lines.add(ReceiptReviewLine(parsed: line, status: ReceiptLineStatus.ignored));
        continue;
      }
      final match = matcher.match(line.text, storeName: storeName);
      final product = productsByIdentifier[match.productIdentifier];
      if (product == null) {
        lines.add(
          ReceiptReviewLine(
            parsed: line,
            status: match.status == ReceiptLineStatus.ignored
                ? ReceiptLineStatus.ignored
                : ReceiptLineStatus.unrecognised,
          ),
        );
        continue;
      }
      final compartment = await _suggestCompartment(product, catalog, layout);
      final shelfLifeDays = catalog.recommendedMaximumStorageDaysOf(product);
      final keepsBestBefore =
          compartment != null &&
          domainsWithBestBefore.contains(layout.domainOfCompartment(compartment.identifier));
      lines.add(
        ReceiptReviewLine(
          parsed: line,
          status: match.status,
          product: product,
          quantity: ReceiptQuantityPolicy.suggest(line, product),
          compartment: compartment,
          bestBeforeOn: keepsBestBefore && shelfLifeDays != null
              ? _clock.todayLocal().addDays(shelfLifeDays)
              : null,
        ),
      );
    }
    final ordered = [
      for (final status in _reviewOrder) ...lines.where((line) => line.status == status),
    ];
    return ReceiptReview(
      pages: List.unmodifiable(pages),
      storeName: storeName,
      purchasedOn: parsed.purchasedOn,
      totalInCents: parsed.totalInCents,
      text: parsed.text,
      lines: List.unmodifiable(ordered),
    );
  }

  /// The product's own default, the compartment it went into last time, the
  /// first of its category's domain, or the first of all.
  Future<Compartment?> _suggestCompartment(
    Product product,
    ProductCatalog catalog,
    StorageLayout layout,
  ) async {
    final active = layout.activeCompartments;
    Compartment? find(CompartmentIdentifier? identifier) => identifier == null
        ? null
        : active.where((compartment) => compartment.identifier == identifier).firstOrNull;
    final domain = catalog.categoryOfProduct(product)?.storageDomain;
    return find(product.defaultCompartmentIdentifier) ??
        find(await _inventory.readLastCompartmentOfProduct(product.identifier)) ??
        (domain == null ? null : layout.activeCompartmentsIn(domain).firstOrNull) ??
        active.firstOrNull;
  }

  /// Long receipts come as several photos: each page continues below the
  /// one before, so rows never merge across pages.
  static List<RecognizedTextLine> _pagesOneBelowTheOther(List<RecognizedReceiptPage> pages) {
    final lines = <RecognizedTextLine>[];
    var offset = 0.0;
    for (final page in pages) {
      var pageBottom = 0.0;
      for (final line in page.lines) {
        lines.add(
          RecognizedTextLine(
            text: line.text,
            left: line.left,
            top: line.top + offset,
            right: line.right,
            bottom: line.bottom + offset,
          ),
        );
        if (line.bottom > pageBottom) pageBottom = line.bottom;
      }
      offset += pageBottom + 1000;
    }
    return lines;
  }
}

/// Adds the ticked lines and archives the receipt (architecture 10.10,
/// steps 6 to 8). The batches go in through the inventory's own use case,
/// in one transaction, so restock and reminders react as for a manual add;
/// then the receipt, its lines, the learned texts and the index are stored
/// in a second one.
final class ConfirmReceiptUseCase {
  const ConfirmReceiptUseCase({
    required ReceiptRepository repository,
    required AddStockBatchUseCase addStockBatch,
    required TransactionRunner transactionRunner,
    required IdentifierGenerator identifierGenerator,
    required Clock clock,
  }) : _repository = repository,
       _addStockBatch = addStockBatch,
       _transactionRunner = transactionRunner,
       _identifierGenerator = identifierGenerator,
       _clock = clock;

  final ReceiptRepository _repository;
  final AddStockBatchUseCase _addStockBatch;
  final TransactionRunner _transactionRunner;
  final IdentifierGenerator _identifierGenerator;
  final Clock _clock;

  /// [decisions] by line position. Lines without one stay open; decisions
  /// for discounts and deposits are ignored.
  Future<Result<ReceiptIdentifier, InventoryFailure>> execute(
    ReceiptReview review, {
    required Map<int, ReceiptLineDecision> decisions,
  }) async {
    final itemDecisions = {
      for (final line in review.lines)
        if (line.kind == ReceiptLineKind.item && decisions[line.position] != null)
          line.position: decisions[line.position]!,
    };
    final additions = [
      for (final MapEntry(key: position, value: decision) in itemDecisions.entries)
        if (decision is AddReceiptLine) (position, decision),
    ];
    final batchByPosition = <int, StockBatchIdentifier>{};
    if (additions.isNotEmpty) {
      final today = _clock.todayLocal();
      switch (await _addStockBatch.executeAll([
        for (final (_, decision) in additions) _commandFor(decision, today),
      ])) {
        case SuccessfulResult(value: final batchIdentifiers):
          for (final (index, (position, _)) in additions.indexed) {
            batchByPosition[position] = batchIdentifiers[index];
          }
        case FailedResult(:final failure):
          return Result.failure(failure);
      }
    }
    final receiptIdentifier = _identifierGenerator.createIdentifier<Receipt>();
    final lines = [
      for (final line in [...review.lines]..sort((a, b) => a.position.compareTo(b.position)))
        _archivedLine(
          receiptIdentifier,
          line,
          itemDecisions[line.position],
          batchByPosition[line.position],
        ),
    ];
    final receipt = Receipt(
      summary: ReceiptSummary(
        identifier: receiptIdentifier,
        storeName: review.storeName,
        purchasedOn: review.purchasedOn,
        totalInCents: review.totalInCents,
        pageCount: review.pages.length,
        createdAt: _clock.nowUtc(),
        openLineCount: lines.where((line) => line.isOpen).length,
      ),
      text: review.text,
      pages: [
        for (final (index, page) in review.pages.indexed)
          ReceiptPage(
            pageNumber: index + 1,
            pictureReference: page.pictureReference,
            rawRecognizedText: page.rawText,
          ),
      ],
      lines: lines,
    );
    await _transactionRunner.runInTransaction(() async {
      await _repository.insertReceipt(
        receipt,
        lineSearchTexts: {for (final line in lines) line.identifier: line.text},
      );
      final storeName = review.storeName;
      if (storeName == null) return;
      for (final line in lines) {
        final mapping = _learnedMapping(storeName, line, itemDecisions[line.position]);
        if (mapping != null) await _repository.saveMapping(mapping);
      }
    });
    return Result.success(receiptIdentifier);
  }

  ReceiptLine _archivedLine(
    ReceiptIdentifier receiptIdentifier,
    ReceiptReviewLine line,
    ReceiptLineDecision? decision,
    StockBatchIdentifier? stockBatchIdentifier,
  ) {
    final parsed = line.parsed;
    final (status, productIdentifier) = switch (decision) {
      AddReceiptLine(:final productIdentifier) => (ReceiptLineStatus.matched, productIdentifier),
      IgnoreReceiptLine() => (ReceiptLineStatus.ignored, null),
      null => (line.status, line.product?.identifier),
    };
    return ReceiptLine(
      identifier: _identifierGenerator.createIdentifier<ReceiptLine>(),
      receiptIdentifier: receiptIdentifier,
      position: parsed.position,
      kind: parsed.kind,
      recognizedText: parsed.text,
      correctedText: _correction(decision, parsed.text),
      quantity: parsed.quantity,
      unitPriceInCents: parsed.unitPriceInCents,
      lineTotalInCents: parsed.lineTotalInCents,
      weightInGrams: parsed.weightInGrams,
      status: status,
      productIdentifier: productIdentifier,
      stockBatchIdentifier: stockBatchIdentifier,
    );
  }

  ReceiptTextMapping? _learnedMapping(
    String storeName,
    ReceiptLine line,
    ReceiptLineDecision? decision,
  ) => learnedMapping(storeName: storeName, line: line, decision: decision, clock: _clock);
}

/// Resolves a line that was left open on an archived receipt, later.
final class ResolveReceiptLineUseCase {
  const ResolveReceiptLineUseCase({
    required ReceiptRepository repository,
    required AddStockBatchUseCase addStockBatch,
    required TransactionRunner transactionRunner,
    required Clock clock,
  }) : _repository = repository,
       _addStockBatch = addStockBatch,
       _transactionRunner = transactionRunner,
       _clock = clock;

  final ReceiptRepository _repository;
  final AddStockBatchUseCase _addStockBatch;
  final TransactionRunner _transactionRunner;
  final Clock _clock;

  Future<Result<ReceiptLine, Failure>> execute(
    ReceiptLineIdentifier receiptLineIdentifier,
    ReceiptLineDecision decision,
  ) async {
    final line = await _repository.readLine(receiptLineIdentifier);
    if (line == null || !line.isOpen) return const Result.failure(ReceiptLineNotOpen());
    final receipt = await _repository.readReceipt(line.receiptIdentifier);
    if (receipt == null) return const Result.failure(ReceiptLineNotOpen());
    final ReceiptLine resolvedLine;
    switch (decision) {
      case AddReceiptLine():
        switch (await _addStockBatch.execute(_commandFor(decision, _clock.todayLocal()))) {
          case SuccessfulResult(value: final stockBatchIdentifier):
            resolvedLine = line.resolved(
              status: ReceiptLineStatus.matched,
              productIdentifier: decision.productIdentifier,
              stockBatchIdentifier: stockBatchIdentifier,
              correctedText: _correction(decision, line.recognizedText),
            );
          case FailedResult(:final failure):
            return Result.failure(failure);
        }
      case IgnoreReceiptLine():
        resolvedLine = line.resolved(
          status: ReceiptLineStatus.ignored,
          correctedText: _correction(decision, line.recognizedText),
        );
    }
    await _transactionRunner.runInTransaction(() async {
      await _repository.replaceLine(resolvedLine, searchText: resolvedLine.text);
      final storeName = receipt.storeName;
      if (storeName == null) return;
      final mapping = learnedMapping(
        storeName: storeName,
        line: resolvedLine,
        decision: decision,
        clock: _clock,
      );
      if (mapping != null) await _repository.saveMapping(mapping);
    });
    return Result.success(resolvedLine);
  }
}

/// Removes a receipt from the archive and the search. What its lines added
/// stays in storage.
final class DeleteReceiptUseCase {
  const DeleteReceiptUseCase({required ReceiptRepository repository}) : _repository = repository;

  final ReceiptRepository _repository;

  Future<void> execute(ReceiptIdentifier receiptIdentifier) =>
      _repository.deleteReceipt(receiptIdentifier);
}

AddStockBatchCommand _commandFor(AddReceiptLine decision, CalendarDate today) =>
    AddStockBatchCommand(
      productIdentifier: decision.productIdentifier,
      compartmentIdentifier: decision.compartmentIdentifier,
      quantity: decision.quantity,
      storedOn: today,
      bestBeforeOn: decision.bestBeforeOn,
    );

/// A correction only when it says something else.
String? _correction(ReceiptLineDecision? decision, String recognizedText) {
  final corrected = decision?.correctedText?.trim();
  return corrected == null || corrected.isEmpty || corrected == recognizedText ? null : corrected;
}

/// What a confirmed, corrected or remembered-as-ignored line teaches the
/// matcher about [storeName] (architecture 10.10, step 7).
ReceiptTextMapping? learnedMapping({
  required String storeName,
  required ReceiptLine line,
  required ReceiptLineDecision? decision,
  required Clock clock,
}) {
  final normalizedStore = ReceiptText.normalize(storeName);
  final normalizedText = ReceiptText.normalize(line.recognizedText);
  if (normalizedStore.isEmpty || normalizedText.isEmpty) return null;
  return switch (decision) {
    AddReceiptLine(:final productIdentifier) => ReceiptTextMapping(
      storeName: normalizedStore,
      lineText: normalizedText,
      productIdentifier: productIdentifier,
      learnedAt: clock.nowUtc(),
    ),
    IgnoreReceiptLine(remember: true) => ReceiptTextMapping(
      storeName: normalizedStore,
      lineText: normalizedText,
      learnedAt: clock.nowUtc(),
    ),
    _ => null,
  };
}
