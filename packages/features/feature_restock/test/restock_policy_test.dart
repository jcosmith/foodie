import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_restock/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:flutter_test/flutter_test.dart';

Quantity _grams(int grams) => Quantity(amountInBaseUnits: grams, unit: QuantityUnit.gram);

void main() {
  const spinach = ProductIdentifier('spinach');
  const peas = ProductIdentifier('peas');
  final spinachRule = RestockRule(
    productIdentifier: spinach,
    minimumQuantity: _grams(1500),
    isActive: true,
  );

  ShoppingListEntry entry(
    String identifier, {
    required ProductIdentifier productIdentifier,
    required ShoppingListEntryOrigin origin,
    Quantity? requestedQuantity,
    DateTime? checkedAt,
  }) => ShoppingListEntry(
    identifier: ShoppingListEntryIdentifier(identifier),
    productIdentifier: productIdentifier,
    requestedQuantity: requestedQuantity,
    origin: origin,
    createdAt: DateTime.utc(2026, 10, 1),
    checkedAt: checkedAt,
  );

  group('quantityToBuy', () {
    test('fills up to the minimum, at least one package', () {
      expect(
        RestockPolicy.quantityToBuy(
          rule: spinachRule,
          stock: _grams(1200),
          packageQuantity: _grams(1000),
        ),
        _grams(1000),
      );
      expect(
        RestockPolicy.quantityToBuy(
          rule: spinachRule,
          stock: _grams(200),
          packageQuantity: _grams(1000),
        ),
        _grams(1300),
      );
    });

    test('fills up to the target when there is one', () {
      final ruleWithTarget = RestockRule(
        productIdentifier: spinach,
        minimumQuantity: _grams(1000),
        targetQuantity: _grams(3000),
        isActive: true,
      );

      expect(RestockPolicy.quantityToBuy(rule: ruleWithTarget, stock: _grams(500)), _grams(2500));
    });
  });

  test('a product is running low below its minimum, while the rule is active', () {
    expect(RestockPolicy.isRunningLow(rule: spinachRule, stock: _grams(1499)), isTrue);
    expect(RestockPolicy.isRunningLow(rule: spinachRule, stock: _grams(1500)), isFalse);
    expect(
      RestockPolicy.isRunningLow(
        rule: RestockRule(
          productIdentifier: spinach,
          minimumQuantity: _grams(1500),
          isActive: false,
        ),
        stock: _grams(0),
      ),
      isFalse,
    );
  });

  group('reconcile', () {
    test('adds running-low products that are not on the list yet', () {
      final changes = RestockPolicy.reconcile(
        rules: [spinachRule],
        stockByProduct: {spinach: _grams(500)},
        packageQuantityByProduct: {spinach: _grams(1000)},
        entries: const [],
      );

      expect(changes.entriesToAdd.single.productIdentifier, spinach);
      expect(changes.entriesToAdd.single.quantityToBuy, _grams(1000));
    });

    test('a product the user already put on the list is not added again', () {
      final changes = RestockPolicy.reconcile(
        rules: [spinachRule],
        stockByProduct: const {},
        packageQuantityByProduct: const {},
        entries: [
          entry('manual', productIdentifier: spinach, origin: ShoppingListEntryOrigin.manual),
        ],
      );

      expect(changes.isEmpty, isTrue);
    });

    test('updates automatic entries with the stock and removes them once stocked', () {
      final automaticSpinach = entry(
        'auto-spinach',
        productIdentifier: spinach,
        origin: ShoppingListEntryOrigin.restock,
        requestedQuantity: _grams(1000),
      );
      final automaticPeas = entry(
        'auto-peas',
        productIdentifier: peas,
        origin: ShoppingListEntryOrigin.restock,
        requestedQuantity: _grams(500),
      );

      final changes = RestockPolicy.reconcile(
        rules: [spinachRule],
        stockByProduct: {spinach: _grams(100)},
        packageQuantityByProduct: {spinach: _grams(1000)},
        entries: [automaticSpinach, automaticPeas],
      );

      expect(changes.entriesToUpdate.single.requestedQuantity, _grams(1400));
      expect(changes.entriesToRemove, [automaticPeas]);
      expect(changes.entriesToAdd, isEmpty);
    });

    test('leaves ticked entries alone', () {
      final tickedSpinach = entry(
        'auto-spinach',
        productIdentifier: spinach,
        origin: ShoppingListEntryOrigin.restock,
        requestedQuantity: _grams(1000),
        checkedAt: DateTime.utc(2026, 10, 2),
      );

      final changes = RestockPolicy.reconcile(
        rules: [spinachRule],
        stockByProduct: {spinach: _grams(5000)},
        packageQuantityByProduct: const {},
        entries: [tickedSpinach],
      );

      expect(changes.isEmpty, isTrue);
    });
  });

  group('runs out in', () {
    var movementNumber = 0;
    InventoryMovement eaten(ProductIdentifier product, int grams, {MovementKind? kind}) =>
        InventoryMovement(
          identifier: InventoryMovementIdentifier('movement-${movementNumber++}'),
          stockBatchIdentifier: const StockBatchIdentifier('batch'),
          productIdentifier: product,
          compartmentIdentifier: const CompartmentIdentifier('drawer'),
          kind: kind ?? MovementKind.consumed,
          quantityDelta: _grams(-grams),
          occurredAt: DateTime.utc(2026, 9, 20),
        );
    final peasRule = RestockRule(
      productIdentifier: peas,
      minimumQuantity: _grams(500),
      isActive: true,
    );
    const pizza = ProductIdentifier('pizza');
    final pizzaRule = RestockRule(
      productIdentifier: pizza,
      minimumQuantity: _grams(1),
      isActive: true,
    );

    test('divides the stock by the eating rate of the last 60 days, soonest first', () {
      final forecasts = StockRunOutForecasting.forecast(
        rules: [pizzaRule, spinachRule, peasRule],
        stockByProduct: {spinach: _grams(100), peas: _grams(2000)},
        recentMovements: [
          eaten(spinach, 600),
          eaten(spinach, 300),
          // An undone eat and a thrown-away bag do not count as eating.
          eaten(spinach, -300),
          eaten(peas, 600),
          eaten(peas, 600, kind: MovementKind.discarded),
        ],
        canonicalUnitOf: (_) => QuantityUnit.gram,
      );

      expect(
        [for (final forecast in forecasts) forecast.productIdentifier],
        [spinach, peas, pizza],
      );
      // 600 g in 60 days is 10 g a day.
      expect(forecasts[0].daysLeft, 10);
      expect(forecasts[0].runsOutSoon, isFalse);
      expect(forecasts[1].daysLeft, 200);
      expect(forecasts[2].daysLeft, isNull);
      expect(forecasts[2].stock, const Quantity.zero(QuantityUnit.gram));
      expect(forecasts[2].runsOutSoon, isFalse);
    });

    test('marks products that run out within ten days', () {
      final forecasts = StockRunOutForecasting.forecast(
        rules: [spinachRule],
        stockByProduct: {spinach: _grams(90)},
        recentMovements: [eaten(spinach, 600)],
        canonicalUnitOf: (_) => QuantityUnit.gram,
      );

      expect(forecasts.single.daysLeft, 9);
      expect(forecasts.single.runsOutSoon, isTrue);
    });
  });
}
