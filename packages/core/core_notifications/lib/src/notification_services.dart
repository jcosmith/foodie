import 'notification_request.dart';

/// Schedules and cancels local notifications.
abstract interface class NotificationScheduler {
  Future<void> schedule(NotificationRequest request);

  Future<void> cancel(int notificationIdentifier);

  /// Ids of every notification that is scheduled and not yet shown.
  Future<Set<int>> pendingNotificationIdentifiers();
}

/// Asks for, and reports, the permission to show notifications.
abstract interface class NotificationPermissionService {
  Future<NotificationPermissionStatus> currentStatus();

  /// Shows the system prompt where the platform has one.
  Future<NotificationPermissionStatus> requestPermission();
}

/// Turns notification taps into app route paths.
abstract interface class NotificationTapRouter {
  /// Route paths of notifications tapped while the app is running.
  Stream<String> get tappedRoutePaths;

  /// The route path of the notification that launched the app, if any.
  Future<String?> launchRoutePath();
}
