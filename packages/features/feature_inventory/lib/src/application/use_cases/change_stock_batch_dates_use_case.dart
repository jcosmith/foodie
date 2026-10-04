import 'package:core_foundation/core_foundation.dart';

import '../../domain/inventory_events.dart';
import '../../domain/inventory_failure.dart';
import '../../domain/stock_batch.dart';
import 'inventory_use_case_dependencies.dart';

/// "Edit dates": fixes the stored-on, best-before and opened-on dates of a
/// batch, for typing mistakes or food put away or opened earlier. Amounts
/// do not change, so nothing is written to the movement log.
final class ChangeStockBatchDatesUseCase {
  const ChangeStockBatchDatesUseCase({required InventoryUseCaseDependencies dependencies})
    : _dependencies = dependencies;

  final InventoryUseCaseDependencies _dependencies;

  Future<Result<Unit, InventoryFailure>> execute(
    StockBatchIdentifier stockBatchIdentifier, {
    required CalendarDate storedOn,
    required CalendarDate? bestBeforeOn,
    required CalendarDate? openedOn,
  }) async {
    final today = _dependencies.clock.todayLocal();
    if (storedOn.isAfter(today)) return const Result.failure(StoredOnInFuture());
    if (openedOn != null) {
      if (openedOn.isAfter(today)) return const Result.failure(OpenedOnInFuture());
      if (openedOn.isBefore(storedOn)) return const Result.failure(OpenedBeforeStored());
    }
    final result = await _dependencies.transactionRunner.runInTransaction(() async {
      final batch = await _dependencies.repository.readBatch(stockBatchIdentifier);
      if (batch == null || batch.isDepleted) {
        return const Result<StockBatchDatesChanged, InventoryFailure>.failure(StockBatchNotFound());
      }
      await _dependencies.repository.updateDates(
        stockBatchIdentifier,
        storedOn: storedOn,
        bestBeforeOn: bestBeforeOn,
        openedOn: openedOn,
      );
      return Result<StockBatchDatesChanged, InventoryFailure>.success(
        StockBatchDatesChanged(
          stockBatchIdentifier: stockBatchIdentifier,
          productIdentifier: batch.productIdentifier,
          occurredAt: _dependencies.clock.nowUtc(),
        ),
      );
    });
    if (result case SuccessfulResult(value: final event)) {
      await _dependencies.domainEventBus.publish(event);
    }
    return result.mapValue((_) => unit);
  }
}
