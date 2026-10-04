import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_receipt_scanning/feature_receipt_scanning.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/receipt_scanning_test_harness.dart';

const _shopping = [
  ['Fresh Market'],
  ['Garden peas', '1.99'],
  ['MINCED BEEF 500G', '4.49'],
  ['Chicken breast 2 x 3.50', '7.00'],
  ['Magazine', '3.20'],
  ['Deposit', '0.25'],
  ['TOTAL', '16.93'],
  ['VISA **** **** **** 4711', '16.93'],
  ['03.10.2026'],
];

void main() {
  late ReceiptScanningTestHarness harness;

  setUp(() async {
    harness = ReceiptScanningTestHarness();
    await harness.seedCatalogAndStoragePlace();
  });

  tearDown(() => harness.dispose());

  ReceiptReviewLine lineNamed(ReceiptReview review, String text) =>
      review.lines.singleWhere((line) => line.text == text);

  /// Ticks the matched lines, corrects the minced beef and ignores the
  /// magazine for this store, as a user would on the review screen.
  Future<ReceiptIdentifier> confirmShopping(ReceiptReview review) async {
    final mincedMeat = await harness.productWithKey('mincedMeat');
    final drawers = await harness.compartments();
    final result = await harness
        .read(confirmReceiptUseCaseProvider)
        .execute(
          review,
          decisions: {
            for (final line in review.lines)
              if (line.status == ReceiptLineStatus.matched)
                line.position: AddReceiptLine.suggested(line),
            lineNamed(review, 'MINCED BEEF 500G').position: AddReceiptLine(
              productIdentifier: mincedMeat.identifier,
              compartmentIdentifier: drawers[1].identifier,
              quantity: Quantity(amountInBaseUnits: 500, unit: mincedMeat.canonicalUnit),
            ),
            lineNamed(review, 'Magazine').position: const IgnoreReceiptLine(remember: true),
          },
        );
    return result.valueOrNull!;
  }

  group('reviewing a receipt', () {
    test('matches known names, flags unknown lines and never offers deposits', () async {
      final review = await harness.review(_shopping);

      expect(review.storeName, 'Fresh Market');
      expect(review.purchasedOn, CalendarDate(2026, 10, 3));
      expect(review.totalInCents, 1693);
      final peas = lineNamed(review, 'Garden peas');
      expect(peas.status, ReceiptLineStatus.matched);
      expect(peas.product!.catalogKey, 'gardenPeas');
      expect(peas.quantity!.amountInBaseUnits, 750);
      expect(peas.compartment, isNotNull);
      final chicken = lineNamed(review, 'Chicken breast');
      expect(chicken.status, ReceiptLineStatus.matched);
      expect(chicken.quantity!.amountInBaseUnits, 1600, reason: 'two packages of 800 g');
      expect(lineNamed(review, 'MINCED BEEF 500G').status, ReceiptLineStatus.unrecognised);
      expect(lineNamed(review, 'Magazine').status, ReceiptLineStatus.unrecognised);
      expect(lineNamed(review, 'Deposit').status, ReceiptLineStatus.ignored);
      expect(
        review.lines.take(2).map((line) => line.status),
        everyElement(ReceiptLineStatus.unrecognised),
        reason: 'unrecognised lines come first',
      );
    });

    test('weighed goods suggest the weight on the receipt', () async {
      final review = await harness.review([
        ['Fresh Market'],
        ['Minced meat', '2.99'],
        ['0,512 kg x 5,84 EUR/kg'],
      ]);

      expect(review.lines.single.quantity!.amountInBaseUnits, 512);
    });
  });

  group('confirming a receipt', () {
    test('adds the ticked lines to storage and archives the receipt', () async {
      final review = await harness.review(_shopping);

      final receiptIdentifier = await confirmShopping(review);

      final batches = await harness.activeBatches();
      expect(batches, hasLength(3));
      final receipt = (await harness
          .read(receiptQueryServiceProvider)
          .readReceipt(receiptIdentifier))!;
      expect(receipt.storeName, 'Fresh Market');
      expect(receipt.totalInCents, 1693);
      expect(receipt.purchasedOn, CalendarDate(2026, 10, 3));
      expect(receipt.text, isNot(contains('4711')), reason: 'card numbers are masked');
      expect(receipt.pages.single.rawRecognizedText, isNot(contains('4711')));
      expect(receipt.pages.single.rawRecognizedText, contains('MINCED BEEF 500G'));
      expect(receipt.lines, hasLength(5));
      final added = receipt.lines.where((line) => line.stockBatchIdentifier != null);
      expect(
        added.map((line) => line.stockBatchIdentifier),
        unorderedEquals(batches.map((b) => b.identifier)),
      );
      expect(receipt.openLines, isEmpty);
    });

    test('remembers corrections and ignored lines for the next receipt from the store', () async {
      await confirmShopping(await harness.review(_shopping));

      final next = await harness.review([
        ['FRESH MARKET'],
        ['Minced beef 500g', '4.49'],
        ['Magazine', '3.50'],
        ['03.10.2026'],
      ]);

      final mincedBeef = next.lines.singleWhere((line) => line.text == 'Minced beef 500g');
      expect(mincedBeef.status, ReceiptLineStatus.matched);
      expect(mincedBeef.product!.catalogKey, 'mincedMeat');
      expect(
        mincedBeef.compartment!.identifier,
        (await harness.compartments())[1].identifier,
        reason: 'the drawer it went into last time',
      );
      expect(lineNamed(next, 'Magazine').status, ReceiptLineStatus.ignored);
    });

    test('a corrected misread line is what gets learned and searched', () async {
      final review = await harness.review([
        ['Fresh Market'],
        ['GARDFN PEAS', '1.99'],
      ]);
      final peas = await harness.productWithKey('gardenPeas');
      final drawers = await harness.compartments();

      final receiptIdentifier =
          (await harness
                  .read(confirmReceiptUseCaseProvider)
                  .execute(
                    review,
                    decisions: {
                      0: AddReceiptLine(
                        productIdentifier: peas.identifier,
                        compartmentIdentifier: drawers.first.identifier,
                        quantity: peas.defaultPackageQuantity!,
                        correctedText: 'GARDEN PEAS',
                      ),
                    },
                  ))
              .valueOrNull!;

      final line = (await harness.read(receiptQueryServiceProvider).readReceipt(receiptIdentifier))!
          .lines
          .single;
      expect(line.recognizedText, 'GARDFN PEAS', reason: 'the original is kept');
      expect(line.text, 'GARDEN PEAS');
      final hits = await harness.read(receiptQueryServiceProvider).search('garden');
      expect(hits.single.matchingLine!.identifier, line.identifier);
    });

    test('a line left open stays flagged and can be resolved later', () async {
      final review = await harness.review(_shopping);
      final receiptIdentifier =
          (await harness
                  .read(confirmReceiptUseCaseProvider)
                  .execute(
                    review,
                    decisions: {
                      lineNamed(review, 'Garden peas').position: AddReceiptLine.suggested(
                        lineNamed(review, 'Garden peas'),
                      ),
                    },
                  ))
              .valueOrNull!;
      final queries = harness.read(receiptQueryServiceProvider);

      var receipt = (await queries.readReceipt(receiptIdentifier))!;
      expect(
        receipt.openLines.map((line) => line.text),
        unorderedEquals(['MINCED BEEF 500G', 'Chicken breast', 'Magazine']),
      );
      final summaries = await queries.watchReceipts().first;
      expect(summaries.single.openLineCount, 3);

      final mincedMeat = await harness.productWithKey('mincedMeat');
      final open = receipt.openLines.singleWhere((line) => line.text == 'MINCED BEEF 500G');
      final result = await harness
          .read(resolveReceiptLineUseCaseProvider)
          .execute(
            open.identifier,
            AddReceiptLine(
              productIdentifier: mincedMeat.identifier,
              compartmentIdentifier: (await harness.compartments()).first.identifier,
              quantity: mincedMeat.defaultPackageQuantity!,
            ),
          );

      expect(result.isSuccess, isTrue);
      receipt = (await queries.readReceipt(receiptIdentifier))!;
      expect(receipt.openLines, hasLength(2));
      expect(await harness.activeBatches(), hasLength(2));
      final next = await harness.review([
        ['Fresh Market'],
        ['MINCED BEEF 500G', '4.49'],
      ]);
      expect(next.lines.single.status, ReceiptLineStatus.matched, reason: 'learned when resolved');
    });

    test('nothing is archived when a line cannot be added', () async {
      final review = await harness.review(_shopping);
      final peas = lineNamed(review, 'Garden peas');

      final result = await harness
          .read(confirmReceiptUseCaseProvider)
          .execute(
            review,
            decisions: {
              peas.position: AddReceiptLine(
                productIdentifier: peas.product!.identifier,
                compartmentIdentifier: peas.compartment!.identifier,
                quantity: Quantity(amountInBaseUnits: 0, unit: peas.product!.canonicalUnit),
              ),
            },
          );

      expect(result.failureOrNull, isA<QuantityNotPositive>());
      expect(await harness.read(receiptQueryServiceProvider).watchReceipts().first, isEmpty);
      expect(await harness.activeBatches(), isEmpty);
    });
  });

  group('the receipt archive', () {
    test('full-text search finds receipts by item, word prefix and store', () async {
      final receiptIdentifier = await confirmShopping(await harness.review(_shopping));
      final queries = harness.read(receiptQueryServiceProvider);

      final peas = await queries.search('peas');
      expect(peas.single.receipt.identifier, receiptIdentifier);
      expect(peas.single.matchingLine!.text, 'Garden peas');
      expect((await queries.search('gard')).single.matchingLine!.text, 'Garden peas');
      expect((await queries.search('GARDEN PEAS')).single.matchingLine!.text, 'Garden peas');
      final store = await queries.search('fresh market');
      expect(store.single.receipt.identifier, receiptIdentifier);
      expect(store.single.matchingLine, isNull);
      expect(await queries.search('olive'), isEmpty);
      expect(await queries.search('4711'), isEmpty, reason: 'masked numbers are not indexed');
      expect(await queries.search('  '), isEmpty);
    });

    test('lists receipts newest first', () async {
      await confirmShopping(await harness.review(_shopping));
      harness.clock.advanceBy(const Duration(days: 1));
      final review = await harness.review([
        ['Corner Shop'],
        ['Garden peas', '1.99'],
        ['04.10.2026'],
      ]);
      await harness.read(confirmReceiptUseCaseProvider).execute(review, decisions: const {});

      final summaries = await harness.read(receiptQueryServiceProvider).watchReceipts().first;

      expect(summaries.map((receipt) => receipt.storeName), ['Corner Shop', 'Fresh Market']);
      expect(summaries.first.openLineCount, 1);
    });

    test('a corrected line is shown and searched, the recognised text kept', () async {
      final receiptIdentifier = await confirmShopping(await harness.review(_shopping));
      final queries = harness.read(receiptQueryServiceProvider);
      final magazine = (await queries.readReceipt(
        receiptIdentifier,
      ))!.lines.singleWhere((line) => line.text == 'Magazine');

      await harness
          .read(correctReceiptLineTextUseCaseProvider)
          .execute(magazine.identifier, 'Weekly magazine');

      final corrected = (await queries.readReceipt(
        receiptIdentifier,
      ))!.lines.singleWhere((line) => line.identifier == magazine.identifier);
      expect(corrected.text, 'Weekly magazine');
      expect(corrected.recognizedText, 'Magazine');
      expect((await queries.search('weekly')).single.matchingLine!.identifier, magazine.identifier);
    });

    test('old photos go after the chosen time; the text stays searchable', () async {
      harness.camera.queuedPages.add(receiptPage(_shopping));
      final photo = (await harness.camera.takePhoto())!;
      final page = (await harness.read(readReceiptPageUseCaseProvider).execute(photo)).valueOrNull!;
      final review = await harness
          .read(prepareReceiptReviewUseCaseProvider)
          .execute(pages: [page], names: harness.names);
      final receiptIdentifier =
          (await harness.read(confirmReceiptUseCaseProvider).execute(review, decisions: const {}))
              .valueOrNull!;
      final retention = harness.read(applyReceiptPhotoRetentionUseCaseProvider);
      expect(harness.receiptImages.filesByName, hasLength(1));

      harness.clock.advanceBy(const Duration(days: 200));
      expect(await retention.execute(ReceiptPhotoRetention.twelveMonths), 0);
      expect(await retention.execute(ReceiptPhotoRetention.forever), 0);
      expect(await retention.execute(ReceiptPhotoRetention.sixMonths), 1);

      expect(harness.receiptImages.filesByName, isEmpty);
      final receipt = (await harness
          .read(receiptQueryServiceProvider)
          .readReceipt(receiptIdentifier))!;
      expect(receipt.pages.single.pictureReference, isNull);
      expect(receipt.pages.single.rawRecognizedText, contains('Garden peas'));
      expect(await harness.read(receiptQueryServiceProvider).search('peas'), hasLength(1));
    });

    test('deleting a receipt removes it from the archive and the search', () async {
      final receiptIdentifier = await confirmShopping(await harness.review(_shopping));

      await harness.read(deleteReceiptUseCaseProvider).execute(receiptIdentifier);

      final queries = harness.read(receiptQueryServiceProvider);
      expect(await queries.readReceipt(receiptIdentifier), isNull);
      expect(await queries.watchReceipts().first, isEmpty);
      expect(await queries.search('peas'), isEmpty);
      expect(await harness.activeBatches(), hasLength(3), reason: 'what was added stays');
    });
  });
}
