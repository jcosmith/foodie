import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'scanned_barcode.dart';

/// A scanned code prepared for looking up its product.
@immutable
final class NormalizedBarcode {
  const NormalizedBarcode({
    required this.scannedValue,
    required this.lookupValue,
    required this.symbology,
    required this.isVariableMeasure,
    this.embeddedMeasureValue,
  });

  /// What the camera read, shown to the user.
  final String scannedValue;

  /// What the code is learned and looked up under: the whole code, or for
  /// weighed goods only the prefix and item part.
  final String lookupValue;

  final BarcodeSymbology symbology;

  /// A weighed-goods code whose last digits change from package to package.
  final bool isVariableMeasure;

  /// The value printed into a weighed-goods code (weight or price).
  final int? embeddedMeasureValue;

  /// The embedded weight as an amount of a product measured in [unit], or
  /// `null` when the code has none or the product is not weighed in grams.
  Quantity? embeddedWeightFor(QuantityUnit unit) => switch (embeddedMeasureValue) {
    final value? when unit == QuantityUnit.gram && value > 0 => Quantity(
      amountInBaseUnits: value,
      unit: QuantityUnit.gram,
    ),
    _ => null,
  };
}

/// Turns what the camera read into what a code is learned under
/// (architecture document, section 10.3).
///
/// Weighed goods: in-store codes for loose meat or cheese use the GS1
/// restricted-circulation prefixes 02 and 20 to 29. Their layout is set by
/// each country's GS1 organisation; this follows the common one of two
/// prefix digits, five item digits, five value digits and the check digit
/// (`PP IIIII VVVVV C`). The item part (`PPIIIII`) identifies the product;
/// the value is read as grams for products weighed in grams. Where a shop
/// prints a price there instead, the amount shown in the add form is wrong
/// and the user corrects it before saving.
abstract final class BarcodeNormalization {
  static const int _variableMeasureItemPartLength = 7;
  static const int _ean13Length = 13;

  static NormalizedBarcode normalize(ScannedBarcode scanned) {
    final value = scanned.value.trim();
    // A UPC-A code is an EAN-13 code with a leading zero; using one form
    // makes a code match however the camera reports it.
    final retailDigits = switch (scanned.symbology) {
      BarcodeSymbology.upcA when _isDigits(value, length: 12) => '0$value',
      _ => value,
    };
    final isRetailCode =
        scanned.symbology == BarcodeSymbology.ean13 || scanned.symbology == BarcodeSymbology.upcA;
    if (isRetailCode && isVariableMeasureCode(retailDigits)) {
      return NormalizedBarcode(
        scannedValue: value,
        lookupValue: retailDigits.substring(0, _variableMeasureItemPartLength),
        symbology: BarcodeSymbology.ean13,
        isVariableMeasure: true,
        embeddedMeasureValue: int.parse(retailDigits.substring(_variableMeasureItemPartLength, 12)),
      );
    }
    return NormalizedBarcode(
      scannedValue: value,
      lookupValue: isRetailCode ? retailDigits : value,
      symbology: isRetailCode ? BarcodeSymbology.ean13 : scanned.symbology,
      isVariableMeasure: false,
    );
  }

  /// An EAN-13 code with a valid check digit and a GS1 prefix for weighed
  /// goods (02 or 20 to 29).
  static bool isVariableMeasureCode(String digits) {
    if (!_isDigits(digits, length: _ean13Length) || !hasValidCheckDigit(digits)) return false;
    final prefix = int.parse(digits.substring(0, 2));
    return prefix == 2 || (prefix >= 20 && prefix <= 29);
  }

  /// The GS1 check digit: weights 3 and 1 alternate from the right.
  static bool hasValidCheckDigit(String digits) {
    if (digits.length < 2 || !_isDigits(digits, length: digits.length)) return false;
    var sum = 0;
    for (var index = 0; index < digits.length - 1; index++) {
      final digit = digits.codeUnitAt(digits.length - 2 - index) - 0x30;
      sum += index.isEven ? digit * 3 : digit;
    }
    final checkDigit = (10 - sum % 10) % 10;
    return checkDigit == digits.codeUnitAt(digits.length - 1) - 0x30;
  }

  static bool _isDigits(String text, {required int length}) =>
      text.length == length && RegExp(r'^[0-9]+$').hasMatch(text);
}
