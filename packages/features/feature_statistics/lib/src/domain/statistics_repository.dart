import 'package:core_foundation/core_foundation.dart';

import 'statistics_date_range.dart';
import 'statistics_movement_fact.dart';

/// Reads the movement facts of a period; implemented over the database.
abstract interface class StatisticsRepository {
  /// Facts of every day in [period], updated live.
  Stream<List<StatisticsMovementFact>> watchFacts(StatisticsDateRange period);

  /// The local day of the first movement ever recorded; `null` while there is none.
  Stream<CalendarDate?> watchFirstActivityDay();
}
