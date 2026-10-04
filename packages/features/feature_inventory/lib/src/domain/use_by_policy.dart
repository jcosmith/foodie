import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'stock_batch.dart';

/// How urgently a batch should be used; [overdue] once its last good day
/// has passed.
enum UseByStatus { fresh, aging, urgent, overdue }

/// Which date decides when a batch should be used.
enum UseByReason { shelfLife, bestBefore, opened }

/// The date that decides when a batch should be used, and from when its time
/// counts.
@immutable
final class UseByDeadline {
  const UseByDeadline({required this.countsFrom, required this.lastGoodDay, required this.reason});

  /// The stored-on day, or the opened-on day for [UseByReason.opened].
  final CalendarDate countsFrom;

  /// The last day the batch should be used on.
  final CalendarDate lastGoodDay;

  final UseByReason reason;

  /// The first day the batch is overdue.
  CalendarDate get overdueFrom => lastGoodDay.addDays(1);

  /// Days until [lastGoodDay]: 0 on that day, negative after it.
  int daysLeftOn(CalendarDate day) => day.daysUntil(lastGoodDay);

  /// Past 60 % of the time it should be used soon and past 85 % now; food
  /// that keeps a day or two is due at once: "use today" on its last good
  /// day, "use by tomorrow" the day before.
  UseByStatus statusOn(CalendarDate day) {
    final daysLeft = daysLeftOn(day);
    if (daysLeft < 0) return UseByStatus.overdue;
    final totalDays = countsFrom.daysUntil(overdueFrom);
    final share = totalDays <= 0 ? 1.0 : countsFrom.daysUntil(day) / totalDays;
    if (daysLeft == 0 || share >= UseByPolicy.urgentShare) return UseByStatus.urgent;
    if (daysLeft == 1 || share >= UseByPolicy.agingShare) return UseByStatus.aging;
    return UseByStatus.fresh;
  }

  /// The first day the batch is at least [status]. The status only ever
  /// grows, so a binary search between the start and [overdueFrom] finds it.
  CalendarDate firstDayWithStatus(UseByStatus status) {
    final start = countsFrom.isBefore(overdueFrom) ? countsFrom : overdueFrom;
    var low = 0;
    var high = start.daysUntil(overdueFrom);
    while (low < high) {
      final middle = (low + high) ~/ 2;
      if (statusOn(start.addDays(middle)).index >= status.index) {
        high = middle;
      } else {
        low = middle + 1;
      }
    }
    return start.addDays(low);
  }

  @override
  bool operator ==(Object other) =>
      other is UseByDeadline &&
      other.countsFrom == countsFrom &&
      other.lastGoodDay == lastGoodDay &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(countsFrom, lastGoodDay, reason);
}

/// When a batch should be used: the earliest of the stored-on day plus the
/// shelf life, the best-before date, and the opened-on day plus the shelf
/// life after opening. Batches with none of these (most supplies) never
/// become due.
abstract final class UseByPolicy {
  static const double agingShare = 0.6;
  static const double urgentShare = 0.85;

  static UseByDeadline? deadlineOf({
    required CalendarDate storedOn,
    int? shelfLifeDays,
    CalendarDate? bestBeforeOn,
    CalendarDate? openedOn,
    int? shelfLifeAfterOpeningDays,
  }) {
    final candidates = [
      if (shelfLifeDays != null && shelfLifeDays > 0)
        UseByDeadline(
          countsFrom: storedOn,
          lastGoodDay: storedOn.addDays(shelfLifeDays - 1),
          reason: UseByReason.shelfLife,
        ),
      if (bestBeforeOn != null)
        UseByDeadline(
          countsFrom: storedOn,
          lastGoodDay: bestBeforeOn,
          reason: UseByReason.bestBefore,
        ),
      if (openedOn != null && shelfLifeAfterOpeningDays != null && shelfLifeAfterOpeningDays > 0)
        UseByDeadline(
          countsFrom: openedOn,
          lastGoodDay: openedOn.addDays(shelfLifeAfterOpeningDays - 1),
          reason: UseByReason.opened,
        ),
    ];
    if (candidates.isEmpty) return null;
    return candidates.reduce(
      (earliest, candidate) =>
          candidate.lastGoodDay.isBefore(earliest.lastGoodDay) ? candidate : earliest,
    );
  }

  static UseByDeadline? deadlineOfBatch(
    StockBatch batch, {
    required int? shelfLifeDays,
    required int? shelfLifeAfterOpeningDays,
  }) => deadlineOf(
    storedOn: batch.storedOn,
    shelfLifeDays: shelfLifeDays,
    bestBeforeOn: batch.bestBeforeOn,
    openedOn: batch.openedOn,
    shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays,
  );
}
