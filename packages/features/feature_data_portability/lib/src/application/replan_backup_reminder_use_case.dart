import 'package:core_foundation/core_foundation.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/widgets.dart';

import '../data_portability_routes.dart';
import '../domain/backup_policies.dart';
import '../l10n/generated/data_portability_localizations.dart';
import 'data_portability_providers.dart';

/// Schedules the one backup reminder notification, or none while nothing
/// is stored. Idempotent, so it runs at start and after every change.
final class ReplanBackupReminderUseCase {
  const ReplanBackupReminderUseCase({
    required InventoryQueryService inventory,
    required PreferencesStore preferencesStore,
    required ScheduledNotificationReconciler reconciler,
    required Future<Locale> Function() readApplicationLocale,
    required Clock clock,
  }) : _inventory = inventory,
       _preferencesStore = preferencesStore,
       _reconciler = reconciler,
       _readApplicationLocale = readApplicationLocale,
       _clock = clock;

  final InventoryQueryService _inventory;
  final PreferencesStore _preferencesStore;
  final ScheduledNotificationReconciler _reconciler;
  final Future<Locale> Function() _readApplicationLocale;
  final Clock _clock;

  Future<void> execute() async {
    final lastBackupAt = await _preferencesStore.read(DataPortabilityPreferenceKeys.lastBackupAt);
    final activeBatches = await _inventory.readActiveBatches();
    final oldestStoredAt = activeBatches.isEmpty
        ? null
        : activeBatches
              .map((batch) => batch.createdAt)
              .reduce((first, second) => first.isBefore(second) ? first : second);
    final notificationAt = BackupReminderPolicy.nextNotificationAt(
      lastBackupAtLocal: lastBackupAt?.toLocal(),
      oldestStoredAtLocal: oldestStoredAt?.toLocal(),
      nowLocal: _clock.nowLocal(),
    );

    final requests = <NotificationRequest>[];
    if (notificationAt != null) {
      final localizations = lookupDataPortabilityLocalizations(await _readApplicationLocale());
      requests.add(
        NotificationRequest(
          notificationIdentifier: NotificationPurpose.backupReminder.identifierRange.identifierAt(
            0,
          ),
          channelKind: NotificationChannelKind.backupReminders,
          title: localizations.backupNotificationTitle,
          body: localizations.backupNotificationBody,
          scheduledForLocalTime: notificationAt,
          tapRoutePath: DataPortabilityRoutes.backup,
        ),
      );
    }
    await _reconciler.replaceSchedule(NotificationPurpose.backupReminder, requests);
  }
}
