import 'package:drift/drift.dart';

/// Which local notifications are currently scheduled, so replanning can
/// cancel exactly those (decision D9). Each module owns the rows of its own
/// [purpose].
@DataClassName('ScheduledNotificationRecordRow')
class ScheduledNotificationRecords extends Table {
  IntColumn get notificationIdentifier => integer()();

  /// Who scheduled it, for example `storage_reminders.digest`.
  TextColumn get purpose => text()();

  /// Local wall-clock time the notification was scheduled for, stored as UTC.
  DateTimeColumn get scheduledFor => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {notificationIdentifier};
}
