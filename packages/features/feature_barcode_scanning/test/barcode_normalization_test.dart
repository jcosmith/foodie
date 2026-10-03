import 'package:core_foundation/core_foundation.dart';
import 'package:feature_barcode_scanning/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  NormalizedBarcode normalize(String value, BarcodeSymbology symbology) =>
      BarcodeNormalization.normalize(ScannedBarcode(value: value, symbology: symbology));

  test('a retail code is learned as it is', () {
    final barcode = normalize('4001234567891', BarcodeSymbology.ean13);

    expect(barcode.lookupValue, '4001234567891');
    expect(barcode.isVariableMeasure, isFalse);
    expect(barcode.embeddedWeightFor(QuantityUnit.gram), isNull);
  });

  test('a UPC-A code matches its EAN-13 form', () {
    expect(
      normalize('012345678905', BarcodeSymbology.upcA).lookupValue,
      normalize('0012345678905', BarcodeSymbology.ean13).lookupValue,
    );
  });

  test('weighed goods match on the item part and carry their weight', () {
    final firstPackage = normalize('2412345003505', BarcodeSymbology.ean13);
    final secondPackage = normalize('2412345004205', BarcodeSymbology.ean13);

    expect(firstPackage.isVariableMeasure, isTrue);
    expect(firstPackage.lookupValue, '2412345');
    expect(secondPackage.lookupValue, firstPackage.lookupValue);
    expect(
      firstPackage.embeddedWeightFor(QuantityUnit.gram),
      const Quantity(amountInBaseUnits: 350, unit: QuantityUnit.gram),
    );
    // A product counted in pieces gets no weight.
    expect(firstPackage.embeddedWeightFor(QuantityUnit.piece), isNull);
    // A zero value says nothing about the weight.
    expect(
      normalize('2012345000001', BarcodeSymbology.ean13).embeddedWeightFor(QuantityUnit.gram),
      isNull,
    );
  });

  test('a UPC-A weighed-goods code (prefix 2) is recognised as prefix 02', () {
    final barcode = normalize('212345003503', BarcodeSymbology.upcA);

    expect(barcode.isVariableMeasure, isTrue);
    expect(barcode.lookupValue, '0212345');
    expect(barcode.embeddedMeasureValue, 350);
  });

  test('a misread check digit or another prefix is not weighed goods', () {
    expect(normalize('2412345003506', BarcodeSymbology.ean13).isVariableMeasure, isFalse);
    expect(normalize('4001234567891', BarcodeSymbology.ean13).isVariableMeasure, isFalse);
    // Only retail symbologies have GS1 prefixes.
    expect(normalize('2412345003505', BarcodeSymbology.code128).isVariableMeasure, isFalse);
    expect(BarcodeNormalization.hasValidCheckDigit('4001234567891'), isTrue);
    expect(BarcodeNormalization.hasValidCheckDigit('4001234567890'), isFalse);
  });

  test('surrounding spaces are ignored', () {
    expect(
      normalize(' https://example.org/label ', BarcodeSymbology.qrCode).lookupValue,
      'https://example.org/label',
    );
  });
}
