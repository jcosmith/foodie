import 'package:core_notifications/core_notifications.dart';

/// Used when the notification plugin failed to initialise: the app keeps
/// working, reminders are simply not shown.
final class UnavailableNotificationServices
    implements NotificationScheduler, NotificationPermissionService, NotificationTapRouter {
  const UnavailableNotificationServices();

  @override
  Future<void> schedule(NotificationRequest request) async {}

  @override
  Future<void> cancel(int notificationIdentifier) async {}

  @override
  Future<Set<int>> pendingNotificationIdentifiers() async => const {};

  @override
  Future<NotificationPermissionStatus> currentStatus() async => NotificationPermissionStatus.denied;

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.denied;

  @override
  Stream<String> get tappedRoutePaths => const Stream.empty();

  @override
  Future<String?> launchRoutePath() async => null;
}
