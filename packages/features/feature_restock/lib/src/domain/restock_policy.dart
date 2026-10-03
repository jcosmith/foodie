import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

import 'restock_rule.dart';
import 'shopping_list_entry.dart';

/// A running-low product that needs a new entry on the shopping list.
@immutable
final class PlannedRestockEntry {
  const PlannedRestockEntry({required this.productIdentifier, required this.quantityToBuy});

  final ProductIdentifier productIdentifier;
  final Quantity quantityToBuy;
}

/// What bringing the shopping list in line with the stock changes.
@immutable
final class ShoppingListChanges {
  const ShoppingListChanges({
    required this.entriesToAdd,
    required this.entriesToUpdate,
    required this.entriesToRemove,
  });

  final List<PlannedRestockEntry> entriesToAdd;
  final List<ShoppingListEntry> entriesToUpdate;
  final List<ShoppingListEntry> entriesToRemove;

  bool get isEmpty => entriesToAdd.isEmpty && entriesToUpdate.isEmpty && entriesToRemove.isEmpty;
}

/// Low-stock detection and the automatic shopping list entries.
abstract final class RestockPolicy {
  static bool isRunningLow({required RestockRule rule, required Quantity stock}) =>
      rule.isActive &&
      stock.hasSameUnitAs(rule.minimumQuantity) &&
      stock.isLessThan(rule.minimumQuantity);

  /// Up to the target (or the minimum), and at least one package, since
  /// nobody buys 120 g of a 1 kg bag.
  static Quantity quantityToBuy({
    required RestockRule rule,
    required Quantity stock,
    Quantity? packageQuantity,
  }) {
    final goal = rule.targetQuantity ?? rule.minimumQuantity;
    final missing = goal - stock;
    if (packageQuantity != null &&
        packageQuantity.hasSameUnitAs(goal) &&
        packageQuantity.isGreaterThan(missing)) {
      return packageQuantity;
    }
    return missing.isPositive ? missing : goal;
  }

  /// Adds an entry for every running-low product that is not on the list yet,
  /// updates the amount of automatic entries as the stock changes and removes
  /// them once the product is stocked again. Entries the user added or ticked
  /// are left alone.
  static ShoppingListChanges reconcile({
    required List<RestockRule> rules,
    required Map<ProductIdentifier, Quantity> stockByProduct,
    required Map<ProductIdentifier, Quantity?> packageQuantityByProduct,
    required List<ShoppingListEntry> entries,
  }) {
    Quantity stockOf(RestockRule rule) =>
        stockByProduct[rule.productIdentifier] ?? Quantity.zero(rule.minimumQuantity.unit);
    Quantity? quantityToBuyFor(ProductIdentifier productIdentifier) {
      final rule = rules
          .where((candidate) => candidate.productIdentifier == productIdentifier)
          .firstOrNull;
      if (rule == null || !isRunningLow(rule: rule, stock: stockOf(rule))) return null;
      return quantityToBuy(
        rule: rule,
        stock: stockOf(rule),
        packageQuantity: packageQuantityByProduct[productIdentifier],
      );
    }

    final entriesToUpdate = <ShoppingListEntry>[];
    final entriesToRemove = <ShoppingListEntry>[];
    for (final entry in entries) {
      final productIdentifier = entry.productIdentifier;
      if (!entry.isAutomatic || entry.isChecked || productIdentifier == null) continue;
      final requiredQuantity = quantityToBuyFor(productIdentifier);
      if (requiredQuantity == null) {
        entriesToRemove.add(entry);
      } else if (requiredQuantity != entry.requestedQuantity) {
        entriesToUpdate.add(entry.copyWith(requestedQuantity: requiredQuantity));
      }
    }

    final productsOnTheList = {for (final entry in entries) ?entry.productIdentifier};
    final entriesToAdd = [
      for (final rule in rules)
        if (!productsOnTheList.contains(rule.productIdentifier))
          if (quantityToBuyFor(rule.productIdentifier) case final quantity?)
            PlannedRestockEntry(productIdentifier: rule.productIdentifier, quantityToBuy: quantity),
    ];
    return ShoppingListChanges(
      entriesToAdd: entriesToAdd,
      entriesToUpdate: entriesToUpdate,
      entriesToRemove: entriesToRemove,
    );
  }
}
