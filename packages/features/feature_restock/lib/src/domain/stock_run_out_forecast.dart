import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

import 'restock_rule.dart';

/// When a product with a restock rule will run out at the recent eating
/// rate (architecture document, "Runs out in" insight chart).
@immutable
final class StockRunOutForecast {
  const StockRunOutForecast({
    required this.productIdentifier,
    required this.stock,
    required this.daysLeft,
  });

  final ProductIdentifier productIdentifier;
  final Quantity stock;

  /// Rounded; `null` when nothing was eaten in the look-back window.
  final int? daysLeft;

  bool get runsOutSoon =>
      daysLeft != null && daysLeft! < StockRunOutForecasting.soonThresholdInDays;
}

abstract final class StockRunOutForecasting {
  /// The eating rate is the amount eaten over this many days, per day.
  static const int lookBackInDays = 60;

  /// Products that run out within fewer days are highlighted.
  static const int soonThresholdInDays = 10;

  /// One forecast per rule, soonest first; products without recent use last.
  static List<StockRunOutForecast> forecast({
    required Iterable<RestockRule> rules,
    required Map<ProductIdentifier, Quantity> stockByProduct,
    required Iterable<InventoryMovement> recentMovements,
    required QuantityUnit Function(ProductIdentifier productIdentifier) canonicalUnitOf,
  }) {
    final eatenAmountByProduct = <ProductIdentifier, int>{};
    for (final movement in recentMovements) {
      if (movement.kind != MovementKind.consumed) continue;
      // Undoing an eat is a consumed movement with a positive delta, so the
      // sum nets out.
      eatenAmountByProduct.update(
        movement.productIdentifier,
        (amount) => amount - movement.quantityDelta.amountInBaseUnits,
        ifAbsent: () => -movement.quantityDelta.amountInBaseUnits,
      );
    }
    final forecasts = [
      for (final rule in rules)
        _forecastFor(
          rule.productIdentifier,
          stock:
              stockByProduct[rule.productIdentifier] ??
              Quantity.zero(canonicalUnitOf(rule.productIdentifier)),
          eatenAmountInBaseUnits: eatenAmountByProduct[rule.productIdentifier] ?? 0,
        ),
    ];
    return forecasts..sort(
      (first, second) => switch ((first.daysLeft, second.daysLeft)) {
        (null, null) => 0,
        (null, _) => 1,
        (_, null) => -1,
        (final firstDays?, final secondDays?) => firstDays.compareTo(secondDays),
      },
    );
  }

  static StockRunOutForecast _forecastFor(
    ProductIdentifier productIdentifier, {
    required Quantity stock,
    required int eatenAmountInBaseUnits,
  }) {
    final dailyRate = eatenAmountInBaseUnits / lookBackInDays;
    return StockRunOutForecast(
      productIdentifier: productIdentifier,
      stock: stock,
      daysLeft: dailyRate > 0 ? (stock.amountInBaseUnits / dailyRate).round() : null,
    );
  }
}
