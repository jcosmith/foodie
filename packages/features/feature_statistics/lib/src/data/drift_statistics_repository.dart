import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';

import '../domain/statistics_date_range.dart';
import '../domain/statistics_filter.dart';
import '../domain/statistics_movement_fact.dart';
import '../domain/statistics_repository.dart';

/// Reads movement facts through the read-only [StatisticsDao]. The queries
/// run on Drift's background isolate and re-run when the movement log changes.
final class DriftStatisticsRepository implements StatisticsRepository {
  const DriftStatisticsRepository(this._statisticsDao);

  final StatisticsDao _statisticsDao;

  @override
  Stream<List<StatisticsMovementFact>> watchFacts(StatisticsDateRange period) => _statisticsDao
      .watchDailyMovementAggregates(
        // Local midnights, so days follow the phone's time zone and summer time.
        occurredFrom: period.firstDay.toLocalDateTime(),
        occurredBefore: period.lastDay.addDays(1).toLocalDateTime(),
      )
      .map((rows) => [for (final row in rows) ?_factFromRow(row)]);

  @override
  Stream<CalendarDate?> watchFirstActivityDay() => _statisticsDao.watchFirstMovementTime().map(
    (firstMovementTime) =>
        firstMovementTime == null ? null : CalendarDate.fromDateTime(firstMovementTime.toLocal()),
  );

  static StatisticsMovementFact? _factFromRow(MovementDailyAggregateRow row) {
    final activity = StatisticsActivity.fromStorageName(row.movementKind);
    if (activity == null) return null;
    return StatisticsMovementFact(
      day: row.localDay,
      activity: activity,
      productIdentifier: TypedIdentifier(row.productIdentifier),
      categoryIdentifier: TypedIdentifier(row.categoryIdentifier),
      compartmentIdentifier: TypedIdentifier(row.compartmentIdentifier),
      quantity: Quantity(
        amountInBaseUnits: row.quantityInBaseUnits,
        unit: QuantityUnit.fromStorageName(row.quantityUnit),
      ),
      movementCount: row.movementCount,
      storedDays: row.storedDays,
      discardReason: StatisticsDiscardReason.fromStorageName(row.discardReason),
    );
  }
}
