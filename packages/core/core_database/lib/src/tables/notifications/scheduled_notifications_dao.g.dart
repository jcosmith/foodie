// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_notifications_dao.dart';

// ignore_for_file: type=lint
mixin _$ScheduledNotificationsDaoMixin
    on DatabaseAccessor<ApplicationDatabase> {
  $ScheduledNotificationRecordsTable get scheduledNotificationRecords =>
      attachedDatabase.scheduledNotificationRecords;
  ScheduledNotificationsDaoManager get managers =>
      ScheduledNotificationsDaoManager(this);
}

class ScheduledNotificationsDaoManager {
  final _$ScheduledNotificationsDaoMixin _db;
  ScheduledNotificationsDaoManager(this._db);
  $$ScheduledNotificationRecordsTableTableManager
  get scheduledNotificationRecords =>
      $$ScheduledNotificationRecordsTableTableManager(
        _db.attachedDatabase,
        _db.scheduledNotificationRecords,
      );
}
