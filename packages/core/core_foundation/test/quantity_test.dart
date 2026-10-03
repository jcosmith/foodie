import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

void main() {
  group('Quantity', () {
    test('partial removal from a 1 kg bag is exact', () {
      var remaining = const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.gram);
      for (final taken in [200, 200, 600]) {
        remaining -= Quantity(amountInBaseUnits: taken, unit: QuantityUnit.gram);
      }
      expect(remaining.isZero, isTrue);
    });

    test('stores half a piece as 500 thousandths', () {
      final halfPizza = Quantity.fromDisplayAmount(0.5, QuantityUnit.piece);
      expect(halfPizza.amountInBaseUnits, 500);
      expect(halfPizza.displayAmount, 0.5);
    });

    test('refuses to mix units', () {
      const grams = Quantity(amountInBaseUnits: 100, unit: QuantityUnit.gram);
      const millilitres = Quantity(amountInBaseUnits: 100, unit: QuantityUnit.milliliter);
      expect(() => grams + millilitres, throwsArgumentError);
      expect(() => grams.compareTo(millilitres), throwsArgumentError);
    });

    test('scales by fractions and rounds to base units', () {
      const bag = Quantity(amountInBaseUnits: 750, unit: QuantityUnit.gram);
      expect(bag.scaledBy(0.25).amountInBaseUnits, 188);
    });

    test('round-trips units through their storage names', () {
      for (final unit in QuantityUnit.values) {
        expect(QuantityUnit.fromStorageName(unit.storageName), unit);
      }
      expect(() => QuantityUnit.fromStorageName('ounce'), throwsArgumentError);
    });
  });
}
