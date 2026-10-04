import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

void main() {
  test('a shelf life counts in days, weeks or months of 30.4 days', () {
    expect(const ShelfLife(1, ShelfLifeUnit.days).inDays, 1);
    expect(const ShelfLife(2, ShelfLifeUnit.weeks).inDays, 14);
    expect(const ShelfLife(1, ShelfLifeUnit.months).inDays, 30);
    expect(const ShelfLife(2, ShelfLifeUnit.months).inDays, 61);
    expect(const ShelfLife(12, ShelfLifeUnit.months).inDays, 365);
  });

  test('stored days come back in the unit they were most likely entered in', () {
    expect(ShelfLife.fromDays(1), const ShelfLife(1, ShelfLifeUnit.days));
    expect(ShelfLife.fromDays(3), const ShelfLife(3, ShelfLifeUnit.days));
    expect(ShelfLife.fromDays(7), const ShelfLife(1, ShelfLifeUnit.weeks));
    expect(ShelfLife.fromDays(21), const ShelfLife(3, ShelfLifeUnit.weeks));
    expect(ShelfLife.fromDays(30), const ShelfLife(1, ShelfLifeUnit.months));
    expect(ShelfLife.fromDays(61), const ShelfLife(2, ShelfLifeUnit.months));
    expect(ShelfLife.fromDays(365), const ShelfLife(12, ShelfLifeUnit.months));
    expect(ShelfLife.fromDays(60), const ShelfLife(60, ShelfLifeUnit.days));
  });

  test('every unit round-trips through days', () {
    for (final unit in ShelfLifeUnit.values) {
      for (var amount = 1; amount <= 36; amount++) {
        final shelfLife = ShelfLife(amount, unit);
        expect(ShelfLife.fromDays(shelfLife.inDays).inDays, shelfLife.inDays, reason: '$shelfLife');
      }
    }
  });

  test('a shelf life lasts from one day to 36 months', () {
    expect(const ShelfLife(1, ShelfLifeUnit.days).isWithinLimits, isTrue);
    expect(const ShelfLife(36, ShelfLifeUnit.months).isWithinLimits, isTrue);
    expect(const ShelfLife(0, ShelfLifeUnit.days).isWithinLimits, isFalse);
    expect(const ShelfLife(37, ShelfLifeUnit.months).isWithinLimits, isFalse);
    expect(const ShelfLife(2000, ShelfLifeUnit.days).isWithinLimits, isFalse);
    expect(ShelfLife.maximumInDays, 1094);
  });
}
