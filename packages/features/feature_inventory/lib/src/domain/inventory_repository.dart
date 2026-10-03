import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';

import 'inventory_movement.dart';
import 'stock_batch.dart';

/// Storage of stock batches and the movement log, on the inventory DAO.
///
/// Writes that belong together (a batch and its movement) are wrapped in a
/// transaction by the use case.
abstract interface class InventoryRepository {
  /// Batches that still hold something, oldest frozen first.
  Stream<List<StockBatch>> watchActiveBatches();

  Future<List<StockBatch>> readActiveBatches();

  Future<StockBatch?> readBatch(StockBatchIdentifier stockBatchIdentifier);

  Future<List<StockBatch>> readActiveBatchesInCompartment(
    CompartmentIdentifier compartmentIdentifier,
  );

  /// Oldest frozen first, for "take from the oldest bag".
  Future<List<StockBatch>> readActiveBatchesOfProduct(ProductIdentifier productIdentifier);

  /// Where the most recently added batch of a product went.
  Future<CompartmentIdentifier?> readLastCompartmentOfProduct(ProductIdentifier productIdentifier);

  Future<void> insertBatch(StockBatch batch);

  Future<void> updateQuantityRemaining(
    StockBatchIdentifier stockBatchIdentifier,
    int quantityRemainingInBaseUnits,
  );

  Future<void> updateCompartment(
    StockBatchIdentifier stockBatchIdentifier,
    CompartmentIdentifier compartmentIdentifier,
  );

  Future<void> appendMovement(InventoryMovement movement);

  Future<InventoryMovement?> readMovement(InventoryMovementIdentifier movementIdentifier);

  /// The whole movement log, oldest first.
  Future<List<InventoryMovement>> readMovementHistory();

  /// Movements at or after [occurredFrom], oldest first, kept up to date.
  Stream<List<InventoryMovement>> watchMovementsSince(DateTime occurredFrom);

  Future<bool> isMovementReversed(InventoryMovementIdentifier movementIdentifier);

  /// Batches whose remaining amount differs from the sum of their movements;
  /// always empty unless something is broken.
  Future<List<StockBatchIdentifier>> findInconsistentBatches();
}
