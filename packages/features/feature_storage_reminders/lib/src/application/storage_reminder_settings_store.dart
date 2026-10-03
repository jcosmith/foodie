import 'package:core_preferences/core_preferences.dart';

import '../domain/storage_reminder_settings.dart';

abstract final class StorageReminderPreferenceKeys {
  static const String _namespace = 'storage_reminders';

  static final PreferenceKey<bool> isDailyDigestEnabled = PreferenceKey.boolean(
    moduleNamespace: _namespace,
    name: 'is_daily_digest_enabled',
    defaultValue: StorageReminderSettings.defaults.isDailyDigestEnabled,
  );

  static final PreferenceKey<int> digestMinuteOfDay = PreferenceKey.integer(
    moduleNamespace: _namespace,
    name: 'digest_minute_of_day',
    defaultValue: StorageReminderSettings.defaultDigestMinuteOfDay,
  );

  static final PreferenceKey<bool> showsItemNamesInNotifications = PreferenceKey.boolean(
    moduleNamespace: _namespace,
    name: 'shows_item_names_in_notifications',
    defaultValue: StorageReminderSettings.defaults.showsItemNamesInNotifications,
  );
}

/// Reads and changes the reminder settings, which live in the encrypted
/// database like every preference.
final class StorageReminderSettingsStore {
  const StorageReminderSettingsStore(this._preferencesStore);

  final PreferencesStore _preferencesStore;

  Future<StorageReminderSettings> read() async => StorageReminderSettings(
    isDailyDigestEnabled: await _preferencesStore.read(
      StorageReminderPreferenceKeys.isDailyDigestEnabled,
    ),
    digestMinuteOfDay: await _preferencesStore.read(
      StorageReminderPreferenceKeys.digestMinuteOfDay,
    ),
    showsItemNamesInNotifications: await _preferencesStore.read(
      StorageReminderPreferenceKeys.showsItemNamesInNotifications,
    ),
  );

  /// Emits the current settings, then every change.
  Stream<StorageReminderSettings> watch() => Stream.multi((controller) {
    final subscriptions = [
      for (final changes in [
        _preferencesStore.watch(StorageReminderPreferenceKeys.isDailyDigestEnabled),
        _preferencesStore.watch(StorageReminderPreferenceKeys.digestMinuteOfDay),
        _preferencesStore.watch(StorageReminderPreferenceKeys.showsItemNamesInNotifications),
      ])
        changes.listen((_) async {
          final settings = await read();
          if (!controller.isClosed) controller.add(settings);
        }, onError: controller.addError),
    ];
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
  });

  Future<void> setDailyDigestEnabled({required bool isEnabled}) =>
      _preferencesStore.write(StorageReminderPreferenceKeys.isDailyDigestEnabled, isEnabled);

  Future<void> setDigestTime({required int hour, required int minute}) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Not a time of day: $hour:$minute');
    }
    return _preferencesStore.write(
      StorageReminderPreferenceKeys.digestMinuteOfDay,
      hour * 60 + minute,
    );
  }

  Future<void> setShowsItemNamesInNotifications({required bool showsItemNames}) => _preferencesStore
      .write(StorageReminderPreferenceKeys.showsItemNamesInNotifications, showsItemNames);
}
