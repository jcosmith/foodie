import 'package:core_foundation/core_foundation.dart';

import 'statistics_filter.dart';
import 'statistics_movement_fact.dart';

/// Turns a fact into the number a measure adds up, or `null` when the fact's
/// unit does not belong to the measure (units are never mixed).
abstract final class StatisticsMeasurePolicy {
  /// Kilograms, litres, pieces (pieces and portions together) or a count.
  static double? valueOf(StatisticsMovementFact fact, StatisticsMeasure measure) {
    final unit = fact.quantity.unit;
    return switch (measure) {
      StatisticsMeasure.count => fact.movementCount.toDouble(),
      StatisticsMeasure.weight =>
        unit == QuantityUnit.gram ? fact.quantity.amountInBaseUnits / 1000 : null,
      StatisticsMeasure.volume =>
        unit == QuantityUnit.milliliter ? fact.quantity.amountInBaseUnits / 1000 : null,
      StatisticsMeasure.pieces =>
        unit.dimension == QuantityDimension.count ? fact.quantity.displayAmount : null,
    };
  }
}
