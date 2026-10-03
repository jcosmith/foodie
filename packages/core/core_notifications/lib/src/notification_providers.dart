import 'package:core_database/core_database.dart';
import 'package:riverpod/riverpod.dart';

import 'notification_services.dart';
import 'scheduled_notification_reconciler.dart';

/// Overridden by the app shell with the [LocalNotificationsGateway] it initialised,
/// and in tests with [FakeNotificationServices].
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => throw UnimplementedError('notificationSchedulerProvider must be overridden'),
);

final notificationPermissionServiceProvider = Provider<NotificationPermissionService>(
  (ref) => throw UnimplementedError('notificationPermissionServiceProvider must be overridden'),
);

final notificationTapRouterProvider = Provider<NotificationTapRouter>(
  (ref) => throw UnimplementedError('notificationTapRouterProvider must be overridden'),
);

final scheduledNotificationReconcilerProvider = Provider<ScheduledNotificationReconciler>(
  (ref) => ScheduledNotificationReconciler(
    scheduler: ref.watch(notificationSchedulerProvider),
    recordStore: DatabaseScheduledNotificationRecordStore(
      ref.watch(applicationDatabaseProvider).scheduledNotificationsDao,
    ),
  ),
);
