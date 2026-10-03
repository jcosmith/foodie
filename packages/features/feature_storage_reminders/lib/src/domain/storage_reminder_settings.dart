import 'package:meta/meta.dart';

/// How and when the daily digest reminds the user (Config, "Reminders").
@immutable
final class StorageReminderSettings {
  const StorageReminderSettings({
    required this.isDailyDigestEnabled,
    required this.digestMinuteOfDay,
    required this.showsItemNamesInNotifications,
  });

  /// 18:00, as in the UI examples ("Daily at 18:00").
  static const int defaultDigestMinuteOfDay = 18 * 60;

  static const StorageReminderSettings defaults = StorageReminderSettings(
    isDailyDigestEnabled: true,
    digestMinuteOfDay: defaultDigestMinuteOfDay,
    showsItemNamesInNotifications: false,
  );

  final bool isDailyDigestEnabled;

  /// Local time of the digest, in minutes after midnight.
  final int digestMinuteOfDay;

  /// Off by default: notifications can show on the lock screen, so the
  /// digest only says how many items are due (architecture section 11).
  final bool showsItemNamesInNotifications;

  int get digestHour => digestMinuteOfDay ~/ 60;

  int get digestMinute => digestMinuteOfDay % 60;

  @override
  bool operator ==(Object other) =>
      other is StorageReminderSettings &&
      other.isDailyDigestEnabled == isDailyDigestEnabled &&
      other.digestMinuteOfDay == digestMinuteOfDay &&
      other.showsItemNamesInNotifications == showsItemNamesInNotifications;

  @override
  int get hashCode =>
      Object.hash(isDailyDigestEnabled, digestMinuteOfDay, showsItemNamesInNotifications);
}
