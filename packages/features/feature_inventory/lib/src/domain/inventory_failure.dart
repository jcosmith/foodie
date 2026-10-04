import 'package:core_foundation/core_foundation.dart';

/// Why an inventory change was refused.
sealed class InventoryFailure extends Failure {
  const InventoryFailure();
}

/// Taking, discarding or moving nothing (architecture document, section 10.1).
final class QuantityNotPositive extends InventoryFailure {
  const QuantityNotPositive();

  @override
  String get debugDescription => 'The amount must be more than zero';
}

final class QuantityExceedsRemaining extends InventoryFailure {
  const QuantityExceedsRemaining();

  @override
  String get debugDescription => 'The amount is more than what is left';
}

/// The amount is in a different unit than the product's.
final class QuantityUnitMismatch extends InventoryFailure {
  const QuantityUnitMismatch();

  @override
  String get debugDescription => 'The amount uses another unit than the product';
}

final class StockBatchNotFound extends InventoryFailure {
  const StockBatchNotFound();

  @override
  String get debugDescription => 'The stock batch does not exist';
}

final class ProductNotAvailable extends InventoryFailure {
  const ProductNotAvailable();

  @override
  String get debugDescription => 'The product does not exist or is hidden';
}

final class CompartmentNotAvailable extends InventoryFailure {
  const CompartmentNotAvailable();

  @override
  String get debugDescription => 'The compartment does not exist or was removed';
}

/// Moving a batch to the compartment it is already in.
final class AlreadyInCompartment extends InventoryFailure {
  const AlreadyInCompartment();

  @override
  String get debugDescription => 'The batch is already in that compartment';
}

/// A correction that would not change anything.
final class QuantityUnchanged extends InventoryFailure {
  const QuantityUnchanged();

  @override
  String get debugDescription => 'The remaining amount is already this';
}

/// Only removals (taken or thrown away) can be undone, and only once.
final class MovementCannotBeUndone extends InventoryFailure {
  const MovementCannotBeUndone();

  @override
  String get debugDescription => 'This movement cannot be undone';
}

/// Frozen-on dates in the future are typing mistakes.
final class StoredOnInFuture extends InventoryFailure {
  const StoredOnInFuture();

  @override
  String get debugDescription => 'The freezing date lies in the future';
}
