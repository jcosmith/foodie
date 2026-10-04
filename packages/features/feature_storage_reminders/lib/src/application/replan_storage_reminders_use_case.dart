import 'package:core_foundation/core_foundation.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';

import '../domain/remindable_batch.dart';
import '../domain/storage_reminder_planner.dart';
import '../storage_reminders_routes.dart';
import 'storage_reminder_notification_texts.dart';
import 'storage_reminder_settings_store.dart';

/// Recomputes the digest notifications from the database and replaces the
/// scheduled ones. Idempotent, so it can run after every change and at start.
final class ReplanStorageRemindersUseCase {
  const ReplanStorageRemindersUseCase({
    required InventoryQueryService inventory,
    required ProductCatalogQueryService productCatalog,
    required StorageReminderSettingsStore settingsStore,
    required ScheduledNotificationReconciler reconciler,
    required Future<StorageReminderNotificationTexts> Function() loadNotificationTexts,
    required Clock clock,
  }) : _inventory = inventory,
       _productCatalog = productCatalog,
       _settingsStore = settingsStore,
       _reconciler = reconciler,
       _loadNotificationTexts = loadNotificationTexts,
       _clock = clock;

  /// How many product names a digest shows before "and 2 more".
  static const int namedProductLimit = 3;

  final InventoryQueryService _inventory;
  final ProductCatalogQueryService _productCatalog;
  final StorageReminderSettingsStore _settingsStore;
  final ScheduledNotificationReconciler _reconciler;
  final Future<StorageReminderNotificationTexts> Function() _loadNotificationTexts;
  final Clock _clock;

  Future<void> execute() async {
    final settings = await _settingsStore.read();
    final activeBatches = await _inventory.readActiveBatches();
    final catalog = await _productCatalog.readCatalog();
    final remindableBatches = [
      for (final batch in activeBatches)
        if (catalog.productOf(batch.productIdentifier) case final product?)
          if (UseByPolicy.deadlineOfBatch(
                batch,
                shelfLifeDays: catalog.recommendedMaximumStorageDaysOf(product),
                shelfLifeAfterOpeningDays: catalog.shelfLifeAfterOpeningDaysOf(product),
              )
              case final deadline?)
            RemindableBatch(
              stockBatchIdentifier: batch.identifier,
              productIdentifier: batch.productIdentifier,
              storedSince: CalendarDate.fromDateTime(batch.createdAt.toLocal()),
              deadline: deadline,
            ),
    ];
    final plannedDigests = StorageReminderPlanner.plan(
      batches: remindableBatches,
      settings: settings,
      nowLocal: _clock.nowLocal(),
    );

    final requests = <NotificationRequest>[];
    if (plannedDigests.isNotEmpty) {
      final texts = await _loadNotificationTexts();
      final productNames = ProductDisplayNameResolver(texts.catalogNames);
      for (final digest in plannedDigests) {
        final itemCount = digest.batchesToEatSoon.length;
        final String body;
        if (settings.showsItemNamesInNotifications) {
          final productNameOfEachBatch = [
            for (final batch in digest.batchesToEatSoon)
              if (catalog.productOf(batch.productIdentifier) case final product?)
                productNames.productName(product),
          ];
          final namedProducts = productNameOfEachBatch.toSet().take(namedProductLimit).toList();
          body = texts.digestBodyWithNames(
            namedProducts,
            productNameOfEachBatch.where((name) => !namedProducts.contains(name)).length,
          );
        } else {
          body = texts.digestBodyWithCount(itemCount);
        }
        requests.add(
          NotificationRequest(
            notificationIdentifier: NotificationPurpose.storageReminderDigest.identifierRange
                .identifierAt(digest.dayOffset),
            channelKind: NotificationChannelKind.storageReminders,
            title: texts.digestTitle(itemCount),
            body: body,
            scheduledForLocalTime: digest.scheduledForLocalTime,
            tapRoutePath: StorageRemindersRoutes.eatSoon,
          ),
        );
      }
    }
    await _reconciler.replaceSchedule(NotificationPurpose.storageReminderDigest, requests);
  }
}
