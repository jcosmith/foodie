import 'package:core_foundation/core_foundation.dart';

import 'inventory_movement.dart';

/// Sensible amounts for taking food out (architecture document, section
/// 10.1): sliders snap to a step that suits the package, 1 g or ml for
/// packages under 50, 10 up to 200 and 50 above that, or half a piece or
/// portion, and the quick fractions round to those steps.
abstract final class RemovalAmountPolicy {
  /// The step follows the original package size, so it stays the same
  /// while the package is used up.
  static Quantity stepFor(Quantity packageSize) => switch (packageSize.unit) {
    QuantityUnit.gram || QuantityUnit.milliliter => Quantity(
      amountInBaseUnits: switch (packageSize.amountInBaseUnits) {
        < 50 => 1,
        <= 200 => 10,
        _ => 50,
      },
      unit: packageSize.unit,
    ),
    QuantityUnit.piece ||
    QuantityUnit.portion => Quantity(amountInBaseUnits: 500, unit: packageSize.unit),
  };

  /// [fraction] of [remaining], rounded to the step but never below one
  /// step nor above what is left; a fraction of 1 takes everything.
  static Quantity fractionOf(Quantity remaining, double fraction, {required Quantity packageSize}) {
    if (fraction >= 1) return remaining;
    return _rounded(remaining, remaining.amountInBaseUnits * fraction, packageSize);
  }

  /// The amount the take sheet starts with: the [usualAmount] taken of this
  /// product when there is one, otherwise about a fifth; the whole batch
  /// when it holds one step or less.
  static Quantity suggestedAmount(
    Quantity remaining, {
    required Quantity packageSize,
    Quantity? usualAmount,
  }) => usualAmount != null && usualAmount.unit == remaining.unit && usualAmount.isPositive
      ? _rounded(remaining, usualAmount.amountInBaseUnits.toDouble(), packageSize)
      : fractionOf(remaining, 0.2, packageSize: packageSize);

  /// Snaps a slider position to the step grid, between one step and [remaining].
  static Quantity snap(Quantity remaining, int amountInBaseUnits, {required Quantity packageSize}) {
    if (amountInBaseUnits >= remaining.amountInBaseUnits) return remaining;
    return _rounded(remaining, amountInBaseUnits.toDouble(), packageSize);
  }

  /// The average amount taken out of [productMovements] (movements of one
  /// product) per removal, leaving out undone removals; `null` without any.
  static Quantity? usualConsumedAmount(List<InventoryMovement> productMovements) {
    final reversedIdentifiers = {
      for (final movement in productMovements) ?movement.reversesMovementIdentifier,
    };
    final removals = [
      for (final movement in productMovements)
        if (movement.kind == MovementKind.consumed &&
            movement.quantityDelta.isNegative &&
            !movement.isReversal &&
            !reversedIdentifiers.contains(movement.identifier))
          movement.quantityDelta,
    ];
    if (removals.isEmpty) return null;
    final unit = removals.last.unit;
    final sameUnit = removals.where((delta) => delta.unit == unit).toList();
    final total = sameUnit.fold<int>(0, (sum, delta) => sum - delta.amountInBaseUnits);
    return Quantity(amountInBaseUnits: (total / sameUnit.length).round(), unit: unit);
  }

  static Quantity _rounded(Quantity remaining, double amountInBaseUnits, Quantity packageSize) {
    final step = stepFor(packageSize).amountInBaseUnits;
    if (remaining.amountInBaseUnits <= step) return remaining;
    final roundedAmount = ((amountInBaseUnits / step).round() * step).clamp(
      step,
      remaining.amountInBaseUnits,
    );
    return Quantity(amountInBaseUnits: roundedAmount, unit: remaining.unit);
  }
}
