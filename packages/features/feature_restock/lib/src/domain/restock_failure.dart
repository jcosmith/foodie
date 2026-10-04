import 'package:core_foundation/core_foundation.dart';

/// Why a restock or shopping list change was refused.
sealed class RestockFailure extends Failure {
  const RestockFailure();
}

final class MinimumQuantityNotPositive extends RestockFailure {
  const MinimumQuantityNotPositive();

  @override
  String get debugDescription => 'The minimum must be more than zero';
}

final class TargetBelowMinimum extends RestockFailure {
  const TargetBelowMinimum();

  @override
  String get debugDescription => 'The target must not be below the minimum';
}

/// The amount is in another unit than the product's.
final class RestockUnitMismatch extends RestockFailure {
  const RestockUnitMismatch();

  @override
  String get debugDescription => 'The amount is not in the product unit';
}

final class RestockProductNotFound extends RestockFailure {
  const RestockProductNotFound();

  @override
  String get debugDescription => 'The product does not exist';
}

final class ShoppingListEntryNotFound extends RestockFailure {
  const ShoppingListEntryNotFound();

  @override
  String get debugDescription => 'The shopping list entry does not exist';
}

/// Running-low entries follow the stock; change the rule instead.
final class AutomaticEntryCannotBeRemoved extends RestockFailure {
  const AutomaticEntryCannotBeRemoved();

  @override
  String get debugDescription => 'Entries from restock rules follow the stock';
}

/// Putting bought items into storage needs a storage place.
final class NoCompartmentForBoughtItems extends RestockFailure {
  const NoCompartmentForBoughtItems();

  @override
  String get debugDescription => 'There is no freezer to put the items in';
}
