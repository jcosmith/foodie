import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:feature_inventory/src/domain/removal_amount_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemovalAmountPolicy', () {
    Quantity grams(int amount) => Quantity(amountInBaseUnits: amount, unit: QuantityUnit.gram);
    Quantity pieces(int thousandths) =>
        Quantity(amountInBaseUnits: thousandths, unit: QuantityUnit.piece);

    test('steps are 50 g or half a piece', () {
      expect(RemovalAmountPolicy.stepFor(QuantityUnit.gram), grams(50));
      expect(RemovalAmountPolicy.stepFor(QuantityUnit.piece), pieces(500));
    });

    test('fractions round to the step and stay within what is left', () {
      expect(RemovalAmountPolicy.fractionOf(grams(500), 0.5), grams(250));
      expect(RemovalAmountPolicy.fractionOf(grams(500), 0.25), grams(150));
      expect(RemovalAmountPolicy.fractionOf(grams(500), 0.01), grams(50));
      expect(RemovalAmountPolicy.fractionOf(grams(430), 1), grams(430));
      expect(RemovalAmountPolicy.fractionOf(pieces(3000), 0.5), pieces(1500));
    });

    test('a bag holding one step or less is taken whole', () {
      expect(RemovalAmountPolicy.suggestedAmount(grams(40)), grams(40));
      expect(RemovalAmountPolicy.snap(grams(40), 10), grams(40));
    });

    test('the suggestion is about a fifth', () {
      expect(RemovalAmountPolicy.suggestedAmount(grams(1000)), grams(200));
    });

    test('slider positions snap to the grid', () {
      expect(RemovalAmountPolicy.snap(grams(500), 130), grams(150));
      expect(RemovalAmountPolicy.snap(grams(500), 0), grams(50));
      expect(RemovalAmountPolicy.snap(grams(480), 470), grams(450));
      expect(RemovalAmountPolicy.snap(grams(480), 500), grams(480));
    });
  });

  group('StorageAgePolicy', () {
    test('finds the first day of each status', () {
      final storedOn = CalendarDate(2026, 1, 1);
      for (final storageDays in [1, 7, 30, 90, 180, 365]) {
        for (final status in StorageAgeStatus.values) {
          final firstDay = StorageAgePolicy.firstDayWithStatus(
            storedOn: storedOn,
            recommendedMaximumStorageDays: storageDays,
            status: status,
          );
          StorageAgeStatus statusOn(CalendarDate day) => StorageAgePolicy.evaluate(
            storedOn: storedOn,
            today: day,
            recommendedMaximumStorageDays: storageDays,
          );
          expect(statusOn(firstDay).index, greaterThanOrEqualTo(status.index));
          if (firstDay != storedOn) {
            expect(statusOn(firstDay.addDays(-1)).index, lessThan(status.index));
          }
        }
      }
      expect(
        StorageAgePolicy.firstDayWithStatus(
          storedOn: storedOn,
          recommendedMaximumStorageDays: 100,
          status: StorageAgeStatus.urgent,
        ),
        CalendarDate(2026, 3, 27),
      );
    });

    final today = CalendarDate(2026, 10, 2);

    StorageAgeStatus statusAfter(int storedDays) => StorageAgePolicy.evaluate(
      storedOn: today.addDays(-storedDays),
      today: today,
      recommendedMaximumStorageDays: 100,
    );

    test('fresh until 60 %, aging until 85 %, urgent until 100 %, then overdue', () {
      expect(statusAfter(0), StorageAgeStatus.fresh);
      expect(statusAfter(59), StorageAgeStatus.fresh);
      expect(statusAfter(60), StorageAgeStatus.aging);
      expect(statusAfter(84), StorageAgeStatus.aging);
      expect(statusAfter(85), StorageAgeStatus.urgent);
      expect(statusAfter(99), StorageAgeStatus.urgent);
      expect(statusAfter(100), StorageAgeStatus.overdue);
      expect(statusAfter(400), StorageAgeStatus.overdue);
    });

    test('a batch is overdue from the day its storage time is used up', () {
      final storedOn = CalendarDate(2026, 1, 1);
      expect(
        StorageAgePolicy.firstDayWithStatus(
          storedOn: storedOn,
          recommendedMaximumStorageDays: 90,
          status: StorageAgeStatus.overdue,
        ),
        StorageAgePolicy.storageLimitReachedOn(
          storedOn: storedOn,
          recommendedMaximumStorageDays: 90,
        ),
      );
    });

    test('without a recommendation everything stays fresh', () {
      expect(
        StorageAgePolicy.evaluate(
          storedOn: today.addDays(-1000),
          today: today,
          recommendedMaximumStorageDays: 0,
        ),
        StorageAgeStatus.fresh,
      );
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
      final opened = batch(bestBeforeOn: CalendarDate(2026, 10, 9)).copyWith(
        openedOn: () => CalendarDate(2026, 10, 3),
      );
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
