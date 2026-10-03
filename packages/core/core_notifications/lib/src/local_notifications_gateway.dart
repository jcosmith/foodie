import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as time_zone_database;
import 'package:timezone/timezone.dart' as time_zone;

import 'notification_request.dart';
import 'notification_services.dart';

/// Localized texts the system shows for notification channels.
final class NotificationChannelTexts {
  const NotificationChannelTexts({
    required this.storageRemindersName,
    required this.storageRemindersDescription,
    required this.backupRemindersName,
    required this.backupRemindersDescription,
  });

  final String storageRemindersName;
  final String storageRemindersDescription;
  final String backupRemindersName;
  final String backupRemindersDescription;
}

/// The only place in the app that talks to the notification plugin.
///
/// Uses inexact scheduling, because Android 14 denies exact alarms by
/// default and a daily digest a few minutes late is fine (decision D9).
final class LocalNotificationsGateway
    implements NotificationScheduler, NotificationPermissionService, NotificationTapRouter {
  LocalNotificationsGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String> _tappedRoutePathController = StreamController.broadcast();
  NotificationChannelTexts? _channelTexts;
  bool _isInitialized = false;

  /// Loads the time zone database, detects the device zone and registers the
  /// tap handler. Permission is not requested here; onboarding asks for it
  /// with an explanation first.
  Future<void> initialize({required NotificationChannelTexts channelTexts}) async {
    _channelTexts = channelTexts;
    if (_isInitialized) return;
    time_zone_database.initializeTimeZones();
    final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    time_zone.setLocalLocation(time_zone.getLocation(deviceTimeZone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final routePath = response.payload;
        if (routePath != null) _tappedRoutePathController.add(routePath);
      },
    );
    _isInitialized = true;
  }

  /// Re-reads the device time zone; call when the app resumes, because
  /// reminders are planned in local time.
  Future<void> refreshDeviceTimeZone() async {
    final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    time_zone.setLocalLocation(time_zone.getLocation(deviceTimeZone.identifier));
  }

  @override
  Future<void> schedule(NotificationRequest request) async {
    _requireInitialized();
    final channelTexts = _channelTexts!;
    final (channelIdentifier, channelName, channelDescription) = switch (request.channelKind) {
      NotificationChannelKind.storageReminders => (
        'storage_reminders',
        channelTexts.storageRemindersName,
        channelTexts.storageRemindersDescription,
      ),
      NotificationChannelKind.backupReminders => (
        'backup_reminders',
        channelTexts.backupRemindersName,
        channelTexts.backupRemindersDescription,
      ),
    };
    await _plugin.zonedSchedule(
      id: request.notificationIdentifier,
      scheduledDate: time_zone.TZDateTime.from(request.scheduledForLocalTime, time_zone.local),
      title: request.title,
      body: request.body,
      payload: request.tapRoutePath,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelIdentifier,
          channelName,
          channelDescription: channelDescription,
          // Item names may appear in the text, so the lock screen shows only
          // a redacted version unless the device is unlocked.
          visibility: NotificationVisibility.private,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> cancel(int notificationIdentifier) {
    _requireInitialized();
    return _plugin.cancel(id: notificationIdentifier);
  }

  @override
  Future<Set<int>> pendingNotificationIdentifiers() async {
    _requireInitialized();
    final pendingRequests = await _plugin.pendingNotificationRequests();
    return pendingRequests.map((pendingRequest) => pendingRequest.id).toSet();
  }

  @override
  Future<NotificationPermissionStatus> currentStatus() async {
    final isEnabled = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled(),
      TargetPlatform.iOS =>
        (await _plugin
                .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
                ?.checkPermissions())
            ?.isEnabled,
      _ => false,
    };
    return isEnabled ?? false
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final isGranted = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission(),
      TargetPlatform.iOS =>
        await _plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true),
      _ => false,
    };
    return isGranted ?? false
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }

  @override
  Stream<String> get tappedRoutePaths => _tappedRoutePathController.stream;

  @override
  Future<String?> launchRoutePath() async {
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      return launchDetails?.notificationResponse?.payload;
    }
    return null;
  }

  void _requireInitialized() {
    if (!_isInitialized) {
      throw StateError('LocalNotificationsGateway.initialize must be called first');
    }
  }
}
