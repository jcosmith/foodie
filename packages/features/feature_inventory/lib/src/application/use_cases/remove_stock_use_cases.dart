import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import '../../domain/inventory_events.dart';
import '../../domain/inventory_failure.dart';
import '../../domain/inventory_movement.dart';
import '../../domain/stock_batch.dart';
import 'inventory_use_case_dependencies.dart';

/// The outcome of taking or throwing away food; the movement identifier is
/// what the undo snackbar needs.
@immutable
final class RecordedStockRemoval {
  const RecordedStockRemoval({
    required this.movementIdentifier,
    required this.stockBatchIdentifier,
    required this.quantity,
    required this.quantityRemaining,
  });

  final InventoryMovementIdentifier movementIdentifier;
  final StockBatchIdentifier stockBatchIdentifier;
  final Quantity quantity;
  final Quantity quantityRemaining;
}

/// Takes some or all of a batch out to eat (architecture document, section
/// 10.1): 200 g of a 1 kg bag leaves 800 g that keep their freezing date.
final class ConsumeStockUseCase {
  const ConsumeStockUseCase({required InventoryUseCaseDependencies dependencies})
    : _dependencies = dependencies;

  final InventoryUseCaseDependencies _dependencies;

  Future<Result<RecordedStockRemoval, InventoryFailure>> execute({
    required StockBatchIdentifier stockBatchIdentifier,
    required Quantity quantity,
  }) => _removeStock(
    _dependencies,
    stockBatchIdentifier: stockBatchIdentifier,
    quantity: quantity,
    kind: MovementKind.consumed,
    createEvent: (batch, movement, remaining) => StockBatchConsumed(
      stockBatchIdentifier: batch.identifier,
      productIdentifier: batch.productIdentifier,
      movementIdentifier: movement.identifier,
      quantity: quantity,
      quantityRemaining: remaining,
      occurredAt: movement.occurredAt,
    ),
  );
}

/// Throws away some or all of a batch, with a reason for the waste statistics.
final class DiscardStockUseCase {
  const DiscardStockUseCase({required InventoryUseCaseDependencies dependencies})
    : _dependencies = dependencies;

  final InventoryUseCaseDependencies _dependencies;

  Future<Result<RecordedStockRemoval, InventoryFailure>> execute({
    required StockBatchIdentifier stockBatchIdentifier,
    required Quantity quantity,
    required DiscardReason discardReason,
  }) => _removeStock(
    _dependencies,
    stockBatchIdentifier: stockBatchIdentifier,
    quantity: quantity,
    kind: MovementKind.discarded,
    discardReason: discardReason,
    createEvent: (batch, movement, remaining) => StockBatchDiscarded(
      stockBatchIdentifier: batch.identifier,
      productIdentifier: batch.productIdentifier,
      movementIdentifier: movement.identifier,
      quantity: quantity,
      quantityRemaining: remaining,
      discardReason: discardReason,
      occurredAt: movement.occurredAt,
    ),
  );
}

Future<Result<RecordedStockRemoval, InventoryFailure>> _removeStock(
  InventoryUseCaseDependencies dependencies, {
  required StockBatchIdentifier stockBatchIdentifier,
  required Quantity quantity,
  required MovementKind kind,
  required DomainEvent Function(StockBatch batch, InventoryMovement movement, Quantity remaining)
  createEvent,
  DiscardReason? discardReason,
}) async {
  Future<Result<(RecordedStockRemoval, DomainEvent), InventoryFailure>>
  removeInTransaction() async {
    final batch = await dependencies.repository.readBatch(stockBatchIdentifier);
    if (batch == null) return const Result.failure(StockBatchNotFound());
    if (quantity.unit != batch.unit) return const Result.failure(QuantityUnitMismatch());
    if (!quantity.isPositive) return const Result.failure(QuantityNotPositive());
    if (quantity.isGreaterThan(batch.quantityRemaining)) {
      return const Result.failure(QuantityExceedsRemaining());
    }

    final remaining = batch.quantityRemaining - quantity;
    final movement = InventoryMovement(
      identifier: dependencies.identifierGenerator.createIdentifier(),
      stockBatchIdentifier: batch.identifier,
      productIdentifier: batch.productIdentifier,
      compartmentIdentifier: batch.compartmentIdentifier,
      kind: kind,
      quantityDelta: -quantity,
      discardReason: discardReason,
      occurredAt: dependencies.clock.nowUtc(),
    );
    await dependencies.repository.updateQuantityRemaining(
      batch.identifier,
      remaining.amountInBaseUnits,
    );
    await dependencies.repository.appendMovement(movement);
    final recordedRemoval = RecordedStockRemoval(
      movementIdentifier: movement.identifier,
      stockBatchIdentifier: batch.identifier,
      quantity: quantity,
      quantityRemaining: remaining,
    );
    return Result.success((recordedRemoval, createEvent(batch, movement, remaining)));
  }

  final result = await dependencies.transactionRunner.runInTransaction(removeInTransaction);
  if (result case SuccessfulResult(value: (_, final event))) {
    await dependencies.domainEventBus.publish(event);
  }
  return result.mapValue((recordedRemovalAndEvent) => recordedRemovalAndEvent.$1);
}
