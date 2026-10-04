import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';

import '../domain/inventory_movement.dart';
import '../domain/inventory_repository.dart';
import '../domain/stock_batch.dart';

/// [InventoryRepository] on top of the inventory DAO.
final class DriftInventoryRepository implements InventoryRepository {
  const DriftInventoryRepository(this._inventoryDao);

  final InventoryDao _inventoryDao;

  @override
  Stream<List<StockBatch>> watchActiveBatches() =>
      _inventoryDao.watchActiveBatches().map((rows) => rows.map(_batchFromRow).toList());

  @override
  Future<List<StockBatch>> readActiveBatches() async =>
      (await _inventoryDao.readActiveBatches()).map(_batchFromRow).toList();

  @override
  Future<StockBatch?> readBatch(StockBatchIdentifier stockBatchIdentifier) async {
    final row = await _inventoryDao.readBatch(stockBatchIdentifier.value);
    return row == null ? null : _batchFromRow(row);
  }

  @override
  Future<List<StockBatch>> readActiveBatchesInCompartment(
    CompartmentIdentifier compartmentIdentifier,
  ) async => (await _inventoryDao.readActiveBatchesInCompartment(
    compartmentIdentifier.value,
  )).map(_batchFromRow).toList();

  @override
  Future<List<StockBatch>> readActiveBatchesOfProduct(ProductIdentifier productIdentifier) async =>
      (await _inventoryDao.readActiveBatchesOfProduct(
        productIdentifier.value,
      )).map(_batchFromRow).toList();

  @override
  Future<CompartmentIdentifier?> readLastCompartmentOfProduct(
    ProductIdentifier productIdentifier,
  ) async {
    final compartmentIdentifier = await _inventoryDao.readLastCompartmentOfProduct(
      productIdentifier.value,
    );
    return compartmentIdentifier == null ? null : CompartmentIdentifier(compartmentIdentifier);
  }

  @override
  Future<void> insertBatch(StockBatch batch) => _inventoryDao.insertBatch(
    StockBatchRow(
      stockBatchIdentifier: batch.identifier.value,
      productIdentifier: batch.productIdentifier.value,
      compartmentIdentifier: batch.compartmentIdentifier.value,
      quantityUnit: batch.unit.storageName,
      initialQuantity: batch.initialQuantity.amountInBaseUnits,
      quantityRemaining: batch.quantityRemaining.amountInBaseUnits,
      parentBatchIdentifier: batch.parentBatchIdentifier?.value,
      storedOn: batch.storedOn,
      bestBeforeOn: batch.bestBeforeOn,
      openedOn: batch.openedOn,
      note: batch.note,
      createdAt: batch.createdAt,
    ),
  );

  @override
  Future<void> updateQuantityRemaining(
    StockBatchIdentifier stockBatchIdentifier,
    int quantityRemainingInBaseUnits,
  ) => _inventoryDao.updateBatchQuantityRemaining(
    stockBatchIdentifier.value,
    quantityRemainingInBaseUnits,
  );

  @override
  Future<void> updateCompartment(
    StockBatchIdentifier stockBatchIdentifier,
    CompartmentIdentifier compartmentIdentifier,
  ) =>
      _inventoryDao.updateBatchCompartment(stockBatchIdentifier.value, compartmentIdentifier.value);

  @override
  Future<void> updateDates(
    StockBatchIdentifier stockBatchIdentifier, {
    required CalendarDate storedOn,
    required CalendarDate? bestBeforeOn,
    required CalendarDate? openedOn,
  }) => _inventoryDao.updateBatchDates(
    stockBatchIdentifier.value,
    storedOn: storedOn,
    bestBeforeOn: bestBeforeOn,
    openedOn: openedOn,
  );

  @override
  Future<void> appendMovement(InventoryMovement movement) => _inventoryDao.appendMovement(
    InventoryMovementRow(
      movementIdentifier: movement.identifier.value,
      stockBatchIdentifier: movement.stockBatchIdentifier.value,
      productIdentifier: movement.productIdentifier.value,
      compartmentIdentifier: movement.compartmentIdentifier.value,
      movementKind: movement.kind.storageName,
      quantityDelta: movement.quantityDelta.amountInBaseUnits,
      discardReason: movement.discardReason?.storageName,
      reversesMovementIdentifier: movement.reversesMovementIdentifier?.value,
      occurredAt: movement.occurredAt,
    ),
  );

  @override
  Future<InventoryMovement?> readMovement(InventoryMovementIdentifier movementIdentifier) async {
    final row = await _inventoryDao.readMovement(movementIdentifier.value);
    if (row == null) return null;
    final batch = await _inventoryDao.readBatch(row.stockBatchIdentifier);
    final unit = batch == null
        ? QuantityUnit.gram
        : QuantityUnit.fromStorageName(batch.quantityUnit);
    return _movementFromRow(row, unit);
  }

  @override
  Future<List<InventoryMovement>> readMovementHistory() async => [
    for (final (row, unitStorageName) in await _inventoryDao.readAllMovementsWithUnits())
      _movementFromRow(row, QuantityUnit.fromStorageName(unitStorageName)),
  ];

  @override
  Future<List<InventoryMovement>> readMovementsOfProduct(
    ProductIdentifier productIdentifier,
  ) async => [
    for (final (row, unitStorageName) in await _inventoryDao.readMovementsWithUnitsOfProduct(
      productIdentifier.value,
    ))
      _movementFromRow(row, QuantityUnit.fromStorageName(unitStorageName)),
  ];

  @override
  Stream<List<InventoryMovement>> watchMovementsSince(DateTime occurredFrom) => _inventoryDao
      .watchMovementsWithUnitsSince(occurredFrom)
      .map(
        (rows) => [
          for (final (row, unitStorageName) in rows)
            _movementFromRow(row, QuantityUnit.fromStorageName(unitStorageName)),
        ],
      );

  static InventoryMovement _movementFromRow(InventoryMovementRow row, QuantityUnit unit) =>
      InventoryMovement(
        identifier: InventoryMovementIdentifier(row.movementIdentifier),
        stockBatchIdentifier: StockBatchIdentifier(row.stockBatchIdentifier),
        productIdentifier: ProductIdentifier(row.productIdentifier),
        compartmentIdentifier: CompartmentIdentifier(row.compartmentIdentifier),
        kind: MovementKind.fromStorageName(row.movementKind),
        quantityDelta: Quantity(amountInBaseUnits: row.quantityDelta, unit: unit),
        discardReason: switch (row.discardReason) {
          final discardReason? => DiscardReason.fromStorageName(discardReason),
          null => null,
        },
        reversesMovementIdentifier: switch (row.reversesMovementIdentifier) {
          final reversedIdentifier? => InventoryMovementIdentifier(reversedIdentifier),
          null => null,
        },
        occurredAt: row.occurredAt,
      );

  @override
  Future<bool> isMovementReversed(InventoryMovementIdentifier movementIdentifier) =>
      _inventoryDao.isMovementReversed(movementIdentifier.value);

  @override
  Future<List<StockBatchIdentifier>> findInconsistentBatches() async => [
    for (final identifier in await _inventoryDao.findInconsistentBatchIdentifiers())
      StockBatchIdentifier(identifier),
  ];

  static StockBatch _batchFromRow(StockBatchRow row) {
    final unit = QuantityUnit.fromStorageName(row.quantityUnit);
    return StockBatch(
      identifier: StockBatchIdentifier(row.stockBatchIdentifier),
      productIdentifier: ProductIdentifier(row.productIdentifier),
      compartmentIdentifier: CompartmentIdentifier(row.compartmentIdentifier),
      initialQuantity: Quantity(amountInBaseUnits: row.initialQuantity, unit: unit),
      quantityRemaining: Quantity(amountInBaseUnits: row.quantityRemaining, unit: unit),
      parentBatchIdentifier: switch (row.parentBatchIdentifier) {
        final parentIdentifier? => StockBatchIdentifier(parentIdentifier),
        null => null,
      },
      storedOn: row.storedOn,
      bestBeforeOn: row.bestBeforeOn,
      openedOn: row.openedOn,
      note: row.note,
      createdAt: row.createdAt,
    );
  }
}
