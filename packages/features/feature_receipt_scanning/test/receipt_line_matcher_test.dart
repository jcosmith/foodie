import 'package:feature_product_catalog/domain.dart';
import 'package:feature_receipt_scanning/domain.dart';
import 'package:flutter_test/flutter_test.dart';

const _milk = ProductIdentifier('product-milk');
const _bananas = ProductIdentifier('product-bananas');
const _garlic = ProductIdentifier('product-garlic');
const _oliveOil = ProductIdentifier('product-olive-oil');

const _candidates = [
  ReceiptMatchCandidate(productIdentifier: _milk, name: 'Whole milk'),
  ReceiptMatchCandidate(productIdentifier: _bananas, name: 'Bananas'),
  ReceiptMatchCandidate(productIdentifier: _garlic, name: 'Garlic'),
  ReceiptMatchCandidate(productIdentifier: _oliveOil, name: 'Olivenöl'),
];

void main() {
  test('texts are compared without case, accents, punctuation or extra spaces', () {
    expect(ReceiptText.normalize('  BIO  Vollm. 1,5%  '), 'bio vollm 1 5');
    expect(ReceiptText.normalize('Olivenöl'), 'olivenoel');
    expect(ReceiptText.normalize('REWE Markt GmbH'), ReceiptText.normalize('rewe  markt gmbh!'));
  });

  test('a mapping learned for the store wins, and only for that store', () {
    final mappings = [
      ReceiptTextMapping(
        storeName: ReceiptText.normalize('REWE Markt GmbH'),
        lineText: ReceiptText.normalize('BIO VOLLM. 1,5%'),
        productIdentifier: _milk,
      ),
    ];
    final matcher = ReceiptLineMatcher(candidates: _candidates, mappings: mappings);

    final atRewe = matcher.match('BIO VOLLM. 1,5%', storeName: 'REWE Markt GmbH');
    expect(atRewe.status, ReceiptLineStatus.matched);
    expect(atRewe.productIdentifier, _milk);
    final elsewhere = matcher.match('BIO VOLLM. 1,5%', storeName: 'Other store');
    expect(elsewhere.status, ReceiptLineStatus.unrecognised);
  });

  test('a line remembered as ignored stays ignored at that store', () {
    final matcher = ReceiptLineMatcher(
      candidates: _candidates,
      mappings: [
        ReceiptTextMapping(
          storeName: ReceiptText.normalize('REWE'),
          lineText: ReceiptText.normalize('TV Magazin'),
        ),
      ],
    );
    final match = matcher.match('TV MAGAZIN', storeName: 'rewe');
    expect(match.status, ReceiptLineStatus.ignored);
    expect(match.productIdentifier, isNull);
  });

  test('the same name matches; a close one is only suggested; nothing like it is flagged', () {
    final matcher = ReceiptLineMatcher(candidates: _candidates, mappings: const []);

    final exact = matcher.match('BANANAS', storeName: null);
    expect((exact.status, exact.productIdentifier), (ReceiptLineStatus.matched, _bananas));

    final close = matcher.match('BANANEN', storeName: null);
    expect((close.status, close.productIdentifier), (ReceiptLineStatus.suggested, _bananas));

    final containing = matcher.match('BIO OLIVENOEL EXTRA 0,75L', storeName: null);
    expect(
      (containing.status, containing.productIdentifier),
      (ReceiptLineStatus.suggested, _oliveOil),
    );

    final unknown = matcher.match('KNOBL. 3ST', storeName: null);
    expect(unknown.status, ReceiptLineStatus.unrecognised);
    expect(unknown.productIdentifier, isNull);
  });
}
