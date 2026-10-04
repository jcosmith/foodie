import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_reminders/domain.dart';
import 'package:flutter_test/flutter_test.dart';

RemindableBatch _batch(
  String identifier, {
  required CalendarDate storedOn,
  int? storageDays,
  CalendarDate? bestBeforeOn,
  CalendarDate? storedSince,
}) => RemindableBatch(
  stockBatchIdentifier: StockBatchIdentifier(identifier),
  productIdentifier: ProductIdentifier('product-$identifier'),
  storedSince: storedSince ?? storedOn,
  deadline: UseByPolicy.deadlineOf(
    storedOn: storedOn,
    shelfLifeDays: storageDays,
    bestBeforeOn: bestBeforeOn,
  )!,
);

void main() {
  const settings = StorageReminderSettings.defaults;
  // 2 October 2026, 09:00 local time.
  final nowLocal = DateTime(2026, 10, 2, 9);
  final today = CalendarDate(2026, 10, 2);

  test('plans a digest at 18:00 on each day a batch becomes due, and only then', () {
    // 30 days of storage: "eat soon" after 26 days (85 %), used up after 30.
    final spinach = _batch('spinach', storedOn: today.addDays(-20), storageDays: 30);

    final digests = StorageReminderPlanner.plan(
      batches: [spinach],
      settings: settings,
      nowLocal: nowLocal,
    );

    expect([for (final digest in digests) digest.dayOffset], [6, 10]);
    expect(digests.first.scheduledForLocalTime, DateTime(2026, 10, 8, 18));
    expect(digests.first.batchesToEatSoon, [spinach]);
    expect(digests.last.day, today.addDays(10));
  });

  test('a digest also counts food that was already due, newly due first', () {
    final oldPeas = _batch('peas', storedOn: today.addDays(-95), storageDays: 100);
    final berries = _batch('berries', storedOn: today.addDays(-84), storageDays: 100);

    final firstDigest = StorageReminderPlanner.plan(
      batches: [oldPeas, berries],
      settings: settings,
      nowLocal: nowLocal,
    ).first;

    expect(firstDigest.dayOffset, 1);
    expect(firstDigest.batchesToEatSoon, [berries, oldPeas]);
    expect(firstDigest.newlyDueCount, 1);
  });

  test('food entered when it is already old is due on the day it was entered', () {
    final foundInTheBack = _batch(
      'found',
      storedOn: today.addDays(-400),
      storageDays: 180,
      storedSince: today,
    );

    final digests = StorageReminderPlanner.plan(
      batches: [foundInTheBack],
      settings: settings,
      nowLocal: nowLocal,
    );

    expect([for (final digest in digests) digest.dayOffset], [0]);
  });

  test('skips today once the digest time has passed', () {
    final foundInTheBack = _batch(
      'found',
      storedOn: today.addDays(-400),
      storageDays: 180,
      storedSince: today,
    );

    final digests = StorageReminderPlanner.plan(
      batches: [foundInTheBack],
      settings: settings,
      nowLocal: DateTime(2026, 10, 2, 18, 30),
    );

    expect(digests, isEmpty);
  });

  test('follows the chosen time and plans nothing when switched off', () {
    final spinach = _batch('spinach', storedOn: today.addDays(-80), storageDays: 100);

    final morningDigests = StorageReminderPlanner.plan(
      batches: [spinach],
      settings: const StorageReminderSettings(
        isDailyDigestEnabled: true,
        digestMinuteOfDay: 7 * 60 + 30,
        showsItemNamesInNotifications: false,
      ),
      nowLocal: nowLocal,
    );
    final switchedOff = StorageReminderPlanner.plan(
      batches: [spinach],
      settings: const StorageReminderSettings(
        isDailyDigestEnabled: false,
        digestMinuteOfDay: StorageReminderSettings.defaultDigestMinuteOfDay,
        showsItemNamesInNotifications: false,
      ),
      nowLocal: nowLocal,
    );

    expect(morningDigests.first.scheduledForLocalTime, DateTime(2026, 10, 7, 7, 30));
    expect(switchedOff, isEmpty);
  });

  test('never plans beyond the 14-day horizon', () {
    final batches = [
      for (var index = 0; index < 60; index++)
        _batch('batch-$index', storedOn: today.addDays(-index), storageDays: 40),
    ];

    final digests = StorageReminderPlanner.plan(
      batches: batches,
      settings: settings,
      nowLocal: nowLocal,
    );

    expect(digests, hasLength(StorageReminderPlanner.planningHorizonDays));
    expect(digests.last.dayOffset, StorageReminderPlanner.planningHorizonDays - 1);
  });

  test('food that keeps one day is in tonight\'s digest; best before tomorrow is tomorrow\'s', () {
    final rolls = _batch('rolls', storedOn: today, storageDays: 1);
    final yoghurt = _batch(
      'yoghurt',
      storedOn: today.addDays(-3),
      storageDays: 300,
      bestBeforeOn: today.addDays(1),
    );

    final digests = StorageReminderPlanner.plan(
      batches: [rolls, yoghurt],
      settings: settings,
      nowLocal: nowLocal,
    );

    expect(digests.first.dayOffset, 0);
    expect(digests.first.batchesToEatSoon, [rolls]);
    expect(digests[1].dayOffset, 1);
    expect(digests[1].batchesToEatSoon, [rolls, yoghurt], reason: 'the rolls are past their day');
    expect(digests[1].newlyDueCount, 2);
  });
}
