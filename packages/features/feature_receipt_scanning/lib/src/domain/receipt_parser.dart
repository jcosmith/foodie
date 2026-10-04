import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'receipt_rows.dart';
import 'receipt_text.dart';

/// What a priced row of a receipt is.
enum ReceiptLineKind {
  /// Something bought, which can be added to the household.
  item,

  /// A price reduction, printed as a negative amount.
  discount,

  /// A bottle or crate deposit, never a product.
  deposit,
}

/// One priced row of a receipt, with what the rows below it said about it.
@immutable
final class ParsedReceiptLine {
  const ParsedReceiptLine({
    required this.position,
    required this.kind,
    required this.text,
    required this.lineTotalInCents,
    this.quantity = 1,
    this.unitPriceInCents,
    this.weightInGrams,
  });

  /// Order on the receipt, from 0.
  final int position;
  final ReceiptLineKind kind;

  /// The description as printed, without the price: "BIO VOLLM. 1,5%".
  final String text;

  /// Negative for discounts.
  final int lineTotalInCents;

  /// Pieces bought, from a quantity row such as "2 x 1,29".
  final int quantity;

  /// The price of one piece, or of a kilogram for weighed goods.
  final int? unitPriceInCents;

  /// For weighed goods ("0,512 kg x 2,99 EUR/kg").
  final int? weightInGrams;

  ParsedReceiptLine _with({int? quantity, int? unitPriceInCents, int? weightInGrams}) =>
      ParsedReceiptLine(
        position: position,
        kind: kind,
        text: text,
        lineTotalInCents: lineTotalInCents,
        quantity: quantity ?? this.quantity,
        unitPriceInCents: unitPriceInCents ?? this.unitPriceInCents,
        weightInGrams: weightInGrams ?? this.weightInGrams,
      );
}

/// What the parser found on a receipt.
@immutable
final class ParsedReceipt {
  const ParsedReceipt({
    required this.lines,
    required this.text,
    this.storeName,
    this.purchasedOn,
    this.totalInCents,
  });

  final String? storeName;
  final CalendarDate? purchasedOn;
  final int? totalInCents;
  final List<ParsedReceiptLine> lines;

  /// Every row, top to bottom, with card and loyalty numbers masked: what is
  /// stored and searched.
  final String text;
}

/// Reads receipts from recognised text (architecture 10.10, step 3). Pure
/// and rule based, so it is tested with recorded text instead of a camera.
/// It never guesses: rows it does not understand are left out of the lines
/// but stay in the text. Prices may use a comma or a dot, whatever the
/// language.
abstract final class ReceiptParser {
  /// A price at the end of a row, with an optional currency before or after
  /// it and the tax letter German receipts print: "2,58 B", "EUR 5,15",
  /// "£2.35", "-0,20 A".
  static final RegExp _trailingPrice = RegExp(
    r'(?:^|\s)(?:EUR|€|£|\$|CHF)?\s?(-?\d{1,5}[.,]\d{2})(?:\s?(?:EUR|€|CHF))?(?:\s[A-Z0-9*]{1,2})?$',
  );

  /// A row of its own saying how many pieces the row above is: "2 Stk x 1,29".
  static final RegExp _quantityRow = RegExp(
    r'^(\d{1,3})\s*(?:stk|st|pcs|pc|x)?\.?\s*[x×*]\s*(\d{1,5}[.,]\d{2})(?:\s?(?:EUR|€))?$',
    caseSensitive: false,
  );

  /// A quantity printed in the item row itself: "Apples 3 x 0.40" or
  /// "Milch 1,29 x 2".
  static final RegExp _inlineQuantity = RegExp(r'\s(\d{1,3})\s*[x×*]\s*(\d{1,5}[.,]\d{2})$');
  static final RegExp _inlinePriceFirstQuantity = RegExp(
    r'\s(\d{1,5}[.,]\d{2})\s*[x×*]\s*(\d{1,3})$',
  );

  /// A weight row for the row above: "0,512 kg x 2,99 EUR/kg".
  static final RegExp _weightRow = RegExp(
    r'^(\d{1,3}[.,]\d{1,3})\s*kg\s*[x×*]\s*(\d{1,5}[.,]\d{2})',
    caseSensitive: false,
  );

  static final RegExp _subtotalWord = RegExp(
    r'zwischensumme|subtotal|sub-total|sub total|netto|brutto',
    caseSensitive: false,
  );
  static final RegExp _totalWord = RegExp(
    r'^(?:summe|total|gesamt|zu zahlen|endbetrag|amount due|balance due)\b',
    caseSensitive: false,
  );

  /// Rows about paying, change and loyalty programmes, which start with
  /// the word ("Bar", "EC-Cash", "Visa"), so "Chocolate bar" stays an item.
  static final RegExp _paymentRow = RegExp(
    r'^(?:bar|cash|geg\.|gegeben|ec\b|ec-|girocard|karte|card|credit|debit|visa|mastercard|'
    r'maestro|amex|paid|tendered|change|rückgeld|rueckgeld)',
    caseSensitive: false,
  );

  /// Tax, signature and loyalty rows, wherever the word stands.
  static final RegExp _bookkeepingWord = RegExp(
    r'mwst|\bust\b|steuer|\bvat\b|\btax\b|kartenzahlung|payback|punkte|\bpoints\b|'
    r'loyalty|\btse\b|signatur',
    caseSensitive: false,
  );
  static final RegExp _discountWord = RegExp(
    r'rabatt|nachlass|preisvorteil|coupon|gutschein|discount|saving|offer|aktion',
    caseSensitive: false,
  );
  static final RegExp _depositWord = RegExp(
    r'pfand|leergut|deposit|bottle return',
    caseSensitive: false,
  );

  static final RegExp _dayFirstDate = RegExp(r'\b(\d{1,2})[./](\d{1,2})[./](\d{2,4})\b');
  static final RegExp _isoDate = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b');
  static final RegExp _letter = RegExp('[A-Za-zÄÖÜäöüß]');

  static ParsedReceipt parse(List<RecognizedTextLine> lines) {
    final rows = [
      for (final row in ReceiptRows.fromLines(lines))
        if (row.text.isNotEmpty) ReceiptText.maskPrivateNumbers(row.text),
    ];
    String? storeName;
    CalendarDate? purchasedOn;
    int? totalInCents;
    final parsedLines = <ParsedReceiptLine>[];

    void amendLast(ParsedReceiptLine Function(ParsedReceiptLine line) change) {
      final last = parsedLines.lastOrNull;
      if (last != null && last.kind == ReceiptLineKind.item) {
        parsedLines[parsedLines.length - 1] = change(last);
      }
    }

    for (final row in rows) {
      purchasedOn ??= _dateIn(row);
      if (_quantityRow.firstMatch(row) case final match?) {
        amendLast(
          (line) => line._with(quantity: int.parse(match[1]!), unitPriceInCents: _cents(match[2]!)),
        );
        continue;
      }
      if (_weightRow.firstMatch(row) case final match?) {
        amendLast(
          (line) => line._with(
            weightInGrams: (_decimal(match[1]!) * 1000).round(),
            unitPriceInCents: _cents(match[2]!),
          ),
        );
        continue;
      }
      final priceMatch = _trailingPrice.firstMatch(row);
      if (priceMatch == null) {
        if (storeName == null && purchasedOn == null && _letter.hasMatch(row)) storeName = row;
        continue;
      }
      final amount = _cents(priceMatch[1]!);
      final description = row.substring(0, priceMatch.start).trim();
      if (_subtotalWord.hasMatch(description)) continue;
      if (_totalWord.hasMatch(description)) {
        totalInCents ??= amount;
        continue;
      }
      if (_paymentRow.hasMatch(description) ||
          _bookkeepingWord.hasMatch(description) ||
          !_letter.hasMatch(description)) {
        continue;
      }
      final kind = amount < 0 || _discountWord.hasMatch(description)
          ? ReceiptLineKind.discount
          : _depositWord.hasMatch(description)
          ? ReceiptLineKind.deposit
          : ReceiptLineKind.item;
      var text = description;
      var quantity = 1;
      int? unitPrice;
      if (_inlineQuantity.firstMatch(description) case final match?
          when kind == ReceiptLineKind.item) {
        quantity = int.parse(match[1]!);
        unitPrice = _cents(match[2]!);
        text = description.substring(0, match.start).trim();
      } else if (_inlinePriceFirstQuantity.firstMatch(description) case final match?
          when kind == ReceiptLineKind.item) {
        unitPrice = _cents(match[1]!);
        quantity = int.parse(match[2]!);
        text = description.substring(0, match.start).trim();
      }
      parsedLines.add(
        ParsedReceiptLine(
          position: parsedLines.length,
          kind: kind,
          text: text,
          lineTotalInCents: kind == ReceiptLineKind.discount ? -amount.abs() : amount,
          quantity: quantity,
          unitPriceInCents: unitPrice,
        ),
      );
    }
    return ParsedReceipt(
      storeName: storeName,
      purchasedOn: purchasedOn,
      totalInCents: totalInCents,
      lines: List.unmodifiable(parsedLines),
      text: rows.join('\n'),
    );
  }

  /// Day first, as in every supported language ("14.09.2026",
  /// "03/10/2026"), or ISO dates; two-digit years are this century.
  static CalendarDate? _dateIn(String row) {
    if (_isoDate.firstMatch(row) case final match?) {
      return _validDate(int.parse(match[1]!), int.parse(match[2]!), int.parse(match[3]!));
    }
    if (_dayFirstDate.firstMatch(row) case final match?) {
      final year = int.parse(match[3]!);
      return _validDate(
        year < 100 ? 2000 + year : year,
        int.parse(match[2]!),
        int.parse(match[1]!),
      );
    }
    return null;
  }

  static CalendarDate? _validDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 2000 || year > 2100) {
      return null;
    }
    final date = DateTime.utc(year, month, day);
    return date.month == month ? CalendarDate(year, month, day) : null;
  }

  static int _cents(String amount) => (_decimal(amount) * 100).round();

  static double _decimal(String amount) => double.parse(amount.replaceAll(',', '.'));
}
