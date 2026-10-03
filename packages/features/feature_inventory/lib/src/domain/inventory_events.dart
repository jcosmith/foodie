import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';

import 'inventory_movement.dart';
import 'stock_batch.dart';

/// Base of every inventory event, so subscribers can listen to all of them.
sealed class StockBatchEvent extends DomainEvent {
  const StockBatchEvent({
    required this.stockBatchIdentifier,
    required this.productIdentifier,
    required super.occurredAt,
  });

  final StockBatchIdentifier stockBatchIdentifier;
  final ProductIdentifier productIdentifier;
}

final class StockBatchAdded extends StockBatchEvent {
  const StockBatchAdded({
    required super.stockBatchIdentifier,
    required super.productIdentifier,
    required this.compartmentIdentifier,
    required this.quantity,
    required super.occurredAt,
  });

  final CompartmentIdentifier compartmentIdentifier;
  final Quantity quantity;
}

/// Some or all of a batch was eaten.
final class StockBatchConsumed extends StockBatchEvent {
  const StockBatchConsumed({
    required super.stockBatchIdentifier,
    required super.productIdentifier,
    required this.movementIdentifier,
    required this.quantity,
    required this.quantityRemaining,
    required super.occurredAt,
  });

  final InventoryMovementIdentifier movementIdentifier;
  final Quantity quantity;
  final Quantity quantityRemaining;
}

/// Some or all of a batch was thrown away.
final class StockBatchDiscarded extends StockBatchEvent {
  const StockBatchDiscarded({
    required super.stockBatchIdentifier,
    required super.productIdentifier,
    required this.movementIdentifier,
    required this.quantity,
    required this.quantityRemaining,
    required this.discardReason,
    required super.occurredAt,
  });

  final InventoryMovementIdentifier movementIdentifier;
  final Quantity quantity;
  final Quantity quantityRemaining;
  final DiscardReason discardReason;
}

/// A batch, or a part split off it, now sits in another compartment.
final class StockBatchMoved extends StockBatchEvent {
  const StockBatchMoved({
    required super.stockBatchIdentifier,
    required super.productIdentifier,
    required this.sourceCompartmentIdentifier,
    required this.destinationCompartmentIdentifier,
    required this.quantity,
    required super.occurredAt,
    this.splitOffBatchIdentifier,
  });

  final CompartmentIdentifier sourceCompartmentIdentifier;
  final CompartmentIdentifier destinationCompartmentIdentifier;
  final Quantity quantity;

  /// The new batch when only part of [stockBatchIdentifier] moved.
  final StockBatchIdentifier? splitOffBatchIdentifier;
}

/// The remaining amount was set to what is really left, or a removal was undone.
final class StockBatchCorrected extends StockBatchEvent {
  const StockBatchCorrected({
    required super.stockBatchIdentifier,
    required super.productIdentifier,
    required this.quantityDelta,
    required this.quantityRemaining,
    required super.occurredAt,
  });

  final Quantity quantityDelta;
  final Quantity quantityRemaining;
}
