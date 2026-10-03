import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';

import '../../domain/inventory_events.dart';
import '../../domain/inventory_failure.dart';
import '../../domain/inventory_movement.dart';
import '../../domain/stock_batch.dart';
import 'inventory_use_case_dependencies.dart';

/// Moves a batch, or part of it, to another compartment.
///
/// Moving everything keeps the batch and records two "moved" movements (out
/// of the old compartment, into the new one). Moving part splits the batch:
/// a new batch with the same freezing date and a parent reference takes the
/// moved amount (architecture document, section 10.1).
final class MoveStockBatchUseCase {
  MoveStockBatchUseCase({
    required InventoryUseCaseDependencies dependencies,
    required StorageLayoutQueryService storageLayout,
  }) : _dependencies = dependencies,
       _storageLayout = storageLayout,
       _stockBatchMover = StockBatchMover(dependencies);

  final InventoryUseCaseDependencies _dependencies;
  final StorageLayoutQueryService _storageLayout;
  final StockBatchMover _stockBatchMover;

  /// Returns the batch that is now in the destination: the same one, or the
  /// split-off part.
  Future<Result<StockBatchIdentifier, InventoryFailure>> execute({
    required StockBatchIdentifier stockBatchIdentifier,
    required CompartmentIdentifier destinationCompartmentIdentifier,
    required Quantity quantity,
  }) async {
    final destination = await _storageLayout.readCompartment(destinationCompartmentIdentifier);
    if (destination == null || destination.isArchived) {
      return const Result.failure(CompartmentNotAvailable());
    }
    final result = await _dependencies.transactionRunner.runInTransaction(
      () => _move(stockBatchIdentifier, destinationCompartmentIdentifier, quantity),
    );
    if (result case SuccessfulResult(value: final event)) {
      await _dependencies.domainEventBus.publish(event);
    }
    return result.mapValue((event) => event.splitOffBatchIdentifier ?? event.stockBatchIdentifier);
  }

  Future<Result<StockBatchMoved, InventoryFailure>> _move(
    StockBatchIdentifier stockBatchIdentifier,
    CompartmentIdentifier destinationCompartmentIdentifier,
    Quantity quantity,
  ) async {
    final batch = await _dependencies.repository.readBatch(stockBatchIdentifier);
    if (batch == null || batch.isDepleted) return const Result.failure(StockBatchNotFound());
    if (quantity.unit != batch.unit) return const Result.failure(QuantityUnitMismatch());
    if (!quantity.isPositive) return const Result.failure(QuantityNotPositive());
    if (quantity.isGreaterThan(batch.quantityRemaining)) {
      return const Result.failure(QuantityExceedsRemaining());
    }
    if (batch.compartmentIdentifier == destinationCompartmentIdentifier) {
      return const Result.failure(AlreadyInCompartment());
    }
    return Result.success(
      quantity == batch.quantityRemaining
          ? await _stockBatchMover.moveWholeBatch(batch, destinationCompartmentIdentifier)
          : await _stockBatchMover.splitBatch(batch, destinationCompartmentIdentifier, quantity),
    );
  }
}

/// The writes of a move, without checks or transaction: shared by
/// [MoveStockBatchUseCase] and by emptying a compartment that is being
/// removed, which validates the destination itself.
final class StockBatchMover {
  const StockBatchMover(this._dependencies);

  final InventoryUseCaseDependencies _dependencies;

  /// Moves all of [batch]; also used when a compartment is removed. Must run
  /// inside a transaction; the caller publishes the returned event.
  Future<StockBatchMoved> moveWholeBatch(
    StockBatch batch,
    CompartmentIdentifier destinationCompartmentIdentifier,
  ) async {
    final occurredAt = _dependencies.clock.nowUtc();
    await _dependencies.repository.updateCompartment(
      batch.identifier,
      destinationCompartmentIdentifier,
    );
    await _appendMovePair(
      outOfBatch: batch,
      intoBatch: batch.copyWith(compartmentIdentifier: destinationCompartmentIdentifier),
      quantity: batch.quantityRemaining,
      occurredAt: occurredAt,
    );
    return StockBatchMoved(
      stockBatchIdentifier: batch.identifier,
      productIdentifier: batch.productIdentifier,
      sourceCompartmentIdentifier: batch.compartmentIdentifier,
      destinationCompartmentIdentifier: destinationCompartmentIdentifier,
      quantity: batch.quantityRemaining,
      occurredAt: occurredAt,
    );
  }

  /// Moves [quantity] of [batch] into a new batch in the destination. Must
  /// run inside a transaction; the caller publishes the returned event.
  Future<StockBatchMoved> splitBatch(
    StockBatch batch,
    CompartmentIdentifier destinationCompartmentIdentifier,
    Quantity quantity,
  ) async {
    final occurredAt = _dependencies.clock.nowUtc();
    final splitOffBatch = StockBatch(
      identifier: _dependencies.identifierGenerator.createIdentifier(),
      productIdentifier: batch.productIdentifier,
      compartmentIdentifier: destinationCompartmentIdentifier,
      // Its only movement is the incoming "moved" one, so its movements add
      // up to what it holds, like every other batch.
      initialQuantity: quantity,
      quantityRemaining: quantity,
      parentBatchIdentifier: batch.identifier,
      frozenOn: batch.frozenOn,
      bestBeforeOn: batch.bestBeforeOn,
      note: batch.note,
      createdAt: occurredAt,
    );
    await _dependencies.repository.insertBatch(splitOffBatch);
    await _dependencies.repository.updateQuantityRemaining(
      batch.identifier,
      (batch.quantityRemaining - quantity).amountInBaseUnits,
    );
    await _appendMovePair(
      outOfBatch: batch,
      intoBatch: splitOffBatch,
      quantity: quantity,
      occurredAt: occurredAt,
    );
    return StockBatchMoved(
      stockBatchIdentifier: batch.identifier,
      productIdentifier: batch.productIdentifier,
      sourceCompartmentIdentifier: batch.compartmentIdentifier,
      destinationCompartmentIdentifier: destinationCompartmentIdentifier,
      quantity: quantity,
      splitOffBatchIdentifier: splitOffBatch.identifier,
      occurredAt: occurredAt,
    );
  }

  Future<void> _appendMovePair({
    required StockBatch outOfBatch,
    required StockBatch intoBatch,
    required Quantity quantity,
    required DateTime occurredAt,
  }) async {
    for (final (batch, delta) in [(outOfBatch, -quantity), (intoBatch, quantity)]) {
      await _dependencies.repository.appendMovement(
        InventoryMovement(
          identifier: _dependencies.identifierGenerator.createIdentifier(),
          stockBatchIdentifier: batch.identifier,
          productIdentifier: batch.productIdentifier,
          compartmentIdentifier: batch.compartmentIdentifier,
          kind: MovementKind.moved,
          quantityDelta: delta,
          occurredAt: occurredAt,
        ),
      );
    }
  }
}
