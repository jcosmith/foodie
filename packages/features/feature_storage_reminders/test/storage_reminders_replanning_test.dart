import 'package:core_notifications/core_notifications.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_reminders/feature_storage_reminders.dart';
import 'package:feature_storage_reminders/src/application/storage_reminder_settings_store.dart';
import 'package:feature_storage_reminders/src/application/storage_reminders_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/storage_reminders_test_harness.dart';

void main() {
  late StorageRemindersTestHarness harness;
  late Product mincedMeat;

  /// Freezing day that makes a batch of [product] due in [dayOffset] days.
  Future<void> addBatchDueIn(Product product, int dayOffset) async {
    final storageDays = await harness.storageDaysOf(product);
    final daysUntilEatSoon = (storageDays * 0.85).ceil();
    await harness.addBatch(product, storedOn: harness.today.addDays(dayOffset - daysUntilEatSoon));
  }

  Map<int, NotificationRequest> scheduled() => harness.notificationServices.scheduledRequests;

  setUp(() async {
    harness = StorageRemindersTestHarness();
    await harness.seedCatalogAndStoragePlace();
    await harness
        .read(preferencesStoreProvider)
        .write(ApplicationPreferenceKeys.languageCode, 'en');
    mincedMeat = await harness.productWithKey('mincedMeat');
    await const StorageRemindersFeatureModule().initializeModule(harness.initializationContext);
  });
  tearDown(() => harness.dispose());

  test('schedules a digest for the day food becomes due, without names', () async {
    await addBatchDueIn(mincedMeat, 2);

    final digest = scheduled()[7102];
    expect(digest, isNotNull);
    expect(digest!.title, 'Eat soon');
    expect(digest.body, '1 item in your freezer should be eaten soon.');
    expect(digest.scheduledForLocalTime, DateTime(2026, 10, 4, 18));
    expect(digest.tapRoutePath, StorageRemindersRoutes.eatSoon);
    expect(harness.logger.recordedEntries, isEmpty);
  });

  test('cancels the digest when the food is eaten', () async {
    await addBatchDueIn(mincedMeat, 2);
    final batch = (await harness.read(inventoryQueryServiceProvider).readActiveBatches()).single;

    await harness
        .read(consumeStockUseCaseProvider)
        .execute(stockBatchIdentifier: batch.identifier, quantity: batch.quantityRemaining);

    expect(scheduled(), isEmpty);
  });

  test('names the food when the user allows it', () async {
    final spinach = await harness.productWithKey('leafSpinach');
    await addBatchDueIn(mincedMeat, 3);
    await addBatchDueIn(spinach, 3);
    final settingsStore = harness.read(storageReminderSettingsStoreProvider);

    await settingsStore.setShowsItemNamesInNotifications(showsItemNames: true);
    await harness.read(storageReminderReplanningCoordinatorProvider).requestRecomputation();

    expect(
      scheduled()[7103]!.body,
      anyOf('Minced meat, Leaf spinach', 'Leaf spinach, Minced meat'),
    );
  });

  test('follows the digest time and the switch', () async {
    await addBatchDueIn(mincedMeat, 2);
    final settingsStore = harness.read(storageReminderSettingsStoreProvider);
    final coordinator = harness.read(storageReminderReplanningCoordinatorProvider);

    await settingsStore.setDigestTime(hour: 7, minute: 45);
    await coordinator.requestRecomputation();
    final morningTime = scheduled()[7102]!.scheduledForLocalTime;
    await settingsStore.setDailyDigestEnabled(isEnabled: false);
    await coordinator.requestRecomputation();

    expect(morningTime, DateTime(2026, 10, 4, 7, 45));
    expect(scheduled(), isEmpty);
  });

  test('replans when a category storage limit changes', () async {
    await addBatchDueIn(mincedMeat, 2);
    final storageDays = await harness.storageDaysOf(mincedMeat);

    // A longer limit moves "eat soon" out of the two-week window.
    await harness
        .read(changeCategoryStorageLimitUseCaseProvider)
        .execute(
          categoryIdentifier: mincedMeat.categoryIdentifier,
          recommendedMaximumStorageDays: storageDays * 2,
        );

    expect(scheduled(), isEmpty);
  });

  test('settings are stored as preferences with the documented defaults', () async {
    final settings = await StorageReminderSettingsStore(
      harness.read(preferencesStoreProvider),
    ).read();

    expect(settings, StorageReminderSettings.defaults);
    expect(settings.digestHour, 18);
  });
}
