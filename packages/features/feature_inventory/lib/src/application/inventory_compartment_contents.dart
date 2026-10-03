import 'package:core_events/core_events.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';

import '../domain/inventory_repository.dart';
import 'use_cases/move_stock_batch_use_case.dart';

/// Tells the storage layout what is stored where, and moves everything out
/// of a compartment that is being removed. Bound to the layout's
/// [compartmentContentsPortProvider] by the inventory module.
final class InventoryCompartmentContents implements CompartmentContentsPort {
  const InventoryCompartmentContents({
    required InventoryRepository repository,
    required StockBatchMover stockBatchMover,
  }) : _repository = repository,
       _stockBatchMover = stockBatchMover;

  final InventoryRepository _repository;
  final StockBatchMover _stockBatchMover;

  @override
  Stream<Map<CompartmentIdentifier, int>> watchItemCountsByCompartment() =>
      _repository.watchActiveBatches().map((batches) {
        final itemCounts = <CompartmentIdentifier, int>{};
        for (final batch in batches) {
          itemCounts.update(batch.compartmentIdentifier, (count) => count + 1, ifAbsent: () => 1);
        }
        return itemCounts;
      });

  @override
  Future<int> countItemsInCompartment(CompartmentIdentifier compartmentIdentifier) async =>
      (await _repository.readActiveBatchesInCompartment(compartmentIdentifier)).length;

  @override
  Future<List<DomainEvent>> moveAllContents({
    required CompartmentIdentifier sourceCompartmentIdentifier,
    required CompartmentIdentifier destinationCompartmentIdentifier,
  }) async => [
    for (final batch in await _repository.readActiveBatchesInCompartment(
      sourceCompartmentIdentifier,
    ))
      await _stockBatchMover.moveWholeBatch(batch, destinationCompartmentIdentifier),
  ];
}
