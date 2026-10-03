import 'package:core_notifications/core_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

NotificationRequest _digestRequest(int notificationIdentifier) => NotificationRequest(
  notificationIdentifier: notificationIdentifier,
  channelKind: NotificationChannelKind.storageReminders,
  title: 'Eat soon',
  body: '3 items have been in the freezer for over 6 months',
  scheduledForLocalTime: DateTime(2026, 10, 3, 18),
  tapRoutePath: '/storage_reminders/eat-soon',
);

void main() {
  test('notification requests only accept app route paths', () {
    expect(
      () => NotificationRequest(
        notificationIdentifier: 1,
        channelKind: NotificationChannelKind.storageReminders,
        title: 'title',
        body: 'body',
        scheduledForLocalTime: DateTime(2026, 10, 3, 18),
        tapRoutePath: 'https://example.org',
      ),
      throwsArgumentError,
    );
  });

  test('fake services track scheduling, cancelling and taps', () async {
    final services = FakeNotificationServices();
    final tappedRoutePaths = <String>[];
    final tapSubscription = services.tappedRoutePaths.listen(tappedRoutePaths.add);

    await services.schedule(_digestRequest(1));
    await services.schedule(_digestRequest(2));
    await services.cancel(1);
    services.simulateTap('/storage_reminders/eat-soon');
    await pumpEventQueue();

    expect(await services.pendingNotificationIdentifiers(), {2});
    expect(tappedRoutePaths, ['/storage_reminders/eat-soon']);
    expect(await services.currentStatus(), NotificationPermissionStatus.denied);
    expect(await services.requestPermission(), NotificationPermissionStatus.granted);
    await tapSubscription.cancel();
  });
}
