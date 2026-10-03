import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_reminders/domain.dart';
import 'package:flutter_test/flutter_test.dart';

RemindableBatch _batch(
  String identifier, {
  required CalendarDate frozenOn,
  required int storageDays,
  CalendarDate? storedSince,
}) => RemindableBatch(
  stockBatchIdentifier: StockBatchIdentifier(identifier),
  productIdentifier: ProductIdentifier('product-$identifier'),
  frozenOn: frozenOn,
  storedSince: storedSince ?? frozenOn,
  recommendedMaximumStorageDays: storageDays,
);

void main() {
  const settings = StorageReminderSettings.defaults;
  // 2 October 2026, 09:00 local time.
  final nowLocal = DateTime(2026, 10, 2, 9);
  final today = CalendarDate(2026, 10, 2);

  test('plans a digest at 18:00 on each day a batch becomes due, and only then', () {
    // 30 days of storage: "eat soon" after 26 days (85 %), used up after 30.
    final spinach = _batch('spinach', frozenOn: today.addDays(-20), storageDays: 30);

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
    final oldPeas = _batch('peas', frozenOn: today.addDays(-95), storageDays: 100);
    final berries = _batch('berries', frozenOn: today.addDays(-84), storageDays: 100);

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
      frozenOn: today.addDays(-400),
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
      frozenOn: today.addDays(-400),
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
    final spinach = _batch('spinach', frozenOn: today.addDays(-80), storageDays: 100);

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
        _batch('batch-$index', frozenOn: today.addDays(-index), storageDays: 40),
    ];

    final digests = StorageReminderPlanner.plan(
      batches: batches,
      settings: settings,
      nowLocal: nowLocal,
    );

    expect(digests, hasLength(StorageReminderPlanner.planningHorizonDays));
    expect(digests.last.dayOffset, StorageReminderPlanner.planningHorizonDays - 1);
  });
}
