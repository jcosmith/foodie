import 'dart:async';

import 'notification_request.dart';
import 'notification_services.dart';

/// Records scheduled notifications in memory; for tests and widget previews.
final class FakeNotificationServices
    implements NotificationScheduler, NotificationPermissionService, NotificationTapRouter {
  FakeNotificationServices({
    this.permissionStatusAfterRequest = NotificationPermissionStatus.granted,
  });

  final NotificationPermissionStatus permissionStatusAfterRequest;
  final Map<int, NotificationRequest> scheduledRequests = {};
  final StreamController<String> _tappedRoutePathController = StreamController.broadcast();
  NotificationPermissionStatus _permissionStatus = NotificationPermissionStatus.denied;
  String? launchRoutePathForTest;

  @override
  Future<void> schedule(NotificationRequest request) async {
    scheduledRequests[request.notificationIdentifier] = request;
  }

  @override
  Future<void> cancel(int notificationIdentifier) async {
    scheduledRequests.remove(notificationIdentifier);
  }

  @override
  Future<Set<int>> pendingNotificationIdentifiers() async => scheduledRequests.keys.toSet();

  @override
  Future<NotificationPermissionStatus> currentStatus() async => _permissionStatus;

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      _permissionStatus = permissionStatusAfterRequest;

  @override
  Stream<String> get tappedRoutePaths => _tappedRoutePathController.stream;

  @override
  Future<String?> launchRoutePath() async => launchRoutePathForTest;

  /// Simulates the user tapping a delivered notification.
  void simulateTap(String routePath) => _tappedRoutePathController.add(routePath);
}
