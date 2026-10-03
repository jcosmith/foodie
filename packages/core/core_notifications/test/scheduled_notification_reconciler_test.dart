import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

NotificationRequest _requestWithIdentifier(int notificationIdentifier) => NotificationRequest(
  notificationIdentifier: notificationIdentifier,
  channelKind: NotificationChannelKind.storageReminders,
  title: 'Eat soon',
  body: '$notificationIdentifier',
  scheduledForLocalTime: DateTime(2026, 10, 3, 18),
  tapRoutePath: '/storage_reminders/eat-soon',
);

void main() {
  late ApplicationDatabase database;
  late FakeNotificationServices notificationServices;
  late ScheduledNotificationReconciler reconciler;
  const digestPurpose = NotificationPurpose.storageReminderDigest;

  setUp(() {
    database = createInMemoryApplicationDatabase();
    notificationServices = FakeNotificationServices();
    reconciler = ScheduledNotificationReconciler(
      scheduler: notificationServices,
      recordStore: DatabaseScheduledNotificationRecordStore(database.scheduledNotificationsDao),
    );
  });
  tearDown(() => database.close());

  test('replaces the previous plan of the same purpose only', () async {
    await notificationServices.schedule(
      NotificationRequest(
        notificationIdentifier: 7200,
        channelKind: NotificationChannelKind.backupReminders,
        title: 'Backup',
        body: 'Time for a backup',
        scheduledForLocalTime: DateTime(2026, 12, 1, 18),
        tapRoutePath: '/configuration',
      ),
    );
    await reconciler.replaceSchedule(digestPurpose, [
      _requestWithIdentifier(7100),
      _requestWithIdentifier(7101),
    ]);
    await reconciler.replaceSchedule(digestPurpose, [_requestWithIdentifier(7105)]);

    expect(notificationServices.scheduledRequests.keys, unorderedEquals([7200, 7105]));
    expect(
      await DatabaseScheduledNotificationRecordStore(
        database.scheduledNotificationsDao,
      ).readScheduledIdentifiers(digestPurpose),
      {7105},
    );
  });

  test('also cancels pending ids of its range that were never recorded', () async {
    // For example notifications left over from before a restore.
    await notificationServices.schedule(_requestWithIdentifier(7103));

    await reconciler.replaceSchedule(digestPurpose, const []);

    expect(notificationServices.scheduledRequests, isEmpty);
  });

  test('refuses ids outside the purpose range', () {
    expect(
      () => reconciler.replaceSchedule(digestPurpose, [_requestWithIdentifier(7200)]),
      throwsArgumentError,
    );
  });
}
