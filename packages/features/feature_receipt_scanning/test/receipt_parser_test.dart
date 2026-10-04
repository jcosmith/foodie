import 'package:core_foundation/core_foundation.dart';
import 'package:feature_receipt_scanning/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// A line as text recognition returns it: text and its box on the page.
RecognizedTextLine _line(String text, double top, {double left = 10, double? right}) =>
    RecognizedTextLine(
      text: text,
      left: left,
      top: top,
      right: right ?? left + text.length * 8,
      bottom: top + 14,
    );

/// Rows of text, each row a list of pieces from left to right, as the
/// recognizer splits a description and its price into separate lines.
List<RecognizedTextLine> _page(List<List<String>> rows) => [
  for (final (index, row) in rows.indexed)
    for (final (column, piece) in row.indexed)
      _line(piece, 20.0 + index * 20, left: column == 0 ? 10 : 300),
];

void main() {
  group('rows', () {
    test('pieces on the same height form one row, read left to right', () {
      final rows = ReceiptRows.fromLines([
        _line('2,58 B', 41, left: 300),
        _line('MILCH 1,5%', 40),
        _line('BROT', 61),
        _line('1,99 A', 59, left: 300),
      ]);
      expect(rows.map((row) => row.text), ['MILCH 1,5% 2,58 B', 'BROT 1,99 A']);
    });
  });

  group('a German supermarket receipt', () {
    final receipt = ReceiptParser.parse(
      _page([
        ['REWE Markt GmbH'],
        ['Hauptstr. 5, 10115 Berlin'],
        ['EUR'],
        ['BIO VOLLM. 1,5%', '2,58 B'],
        ['  2 Stk x 1,29'],
        ['BANANEN', '1,53 B'],
        ['  0,512 kg x 2,99 EUR/kg'],
        ['KNOBL. 3ST', '0,99 B'],
        ['Rabatt Bananen', '-0,20 B'],
        ['PFAND 0,25', '0,25 A'],
        ['--------------------'],
        ['SUMME', 'EUR 5,15'],
        ['Geg. EC-Cash', 'EUR 5,15'],
        ['Kartennr. ************4711'],
        ['MwSt 7% 0,30'],
        ['PAYBACK Karte 3081234567890'],
        ['14.09.2026 18:42 Bon 1234'],
      ]),
    );

    test('finds the store, the date and the total', () {
      expect(receipt.storeName, 'REWE Markt GmbH');
      expect(receipt.purchasedOn, CalendarDate(2026, 9, 14));
      expect(receipt.totalInCents, 515);
    });

    test('reads the item lines with quantities and weights', () {
      final items = receipt.lines.where((line) => line.kind == ReceiptLineKind.item).toList();
      expect(items.map((line) => line.text), ['BIO VOLLM. 1,5%', 'BANANEN', 'KNOBL. 3ST']);
      expect(items[0].quantity, 2);
      expect(items[0].unitPriceInCents, 129);
      expect(items[0].lineTotalInCents, 258);
      expect(items[1].weightInGrams, 512);
      expect(items[1].unitPriceInCents, 299, reason: 'per kilogram');
      expect(items[1].lineTotalInCents, 153);
      expect(items[2].quantity, 1);
      expect(items[2].lineTotalInCents, 99);
    });

    test('keeps discounts and deposits apart and skips totals, payment and tax', () {
      expect(receipt.lines.map((line) => (line.kind, line.lineTotalInCents)).toList(), [
        (ReceiptLineKind.item, 258),
        (ReceiptLineKind.item, 153),
        (ReceiptLineKind.item, 99),
        (ReceiptLineKind.discount, -20),
        (ReceiptLineKind.deposit, 25),
      ]);
      expect(receipt.lines.map((line) => line.position), [0, 1, 2, 3, 4]);
    });

    test('masks card and loyalty numbers before the text is kept', () {
      expect(receipt.text, isNot(contains('4711')));
      expect(receipt.text, isNot(contains('3081234567890')));
      expect(receipt.text, contains('BIO VOLLM. 1,5%'));
      expect(receipt.text, contains('Kartennr.'));
    });
  });

  test('an English receipt with dots, a day-first date and an inline quantity', () {
    final receipt = ReceiptParser.parse(
      _page([
        ['Corner Shop'],
        ['Date: 03/10/2026'],
        ['Whole milk', '1.15'],
        ['Apples 3 x 0.40', '1.20'],
        ['Subtotal', '2.35'],
        ['VAT', '0.00'],
        ['TOTAL', '£2.35'],
        ['VISA **** **** **** 1234'],
        ['Change', '0.00'],
      ]),
    );
    expect(receipt.storeName, 'Corner Shop');
    expect(receipt.purchasedOn, CalendarDate(2026, 10, 3));
    expect(receipt.totalInCents, 235);
    expect(receipt.lines.map((line) => line.text), ['Whole milk', 'Apples']);
    expect(receipt.lines.last.quantity, 3);
    expect(receipt.lines.last.unitPriceInCents, 40);
    expect(receipt.text, isNot(contains('1234')));
  });

  test('a page without prices gives no lines and no total, and never throws', () {
    final receipt = ReceiptParser.parse(
      _page([
        ['Thank you'],
        ['for shopping'],
      ]),
    );
    expect(receipt.lines, isEmpty);
    expect(receipt.totalInCents, isNull);
    expect(receipt.purchasedOn, isNull);
    expect(receipt.storeName, 'Thank you');
    expect(ReceiptParser.parse(const []).storeName, isNull);
  });
}
