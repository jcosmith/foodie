import 'package:core_foundation/core_foundation.dart';

/// Sensible amounts for taking food out (architecture document, section
/// 10.1): sliders snap to 50 g, 50 ml or half a piece or portion, and the
/// quick fractions round to those steps.
abstract final class RemovalAmountPolicy {
  static Quantity stepFor(QuantityUnit unit) => switch (unit) {
    QuantityUnit.gram || QuantityUnit.milliliter => Quantity(amountInBaseUnits: 50, unit: unit),
    QuantityUnit.piece || QuantityUnit.portion => Quantity(amountInBaseUnits: 500, unit: unit),
  };

  /// [fraction] of [remaining], rounded to the step but never below one
  /// step nor above what is left; a fraction of 1 takes everything.
  static Quantity fractionOf(Quantity remaining, double fraction) {
    final step = stepFor(remaining.unit).amountInBaseUnits;
    if (fraction >= 1 || remaining.amountInBaseUnits <= step) return remaining;
    final roundedAmount = (remaining.amountInBaseUnits * fraction / step).round() * step;
    return Quantity(
      amountInBaseUnits: roundedAmount.clamp(step, remaining.amountInBaseUnits),
      unit: remaining.unit,
    );
  }

  /// The amount the take sheet starts with: about a fifth, or the whole
  /// batch when it holds one step or less.
  static Quantity suggestedAmount(Quantity remaining) => fractionOf(remaining, 0.2);

  /// Snaps a slider position to the step grid, between one step and [remaining].
  static Quantity snap(Quantity remaining, int amountInBaseUnits) {
    final step = stepFor(remaining.unit).amountInBaseUnits;
    if (amountInBaseUnits >= remaining.amountInBaseUnits || remaining.amountInBaseUnits <= step) {
      return remaining;
    }
    final snappedAmount = ((amountInBaseUnits / step).round() * step).clamp(
      step,
      remaining.amountInBaseUnits,
    );
    return Quantity(amountInBaseUnits: snappedAmount, unit: remaining.unit);
  }
}
