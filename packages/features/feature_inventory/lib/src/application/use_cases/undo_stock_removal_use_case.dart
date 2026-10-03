import 'package:core_foundation/core_foundation.dart';

import '../../domain/inventory_events.dart';
import '../../domain/inventory_failure.dart';
import '../../domain/inventory_movement.dart';
import 'inventory_use_case_dependencies.dart';

/// Undoes taking or throwing away food (the snackbar's "Undo").
///
/// The log stays append-only: a compensating movement of the same kind with
/// the opposite amount is appended and points at the undone one, so sums per
/// kind (eaten, thrown away) stay right for statistics.
final class UndoStockRemovalUseCase {
  const UndoStockRemovalUseCase({required InventoryUseCaseDependencies dependencies})
    : _dependencies = dependencies;

  final InventoryUseCaseDependencies _dependencies;

  Future<Result<Unit, InventoryFailure>> execute(
    InventoryMovementIdentifier movementIdentifier,
  ) async {
    final result = await _dependencies.transactionRunner.runInTransaction(
      () => _undo(movementIdentifier),
    );
    if (result case SuccessfulResult(value: final event)) {
      await _dependencies.domainEventBus.publish(event);
    }
    return result.mapValue((_) => unit);
  }

  Future<Result<StockBatchCorrected, InventoryFailure>> _undo(
    InventoryMovementIdentifier movementIdentifier,
  ) async {
    final repository = _dependencies.repository;
    final movement = await repository.readMovement(movementIdentifier);
    final isUndoable =
        movement != null &&
        (movement.kind == MovementKind.consumed || movement.kind == MovementKind.discarded) &&
        movement.quantityDelta.isNegative &&
        !movement.isReversal &&
        !await repository.isMovementReversed(movementIdentifier);
    if (!isUndoable) return const Result.failure(MovementCannotBeUndone());
    final batch = await repository.readBatch(movement.stockBatchIdentifier);
    if (batch == null) return const Result.failure(StockBatchNotFound());

    final restoredQuantity = -movement.quantityDelta;
    final remaining = batch.quantityRemaining + restoredQuantity;
    final occurredAt = _dependencies.clock.nowUtc();
    await repository.updateQuantityRemaining(batch.identifier, remaining.amountInBaseUnits);
    await repository.appendMovement(
      InventoryMovement(
        identifier: _dependencies.identifierGenerator.createIdentifier(),
        stockBatchIdentifier: batch.identifier,
        productIdentifier: batch.productIdentifier,
        compartmentIdentifier: batch.compartmentIdentifier,
        kind: movement.kind,
        quantityDelta: restoredQuantity,
        discardReason: movement.discardReason,
        reversesMovementIdentifier: movement.identifier,
        occurredAt: occurredAt,
      ),
    );
    return Result.success(
      StockBatchCorrected(
        stockBatchIdentifier: batch.identifier,
        productIdentifier: batch.productIdentifier,
        quantityDelta: restoredQuantity,
        quantityRemaining: remaining,
        occurredAt: occurredAt,
      ),
    );
  }
}
