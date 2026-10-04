import 'package:core_foundation/core_foundation.dart';

import '../../domain/inventory_events.dart';
import '../../domain/inventory_failure.dart';
import '../../domain/stock_batch.dart';
import 'inventory_use_case_dependencies.dart';

/// "Mark as opened": records today as the opened-on day, so the product's
/// shelf life after opening counts from now. Never a required step; with
/// `isOpened: false` it takes the mark back (the snackbar's undo).
final class MarkStockBatchOpenedUseCase {
  const MarkStockBatchOpenedUseCase({required InventoryUseCaseDependencies dependencies})
    : _dependencies = dependencies;

  final InventoryUseCaseDependencies _dependencies;

  Future<Result<Unit, InventoryFailure>> execute(
    StockBatchIdentifier stockBatchIdentifier, {
    bool isOpened = true,
  }) async {
    final result = await _dependencies.transactionRunner.runInTransaction(
      () => _mark(stockBatchIdentifier, isOpened: isOpened),
    );
    if (result case SuccessfulResult(value: final event)) {
      await _dependencies.domainEventBus.publish(event);
    }
    return result.mapValue((_) => unit);
  }

  Future<Result<StockBatchOpened, InventoryFailure>> _mark(
    StockBatchIdentifier stockBatchIdentifier, {
    required bool isOpened,
  }) async {
    final batch = await _dependencies.repository.readBatch(stockBatchIdentifier);
    if (batch == null || batch.isDepleted) return const Result.failure(StockBatchNotFound());
    final openedOn = isOpened ? _dependencies.clock.todayLocal() : null;
    await _dependencies.repository.updateDates(
      stockBatchIdentifier,
      storedOn: batch.storedOn,
      bestBeforeOn: batch.bestBeforeOn,
      openedOn: openedOn,
    );
    return Result.success(
      StockBatchOpened(
        stockBatchIdentifier: stockBatchIdentifier,
        productIdentifier: batch.productIdentifier,
        openedOn: openedOn,
        occurredAt: _dependencies.clock.nowUtc(),
      ),
    );
  }
}
