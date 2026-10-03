import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

final class _Product {}

final class _StockBatch {}

void main() {
  group('TypedIdentifier', () {
    test('identifiers of different entity kinds are never equal', () {
      const productIdentifier = TypedIdentifier<_Product>('same');
      const Object batchIdentifier = TypedIdentifier<_StockBatch>('same');
      expect(productIdentifier, isNot(equals(batchIdentifier)));
      expect(productIdentifier, const TypedIdentifier<_Product>('same'));
    });

    test('UUID generator produces unique version 4 UUIDs', () {
      const generator = UuidIdentifierGenerator();
      final identifiers = List.generate(100, (_) => generator.createIdentifier<_Product>().value);
      expect(identifiers.toSet(), hasLength(100));
      expect(identifiers.first, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-')));
    });

    test('sequential generator is predictable', () {
      final generator = SequentialIdentifierGenerator();
      expect(generator.createIdentifier<_Product>().value, '00000000-0000-4000-8000-000000000001');
      expect(generator.createIdentifier<_Product>().value, '00000000-0000-4000-8000-000000000002');
    });
  });

  group('FixedClock', () {
    test('only moves when told to', () {
      final clock = FixedClock(DateTime.utc(2026, 10, 2, 12));
      expect(clock.nowUtc(), DateTime.utc(2026, 10, 2, 12));
      clock.advanceBy(const Duration(days: 1));
      expect(clock.nowUtc(), DateTime.utc(2026, 10, 3, 12));
    });
  });
}
