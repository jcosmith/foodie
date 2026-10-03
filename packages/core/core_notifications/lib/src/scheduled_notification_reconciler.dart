import 'package:core_database/core_database.dart';
import 'package:meta/meta.dart';

import 'notification_request.dart';
import 'notification_services.dart';

/// A block of notification ids reserved for one purpose, so purposes never
/// cancel each other's notifications.
@immutable
final class NotificationIdentifierRange {
  const NotificationIdentifierRange({required this.firstIdentifier, required this.length});

  final int firstIdentifier;
  final int length;

  bool contains(int notificationIdentifier) =>
      notificationIdentifier >= firstIdentifier &&
      notificationIdentifier < firstIdentifier + length;

  int identifierAt(int offset) {
    RangeError.checkValidIndex(offset, this, 'offset', length);
    return firstIdentifier + offset;
  }
}

/// Every purpose that schedules notifications, with its id range.
enum NotificationPurpose {
  storageReminderDigest(
    'storage_reminders.digest',
    NotificationIdentifierRange(firstIdentifier: 7100, length: 14),
  ),
  backupReminder(
    'data_portability.backup_reminder',
    NotificationIdentifierRange(firstIdentifier: 7200, length: 1),
  );

  const NotificationPurpose(this.recordKey, this.identifierRange);

  /// Stored with each record in `scheduled_notification_records`.
  final String recordKey;
  final NotificationIdentifierRange identifierRange;
}

/// Remembers which notifications each purpose has scheduled.
abstract interface class ScheduledNotificationRecordStore {
  Future<Set<int>> readScheduledIdentifiers(NotificationPurpose purpose);

  Future<void> replaceRecords(NotificationPurpose purpose, List<NotificationRequest> requests);
}

/// Replaces everything a purpose has scheduled with a new plan (decision D9).
///
/// Cancels the recorded ids and, in case the records are stale (for example
/// after a restore from another phone), any pending id in the purpose's range.
final class ScheduledNotificationReconciler {
  const ScheduledNotificationReconciler({
    required NotificationScheduler scheduler,
    required ScheduledNotificationRecordStore recordStore,
  }) : _scheduler = scheduler,
       _recordStore = recordStore;

  final NotificationScheduler _scheduler;
  final ScheduledNotificationRecordStore _recordStore;

  Future<void> replaceSchedule(
    NotificationPurpose purpose,
    List<NotificationRequest> plannedRequests,
  ) async {
    for (final request in plannedRequests) {
      if (!purpose.identifierRange.contains(request.notificationIdentifier)) {
        throw ArgumentError.value(
          request.notificationIdentifier,
          'plannedRequests',
          'Outside the id range of ${purpose.name}',
        );
      }
    }
    final recordedIdentifiers = await _recordStore.readScheduledIdentifiers(purpose);
    final pendingIdentifiers = await _scheduler.pendingNotificationIdentifiers();
    final identifiersToCancel = {
      ...recordedIdentifiers,
      ...pendingIdentifiers.where(purpose.identifierRange.contains),
    };
    for (final notificationIdentifier in identifiersToCancel) {
      await _scheduler.cancel(notificationIdentifier);
    }
    for (final request in plannedRequests) {
      await _scheduler.schedule(request);
    }
    await _recordStore.replaceRecords(purpose, plannedRequests);
  }
}

/// Keeps the records in the encrypted database, so they are part of backups.
final class DatabaseScheduledNotificationRecordStore implements ScheduledNotificationRecordStore {
  const DatabaseScheduledNotificationRecordStore(this._scheduledNotificationsDao);

  final ScheduledNotificationsDao _scheduledNotificationsDao;

  @override
  Future<Set<int>> readScheduledIdentifiers(NotificationPurpose purpose) async {
    final records = await _scheduledNotificationsDao.readRecords(purpose.recordKey);
    return {for (final record in records) record.notificationIdentifier};
  }

  @override
  Future<void> replaceRecords(NotificationPurpose purpose, List<NotificationRequest> requests) =>
      _scheduledNotificationsDao.replaceRecords(purpose.recordKey, [
        for (final request in requests)
          ScheduledNotificationRecordRow(
            notificationIdentifier: request.notificationIdentifier,
            purpose: purpose.recordKey,
            scheduledFor: request.scheduledForLocalTime.toUtc(),
          ),
      ]);
}
