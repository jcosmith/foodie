import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';

import '../domain/inventory_movement.dart';
import '../domain/inventory_repository.dart';
import '../domain/stock_batch.dart';

/// Read-only access to stock for other features (reminders, restock,
/// barcode scanning).
final class InventoryQueryService {
  const InventoryQueryService(this._repository);

  final InventoryRepository _repository;

  /// Batches that still hold something, oldest frozen first.
  Stream<List<StockBatch>> watchActiveBatches() => _repository.watchActiveBatches();

  Future<List<StockBatch>> readActiveBatches() => _repository.readActiveBatches();

  Future<StockBatch?> readBatch(StockBatchIdentifier stockBatchIdentifier) =>
      _repository.readBatch(stockBatchIdentifier);

  /// Oldest frozen first, so "take from the oldest bag" is the first entry.
  Future<List<StockBatch>> readActiveBatchesOfProduct(ProductIdentifier productIdentifier) =>
      _repository.readActiveBatchesOfProduct(productIdentifier);

  /// Every addition, removal, move and correction, oldest first.
  Future<List<InventoryMovement>> readMovementHistory() => _repository.readMovementHistory();

  /// Movements at or after [occurredFrom], oldest first, kept up to date
  /// (restock's "runs out in" forecast).
  Stream<List<InventoryMovement>> watchMovementsSince(DateTime occurredFrom) =>
      _repository.watchMovementsSince(occurredFrom);

  /// Where this product went last time, to pre-fill the add form.
  Future<CompartmentIdentifier?> readLastCompartmentOfProduct(
    ProductIdentifier productIdentifier,
  ) => _repository.readLastCompartmentOfProduct(productIdentifier);
}
