import 'package:core_foundation/core_foundation.dart';

import '../../domain/inventory_events.dart';
import '../../domain/inventory_failure.dart';
import '../../domain/inventory_movement.dart';
import '../../domain/stock_batch.dart';
import 'inventory_use_case_dependencies.dart';

/// Sets a batch to what is really left ("correct remaining amount"), for
/// people who estimated when taking food out. The difference is recorded as
/// a "corrected" movement.
final class CorrectRemainingQuantityUseCase {
  const CorrectRemainingQuantityUseCase({required InventoryUseCaseDependencies dependencies})
    : _dependencies = dependencies;

  final InventoryUseCaseDependencies _dependencies;

  Future<Result<Unit, InventoryFailure>> execute({
    required StockBatchIdentifier stockBatchIdentifier,
    required Quantity actualRemainingQuantity,
  }) async {
    final result = await _dependencies.transactionRunner.runInTransaction(
      () => _correct(stockBatchIdentifier, actualRemainingQuantity),
    );
    if (result case SuccessfulResult(value: final event)) {
      await _dependencies.domainEventBus.publish(event);
    }
    return result.mapValue((_) => unit);
  }

  Future<Result<StockBatchCorrected, InventoryFailure>> _correct(
    StockBatchIdentifier stockBatchIdentifier,
    Quantity actualRemainingQuantity,
  ) async {
    final repository = _dependencies.repository;
    final batch = await repository.readBatch(stockBatchIdentifier);
    if (batch == null) return const Result.failure(StockBatchNotFound());
    if (actualRemainingQuantity.unit != batch.unit) {
      return const Result.failure(QuantityUnitMismatch());
    }
    if (actualRemainingQuantity.isNegative) return const Result.failure(QuantityNotPositive());
    if (actualRemainingQuantity == batch.quantityRemaining) {
      return const Result.failure(QuantityUnchanged());
    }

    final quantityDelta = actualRemainingQuantity - batch.quantityRemaining;
    final occurredAt = _dependencies.clock.nowUtc();
    await repository.updateQuantityRemaining(
      batch.identifier,
      actualRemainingQuantity.amountInBaseUnits,
    );
    await repository.appendMovement(
      InventoryMovement(
        identifier: _dependencies.identifierGenerator.createIdentifier(),
        stockBatchIdentifier: batch.identifier,
        productIdentifier: batch.productIdentifier,
        compartmentIdentifier: batch.compartmentIdentifier,
        kind: MovementKind.corrected,
        quantityDelta: quantityDelta,
        occurredAt: occurredAt,
      ),
    );
    return Result.success(
      StockBatchCorrected(
        stockBatchIdentifier: batch.identifier,
        productIdentifier: batch.productIdentifier,
        quantityDelta: quantityDelta,
        quantityRemaining: actualRemainingQuantity,
        occurredAt: occurredAt,
      ),
    );
  }
}
