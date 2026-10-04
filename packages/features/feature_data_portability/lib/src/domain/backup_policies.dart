import 'data_portability_failure.dart';

/// The backup password protects the only copy of the data that leaves the
/// phone, and it cannot be recovered. It is optional (issue #12); these
/// rules apply when there is one.
abstract final class BackupPasswordPolicy {
  static const int minimumLength = 8;

  static DataPortabilityFailure? check({
    required String? password,
    required String? repeatedPassword,
  }) {
    if (password == null) return null;
    if (password.runes.length < minimumLength) return const BackupPasswordTooShort();
    if (password != repeatedPassword) return const BackupPasswordsDoNotMatch();
    return null;
  }
}

/// Because nothing is stored online, losing the phone loses the data unless
/// there is a backup; the app reminds every few months (section 11).
abstract final class BackupReminderPolicy {
  static const Duration reminderInterval = Duration(days: 90);

  /// How often the notification repeats while no backup is made.
  static const int repeatIntervalDays = 30;

  /// Local time of day of the notification, the default digest time.
  static const int notificationHour = 18;

  static bool isBackupDue({
    required DateTime? lastBackupAt,
    required DateTime now,
    required bool hasStoredFood,
  }) {
    if (!hasStoredFood) return false;
    return lastBackupAt == null || now.difference(lastBackupAt) >= reminderInterval;
  }

  /// When the backup reminder notification should appear next, in local
  /// time: 90 days after the last backup, or after the oldest food in the
  /// storage was put away if there never was one, then every 30 days until a
  /// backup is made. `null` while nothing is stored.
  static DateTime? nextNotificationAt({
    required DateTime? lastBackupAtLocal,
    required DateTime? oldestStoredAtLocal,
    required DateTime nowLocal,
  }) {
    if (oldestStoredAtLocal == null) return null;
    final countedFrom = lastBackupAtLocal ?? oldestStoredAtLocal;
    // Calendar arithmetic keeps 18:00 across daylight saving changes.
    var notificationAt = DateTime(
      countedFrom.year,
      countedFrom.month,
      countedFrom.day + reminderInterval.inDays,
      notificationHour,
    );
    while (!notificationAt.isAfter(nowLocal)) {
      notificationAt = DateTime(
        notificationAt.year,
        notificationAt.month,
        notificationAt.day + repeatIntervalDays,
        notificationHour,
      );
    }
    return notificationAt;
  }
}
