import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_inventory/src/domain/removal_amount_policy.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemovalAmountPolicy', () {
    Quantity grams(int amount) => Quantity(amountInBaseUnits: amount, unit: QuantityUnit.gram);
    Quantity pieces(int thousandths) =>
        Quantity(amountInBaseUnits: thousandths, unit: QuantityUnit.piece);

    test('the step follows the package size: 1 g under 50, 10 up to 200, else 50', () {
      expect(RemovalAmountPolicy.stepFor(grams(49)), grams(1));
      expect(RemovalAmountPolicy.stepFor(grams(50)), grams(10));
      expect(RemovalAmountPolicy.stepFor(grams(200)), grams(10));
      expect(RemovalAmountPolicy.stepFor(grams(201)), grams(50));
      expect(
        RemovalAmountPolicy.stepFor(
          const Quantity(amountInBaseUnits: 30, unit: QuantityUnit.milliliter),
        ),
        const Quantity(amountInBaseUnits: 1, unit: QuantityUnit.milliliter),
      );
      expect(RemovalAmountPolicy.stepFor(pieces(3000)), pieces(500));
      expect(RemovalAmountPolicy.stepFor(pieces(100)), pieces(500));
    });

    test('fractions round to the step and stay within what is left', () {
      expect(RemovalAmountPolicy.fractionOf(grams(500), 0.5, packageSize: grams(500)), grams(250));
      expect(RemovalAmountPolicy.fractionOf(grams(500), 0.25, packageSize: grams(500)), grams(150));
      expect(RemovalAmountPolicy.fractionOf(grams(500), 0.01, packageSize: grams(500)), grams(50));
      expect(RemovalAmountPolicy.fractionOf(grams(430), 1, packageSize: grams(500)), grams(430));
      expect(
        RemovalAmountPolicy.fractionOf(pieces(3000), 0.5, packageSize: pieces(3000)),
        pieces(1500),
      );
    });

    test('small packages get fine steps', () {
      expect(RemovalAmountPolicy.fractionOf(grams(40), 0.25, packageSize: grams(40)), grams(10));
      expect(RemovalAmountPolicy.snap(grams(40), 13, packageSize: grams(40)), grams(13));
      expect(RemovalAmountPolicy.fractionOf(grams(150), 0.25, packageSize: grams(150)), grams(40));
      expect(RemovalAmountPolicy.snap(grams(150), 73, packageSize: grams(150)), grams(70));
    });

    test('the step stays the one of the original package while it is used up', () {
      expect(RemovalAmountPolicy.snap(grams(120), 73, packageSize: grams(500)), grams(50));
    });

    test('a bag holding one step or less is taken whole', () {
      expect(RemovalAmountPolicy.suggestedAmount(grams(40), packageSize: grams(500)), grams(40));
      expect(RemovalAmountPolicy.snap(grams(40), 10, packageSize: grams(500)), grams(40));
    });

    test('the suggestion is about a fifth', () {
      expect(
        RemovalAmountPolicy.suggestedAmount(grams(1000), packageSize: grams(1000)),
        grams(200),
      );
    });

    test('the suggestion is the usual amount, rounded to the step and capped', () {
      expect(
        RemovalAmountPolicy.suggestedAmount(
          grams(1000),
          packageSize: grams(1000),
          usualAmount: grams(230),
        ),
        grams(250),
      );
      expect(
        RemovalAmountPolicy.suggestedAmount(
          grams(180),
          packageSize: grams(1000),
          usualAmount: grams(400),
        ),
        grams(180),
      );
      expect(
        RemovalAmountPolicy.suggestedAmount(
          pieces(6000),
          packageSize: pieces(6000),
          usualAmount: pieces(2000),
        ),
        pieces(2000),
      );
    });

    test('slider positions snap to the grid', () {
      expect(RemovalAmountPolicy.snap(grams(500), 130, packageSize: grams(500)), grams(150));
      expect(RemovalAmountPolicy.snap(grams(500), 0, packageSize: grams(500)), grams(50));
      expect(RemovalAmountPolicy.snap(grams(480), 470, packageSize: grams(500)), grams(450));
      expect(RemovalAmountPolicy.snap(grams(480), 500, packageSize: grams(500)), grams(480));
    });

    group('usual consumed amount', () {
      const product = ProductIdentifier('spinach');
      var counter = 0;
      InventoryMovement movement(
        MovementKind kind,
        int delta, {
        InventoryMovementIdentifier? reverses,
      }) => InventoryMovement(
        identifier: InventoryMovementIdentifier('m${counter++}'),
        stockBatchIdentifier: const StockBatchIdentifier('batch'),
        productIdentifier: product,
        compartmentIdentifier: const CompartmentIdentifier('drawer'),
        kind: kind,
        quantityDelta: grams(delta),
        reversesMovementIdentifier: reverses,
        occurredAt: DateTime.utc(2026, 10, 1),
      );

      test('is null without removals', () {
        expect(
          RemovalAmountPolicy.usualConsumedAmount([movement(MovementKind.added, 1000)]),
          isNull,
        );
      });

      test('averages what was used, leaving out undone removals and discards', () {
        final undone = movement(MovementKind.consumed, -900);
        expect(
          RemovalAmountPolicy.usualConsumedAmount([
            movement(MovementKind.added, 2000),
            movement(MovementKind.consumed, -200),
            movement(MovementKind.consumed, -300),
            undone,
            movement(MovementKind.consumed, 900, reverses: undone.identifier),
            movement(MovementKind.discarded, -500),
          ]),
          grams(250),
        );
      });
    });
  });

  group('UseByPolicy', () {
    final today = CalendarDate(2026, 10, 2);

    UseByDeadline shelfLifeOf(int days, {CalendarDate? storedOn}) =>
        UseByPolicy.deadlineOf(storedOn: storedOn ?? today, shelfLifeDays: days)!;

    test('the earliest of shelf life, best before and opened wins', () {
      final storedOn = CalendarDate(2026, 10, 1);
      final onlyShelfLife = UseByPolicy.deadlineOf(storedOn: storedOn, shelfLifeDays: 30)!;
      expect(onlyShelfLife.reason, UseByReason.shelfLife);
      expect(onlyShelfLife.lastGoodDay, CalendarDate(2026, 10, 30));
      expect(onlyShelfLife.overdueFrom, CalendarDate(2026, 10, 31));

      final bestBefore = UseByPolicy.deadlineOf(
        storedOn: storedOn,
        shelfLifeDays: 30,
        bestBeforeOn: CalendarDate(2026, 10, 10),
      )!;
      expect(bestBefore.reason, UseByReason.bestBefore);
      expect(bestBefore.lastGoodDay, CalendarDate(2026, 10, 10));

      final opened = UseByPolicy.deadlineOf(
        storedOn: storedOn,
        shelfLifeDays: 30,
        bestBeforeOn: CalendarDate(2026, 10, 10),
        openedOn: CalendarDate(2026, 10, 3),
        shelfLifeAfterOpeningDays: 3,
      )!;
      expect(opened.reason, UseByReason.opened);
      expect(opened.countsFrom, CalendarDate(2026, 10, 3));
      expect(opened.lastGoodDay, CalendarDate(2026, 10, 5));

      expect(
        UseByPolicy.deadlineOf(
          storedOn: storedOn,
          openedOn: CalendarDate(2026, 10, 3),
          shelfLifeAfterOpeningDays: null,
        ),
        isNull,
        reason: 'opening matters only with a shelf life after opening',
      );
      expect(UseByPolicy.deadlineOf(storedOn: storedOn), isNull, reason: 'most supplies');
      expect(UseByPolicy.deadlineOf(storedOn: storedOn, shelfLifeDays: 0), isNull);
    });

    test('fresh until 60 %, aging until 85 %, urgent until used up, then overdue', () {
      final deadline = shelfLifeOf(100, storedOn: today);
      UseByStatus statusAfter(int days) => deadline.statusOn(today.addDays(days));
      expect(statusAfter(0), UseByStatus.fresh);
      expect(statusAfter(59), UseByStatus.fresh);
      expect(statusAfter(60), UseByStatus.aging);
      expect(statusAfter(84), UseByStatus.aging);
      expect(statusAfter(85), UseByStatus.urgent);
      expect(statusAfter(99), UseByStatus.urgent);
      expect(statusAfter(100), UseByStatus.overdue);
      expect(statusAfter(400), UseByStatus.overdue);
    });

    test('food that keeps a day or two is due at once', () {
      final oneDay = shelfLifeOf(1);
      expect(oneDay.lastGoodDay, today);
      expect(oneDay.statusOn(today), UseByStatus.urgent, reason: 'use today');
      expect(oneDay.statusOn(today.addDays(1)), UseByStatus.overdue);

      final twoDays = shelfLifeOf(2);
      expect(twoDays.statusOn(today), UseByStatus.aging, reason: 'use by tomorrow');
      expect(twoDays.statusOn(today.addDays(1)), UseByStatus.urgent);
      expect(twoDays.daysLeftOn(today), 1);
    });

    test('a best-before date already passed when stored is overdue at once', () {
      final deadline = UseByPolicy.deadlineOf(storedOn: today, bestBeforeOn: today.addDays(-2))!;
      expect(deadline.statusOn(today), UseByStatus.overdue);
      expect(deadline.firstDayWithStatus(UseByStatus.overdue), today.addDays(-1));
    });

    test('finds the first day of each status', () {
      for (final storageDays in [1, 2, 3, 7, 30, 90, 180, 365]) {
        final deadline = shelfLifeOf(storageDays);
        for (final status in UseByStatus.values) {
          final firstDay = deadline.firstDayWithStatus(status);
          expect(deadline.statusOn(firstDay).index, greaterThanOrEqualTo(status.index));
          if (firstDay != today) {
            expect(deadline.statusOn(firstDay.addDays(-1)).index, lessThan(status.index));
          }
        }
        expect(deadline.firstDayWithStatus(UseByStatus.overdue), deadline.overdueFrom);
      }
      expect(
        shelfLifeOf(100, storedOn: CalendarDate(2026, 1, 1)).firstDayWithStatus(UseByStatus.urgent),
        CalendarDate(2026, 3, 27),
      );
    });

    test('a batch gives its own dates to the policy', () {
      final batch = StockBatch(
        identifier: const StockBatchIdentifier('b'),
        productIdentifier: const ProductIdentifier('p'),
        compartmentIdentifier: const CompartmentIdentifier('c'),
        initialQuantity: const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.milliliter),
        quantityRemaining: const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.milliliter),
        storedOn: today,
        bestBeforeOn: today.addDays(10),
        openedOn: today.addDays(1),
        createdAt: DateTime.utc(2026, 10, 2),
      );
      final deadline = UseByPolicy.deadlineOfBatch(
        batch,
        shelfLifeDays: 30,
        shelfLifeAfterOpeningDays: 3,
      )!;
      expect(deadline.reason, UseByReason.opened);
      expect(deadline.lastGoodDay, today.addDays(3));
    });
  });

  group('StockBatch dates', () {
    StockBatch batch({CalendarDate? bestBeforeOn, CalendarDate? openedOn}) => StockBatch(
      identifier: const StockBatchIdentifier('batch-1'),
      productIdentifier: const ProductIdentifier('product-1'),
      compartmentIdentifier: const CompartmentIdentifier('shelf-1'),
      initialQuantity: const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.milliliter),
      quantityRemaining: const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.milliliter),
      storedOn: CalendarDate(2026, 10, 1),
      bestBeforeOn: bestBeforeOn,
      openedOn: openedOn,
      createdAt: DateTime.utc(2026, 10, 1),
    );

    test('only the stored-on date is required; best-before and opened-on are optional', () {
      final plain = batch();
      expect(plain.storedOn, CalendarDate(2026, 10, 1));
      expect(plain.bestBeforeOn, isNull);
      expect(plain.openedOn, isNull);
      expect(plain.isOpened, isFalse);
    });

    test('opening a batch records the day and keeps everything else', () {
      final opened = batch(
        bestBeforeOn: CalendarDate(2026, 10, 9),
      ).copyWith(openedOn: () => CalendarDate(2026, 10, 3));
      expect(opened.openedOn, CalendarDate(2026, 10, 3));
      expect(opened.isOpened, isTrue);
      expect(opened.bestBeforeOn, CalendarDate(2026, 10, 9));
      expect(opened, isNot(batch(bestBeforeOn: CalendarDate(2026, 10, 9))));
      expect(opened.copyWith(openedOn: () => null).isOpened, isFalse);
    });
  });

  group('DiscardReason', () {
    test('adds expired and spoiled, stored by name', () {
      expect(DiscardReason.fromStorageName('expired'), DiscardReason.expired);
      expect(DiscardReason.fromStorageName('spoiled'), DiscardReason.spoiled);
      expect(DiscardReason.fromStorageName('freezerBurn'), DiscardReason.freezerBurn);
    });

    test('freezer burn is only offered for frozen food', () {
      expect(
        DiscardReason.offeredFor(isFrozen: true),
        containsAll([DiscardReason.freezerBurn, DiscardReason.expired, DiscardReason.spoiled]),
      );
      expect(DiscardReason.offeredFor(isFrozen: false), isNot(contains(DiscardReason.freezerBurn)));
      expect(
        DiscardReason.offeredFor(isFrozen: false),
        containsAll([DiscardReason.tooOld, DiscardReason.expired, DiscardReason.spoiled]),
      );
    });
  });
}
