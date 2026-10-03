import 'package:meta/meta.dart';

/// Which notification channel a request belongs to. Android shows channels
/// in the system settings so users can mute them separately.
enum NotificationChannelKind { storageReminders, backupReminders }

/// A local notification to show at a given local time.
@immutable
final class NotificationRequest {
  NotificationRequest({
    required this.notificationIdentifier,
    required this.channelKind,
    required this.title,
    required this.body,
    required this.scheduledForLocalTime,
    required this.tapRoutePath,
  }) {
    if (!tapRoutePath.startsWith('/')) {
      throw ArgumentError.value(tapRoutePath, 'tapRoutePath', 'Must be an app route path');
    }
  }

  /// Stable id chosen by the caller, so it can cancel exactly this notification.
  final int notificationIdentifier;
  final NotificationChannelKind channelKind;
  final String title;
  final String body;

  /// When to show it, in the device's local time zone. Scheduling is inexact:
  /// the system may deliver it a few minutes late (decision D9).
  final DateTime scheduledForLocalTime;

  /// The app route that opens when the notification is tapped.
  final String tapRoutePath;
}

/// Whether the app may show notifications.
enum NotificationPermissionStatus { granted, denied }
