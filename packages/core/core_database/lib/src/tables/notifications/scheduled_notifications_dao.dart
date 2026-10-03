import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'scheduled_notification_records_table.dart';

part 'scheduled_notifications_dao.g.dart';

/// Remembers which notifications a module has scheduled.
@DriftAccessor(tables: [ScheduledNotificationRecords])
class ScheduledNotificationsDao extends DatabaseAccessor<ApplicationDatabase>
    with _$ScheduledNotificationsDaoMixin {
  ScheduledNotificationsDao(super.attachedDatabase);

  Future<List<ScheduledNotificationRecordRow>> readRecords(String purpose) => (select(
    scheduledNotificationRecords,
  )..where((record) => record.purpose.equals(purpose))).get();

  /// Replaces every record of [purpose] with [records] in one transaction.
  Future<void> replaceRecords(String purpose, List<ScheduledNotificationRecordRow> records) =>
      transaction(() async {
        await (delete(
          scheduledNotificationRecords,
        )..where((record) => record.purpose.equals(purpose))).go();
        await batch(
          (batch) => batch.insertAllOnConflictUpdate(scheduledNotificationRecords, records),
        );
      });
}
