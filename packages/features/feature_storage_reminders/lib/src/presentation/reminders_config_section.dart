import 'package:core_notifications/core_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_reminders_providers.dart';
import '../domain/storage_reminder_settings.dart';
import '../l10n/generated/storage_reminders_localizations.dart';
import '../storage_reminders_routes.dart';

/// Whether the system lets the app show notifications; refreshed after asking.
final notificationPermissionStatusProvider = FutureProvider<NotificationPermissionStatus>(
  (ref) => ref.watch(notificationPermissionServiceProvider).currentStatus(),
);

/// The "Reminders" section of the Config tab: digest on or off, its time,
/// lock-screen privacy and the storage limits per category.
class RemindersConfigSection extends ConsumerWidget {
  const RemindersConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = StorageRemindersLocalizations.of(context);
    final settings = ref.watch(storageReminderSettingsProvider).value;
    final permissionStatus = ref.watch(notificationPermissionStatusProvider).value;
    if (settings == null) return const SizedBox(height: 48);
    final settingsStore = ref.read(storageReminderSettingsStoreProvider);
    final digestTime = TimeOfDay(hour: settings.digestHour, minute: settings.digestMinute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (settings.isDailyDigestEnabled &&
            permissionStatus == NotificationPermissionStatus.denied)
          _NotificationsOffNotice(
            onAllowPressed: () async {
              await ref.read(notificationPermissionServiceProvider).requestPermission();
              ref.invalidate(notificationPermissionStatusProvider);
            },
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(localizations.dailyDigestSwitch),
          subtitle: Text(localizations.dailyDigestDetail),
          value: settings.isDailyDigestEnabled,
          onChanged: (isEnabled) => settingsStore.setDailyDigestEnabled(isEnabled: isEnabled),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: settings.isDailyDigestEnabled,
          title: Text(localizations.digestTimeLabel),
          trailing: Text(
            MaterialLocalizations.of(context).formatTimeOfDay(
              digestTime,
              alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: () => _chooseDigestTime(context, ref, settings),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(localizations.showNamesSwitch),
          subtitle: Text(localizations.showNamesDetail),
          value: settings.showsItemNamesInNotifications,
          onChanged: settings.isDailyDigestEnabled
              ? (showsItemNames) =>
                    settingsStore.setShowsItemNamesInNotifications(showsItemNames: showsItemNames)
              : null,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(localizations.storageLimitsRow),
          subtitle: Text(localizations.storageLimitsDetail),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(StorageRemindersRoutes.storageLimits),
        ),
      ],
    );
  }

  Future<void> _chooseDigestTime(
    BuildContext context,
    WidgetRef ref,
    StorageReminderSettings settings,
  ) async {
    final chosenTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.digestHour, minute: settings.digestMinute),
    );
    if (chosenTime == null) return;
    await ref
        .read(storageReminderSettingsStoreProvider)
        .setDigestTime(hour: chosenTime.hour, minute: chosenTime.minute);
  }
}

class _NotificationsOffNotice extends StatelessWidget {
  const _NotificationsOffNotice({required this.onAllowPressed});

  final VoidCallback onAllowPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = StorageRemindersLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.errorContainer,
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(Icons.notifications_off_outlined, color: colorScheme.onErrorContainer),
        title: Text(
          localizations.notificationsOffMessage,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
        trailing: TextButton(
          onPressed: onAllowPressed,
          child: Text(localizations.allowNotificationsButton),
        ),
      ),
    );
  }
}
