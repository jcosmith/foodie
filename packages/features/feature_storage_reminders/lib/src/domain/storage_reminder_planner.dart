import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'remindable_batch.dart';
import 'storage_reminder_settings.dart';

/// One digest notification: on [day], at the digest time.
@immutable
final class PlannedStorageDigest {
  const PlannedStorageDigest({
    required this.dayOffset,
    required this.day,
    required this.scheduledForLocalTime,
    required this.batchesToEatSoon,
    required this.newlyDueCount,
  });

  /// Days after today; also picks the notification id.
  final int dayOffset;
  final CalendarDate day;
  final DateTime scheduledForLocalTime;

  /// Everything that should be eaten soon on [day]: the batches that became
  /// due that day first, then the rest, most overdue first.
  final List<RemindableBatch> batchesToEatSoon;

  /// How many of [batchesToEatSoon] became due on [day].
  final int newlyDueCount;
}

/// Plans the rolling daily digest (decision D9).
///
/// A digest is planned for each of the next [planningHorizonDays] days on
/// which at least one batch becomes due: it reaches "eat soon" (the urgent
/// badge) or uses up its storage time. Days on which nothing changes stay
/// quiet, so the user is not reminded of the same food every evening. The
/// plan is recomputed whenever the inventory, the catalog or the settings
/// change and at every start, so it always reaches 14 days ahead of the last
/// time the app was used.
abstract final class StorageReminderPlanner {
  static const int planningHorizonDays = 14;

  static List<PlannedStorageDigest> plan({
    required List<RemindableBatch> batches,
    required StorageReminderSettings settings,
    required DateTime nowLocal,
  }) {
    if (!settings.isDailyDigestEnabled || batches.isEmpty) return const [];
    final today = CalendarDate.fromDateTime(nowLocal);
    final plannedDigests = <PlannedStorageDigest>[];
    for (var dayOffset = 0; dayOffset < planningHorizonDays; dayOffset++) {
      final day = today.addDays(dayOffset);
      final scheduledForLocalTime = DateTime(
        day.year,
        day.month,
        day.day,
        settings.digestHour,
        settings.digestMinute,
      );
      if (!scheduledForLocalTime.isAfter(nowLocal)) continue;

      bool becomesDueOn(RemindableBatch batch) =>
          batch.eatSoonFrom == day || batch.storageLimitReachedOn == day;
      final newlyDueBatches = batches.where(becomesDueOn).toList();
      if (newlyDueBatches.isEmpty) continue;
      final otherDueBatches =
          batches.where((batch) => batch.isEatSoonOn(day) && !becomesDueOn(batch)).toList()..sort(
            (first, second) => second.storageShareOn(day).compareTo(first.storageShareOn(day)),
          );
      plannedDigests.add(
        PlannedStorageDigest(
          dayOffset: dayOffset,
          day: day,
          scheduledForLocalTime: scheduledForLocalTime,
          batchesToEatSoon: [...newlyDueBatches, ...otherDueBatches],
          newlyDueCount: newlyDueBatches.length,
        ),
      );
    }
    return plannedDigests;
  }
}
