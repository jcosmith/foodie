import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'inventory_tables.dart';

part 'inventory_dao.g.dart';

/// Data access for feature_inventory.
@DriftAccessor(tables: [StockBatches, InventoryMovements])
class InventoryDao extends DatabaseAccessor<ApplicationDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.attachedDatabase);

  /// Batches that still hold something, oldest first.
  Stream<List<StockBatchRow>> watchActiveBatches() => _activeBatchesQuery().watch();

  Future<List<StockBatchRow>> readActiveBatches() => _activeBatchesQuery().get();

  SimpleSelectStatement<$StockBatchesTable, StockBatchRow> _activeBatchesQuery() =>
      select(stockBatches)
        ..where((batch) => batch.quantityRemaining.isBiggerThanValue(0))
        ..orderBy([
          (batch) => OrderingTerm.asc(batch.storedOn),
          (batch) => OrderingTerm.asc(batch.createdAt),
        ]);

  Future<StockBatchRow?> readBatch(String stockBatchIdentifier) => (select(
    stockBatches,
  )..where((batch) => batch.stockBatchIdentifier.equals(stockBatchIdentifier))).getSingleOrNull();

  Stream<StockBatchRow?> watchBatch(String stockBatchIdentifier) => (select(
    stockBatches,
  )..where((batch) => batch.stockBatchIdentifier.equals(stockBatchIdentifier))).watchSingleOrNull();

  Future<List<StockBatchRow>> readActiveBatchesInCompartment(String compartmentIdentifier) =>
      (_activeBatchesQuery()
            ..where((batch) => batch.compartmentIdentifier.equals(compartmentIdentifier)))
          .get();

  Future<List<StockBatchRow>> readActiveBatchesOfProduct(String productIdentifier) =>
      (_activeBatchesQuery()..where((batch) => batch.productIdentifier.equals(productIdentifier)))
          .get();

  /// The compartment of the most recently added batch of a product, used to
  /// pre-fill the add form.
  Future<String?> readLastCompartmentOfProduct(String productIdentifier) async {
    final latestBatch =
        await (select(stockBatches)
              ..where((batch) => batch.productIdentifier.equals(productIdentifier))
              ..orderBy([(batch) => OrderingTerm.desc(batch.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return latestBatch?.compartmentIdentifier;
  }

  Future<void> insertBatch(StockBatchRow batch) => into(stockBatches).insert(batch);

  Future<void> updateBatchQuantityRemaining(String stockBatchIdentifier, int quantityRemaining) =>
      (update(stockBatches)
            ..where((batch) => batch.stockBatchIdentifier.equals(stockBatchIdentifier)))
          .write(StockBatchesCompanion(quantityRemaining: Value(quantityRemaining)));

  Future<void> updateBatchCompartment(String stockBatchIdentifier, String compartmentIdentifier) =>
      (update(stockBatches)
            ..where((batch) => batch.stockBatchIdentifier.equals(stockBatchIdentifier)))
          .write(StockBatchesCompanion(compartmentIdentifier: Value(compartmentIdentifier)));

  /// Appends to the movement log. There is deliberately no update or delete.
  Future<void> appendMovement(InventoryMovementRow movement) =>
      into(inventoryMovements).insert(movement);

  Future<InventoryMovementRow?> readMovement(String movementIdentifier) => (select(
    inventoryMovements,
  )..where((movement) => movement.movementIdentifier.equals(movementIdentifier))).getSingleOrNull();

  /// The whole movement log, oldest first, each with its batch's unit (for
  /// exports and statistics).
  Future<List<(InventoryMovementRow, String)>> readAllMovementsWithUnits() async => [
    for (final row in await _movementsWithUnitsQuery().get())
      (row.readTable(inventoryMovements), row.readTable(stockBatches).quantityUnit),
  ];

  /// Movements at or after [occurredFrom], oldest first, with their unit;
  /// emits again whenever movements change.
  Stream<List<(InventoryMovementRow, String)>> watchMovementsWithUnitsSince(DateTime occurredFrom) {
    final query = _movementsWithUnitsQuery()
      ..where(inventoryMovements.occurredAt.isBiggerOrEqualValue(occurredFrom));
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (row.readTable(inventoryMovements), row.readTable(stockBatches).quantityUnit),
      ],
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _movementsWithUnitsQuery() =>
      select(inventoryMovements).join([
        innerJoin(
          stockBatches,
          stockBatches.stockBatchIdentifier.equalsExp(inventoryMovements.stockBatchIdentifier),
        ),
      ])..orderBy([OrderingTerm.asc(inventoryMovements.occurredAt)]);

  Future<List<InventoryMovementRow>> readMovementsOfBatch(String stockBatchIdentifier) =>
      (select(inventoryMovements)
            ..where((movement) => movement.stockBatchIdentifier.equals(stockBatchIdentifier))
            ..orderBy([(movement) => OrderingTerm.asc(movement.occurredAt)]))
          .get();

  /// Whether [movementIdentifier] was already undone by a compensating movement.
  Future<bool> isMovementReversed(String movementIdentifier) async {
    final reversal =
        await (select(inventoryMovements)
              ..where((movement) => movement.reversesMovementIdentifier.equals(movementIdentifier))
              ..limit(1))
            .getSingleOrNull();
    return reversal != null;
  }

  /// Batch identifiers whose remaining quantity differs from the sum of their
  /// movement deltas. Always empty unless something is broken; used by tests
  /// and the debug consistency check.
  Future<List<String>> findInconsistentBatchIdentifiers() async {
    final rows = await customSelect(
      'SELECT b.stock_batch_identifier AS identifier '
      'FROM stock_batches b '
      'LEFT JOIN inventory_movements m ON m.stock_batch_identifier = b.stock_batch_identifier '
      'GROUP BY b.stock_batch_identifier '
      'HAVING b.quantity_remaining != COALESCE(SUM(m.quantity_delta), 0)',
      readsFrom: {stockBatches, inventoryMovements},
    ).get();
    return [for (final row in rows) row.read<String>('identifier')];
  }
}
