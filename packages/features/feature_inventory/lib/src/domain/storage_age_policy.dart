import 'package:core_foundation/core_foundation.dart';

/// How urgently a batch should be used; [overdue] once its recommended
/// maximum storage time is used up.
enum StorageAgeStatus { fresh, aging, urgent, overdue }

/// Compares a batch's storage age with its recommended maximum storage time
/// (product or category). Past 60 % it should be used soon, past 85 % now,
/// and from 100 % on it is overdue.
abstract final class StorageAgePolicy {
  static const double agingShare = 0.6;
  static const double urgentShare = 0.85;
  static const double overdueShare = 1;

  static double storageShare({
    required CalendarDate storedOn,
    required CalendarDate today,
    required int recommendedMaximumStorageDays,
  }) {
    if (recommendedMaximumStorageDays <= 0) return 0;
    final storedDays = storedOn.daysUntil(today);
    return storedDays <= 0 ? 0 : storedDays / recommendedMaximumStorageDays;
  }

  static StorageAgeStatus evaluate({
    required CalendarDate storedOn,
    required CalendarDate today,
    required int recommendedMaximumStorageDays,
  }) {
    final share = storageShare(
      storedOn: storedOn,
      today: today,
      recommendedMaximumStorageDays: recommendedMaximumStorageDays,
    );
    if (share >= overdueShare) return StorageAgeStatus.overdue;
    if (share >= urgentShare) return StorageAgeStatus.urgent;
    if (share >= agingShare) return StorageAgeStatus.aging;
    return StorageAgeStatus.fresh;
  }

  /// The first day on which a batch stored on [frozenOn] is at least
  /// [status]; for [StorageAgeStatus.fresh] that is the freezing day.
  static CalendarDate firstDayWithStatus({
    required CalendarDate storedOn,
    required int recommendedMaximumStorageDays,
    required StorageAgeStatus status,
  }) {
    if (recommendedMaximumStorageDays <= 0) {
      throw ArgumentError.value(
        recommendedMaximumStorageDays,
        'recommendedMaximumStorageDays',
        'Must be positive',
      );
    }
    final share = switch (status) {
      StorageAgeStatus.fresh => 0.0,
      StorageAgeStatus.aging => agingShare,
      StorageAgeStatus.urgent => urgentShare,
      StorageAgeStatus.overdue => overdueShare,
    };
    bool reachesStatusAfter(int storedDays) =>
        evaluate(
          storedOn: storedOn,
          today: storedOn.addDays(storedDays),
          recommendedMaximumStorageDays: recommendedMaximumStorageDays,
        ).index >=
        status.index;

    // Start from the arithmetic answer and correct floating point rounding.
    var storedDays = (share * recommendedMaximumStorageDays).ceil();
    while (storedDays > 0 && reachesStatusAfter(storedDays - 1)) {
      storedDays--;
    }
    while (!reachesStatusAfter(storedDays)) {
      storedDays++;
    }
    return storedOn.addDays(storedDays);
  }

  /// The day the recommended maximum storage time is used up.
  static CalendarDate storageLimitReachedOn({
    required CalendarDate storedOn,
    required int recommendedMaximumStorageDays,
  }) => storedOn.addDays(recommendedMaximumStorageDays);
}
