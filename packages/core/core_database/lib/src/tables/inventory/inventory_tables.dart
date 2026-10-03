import 'package:drift/drift.dart';

import '../../converters/calendar_date_converter.dart';
import '../product_catalog/product_catalog_tables.dart';
import '../storage_layout/storage_layout_tables.dart';

/// One physical bag or box with its freezing date, owned by feature_inventory.
@DataClassName('StockBatchRow')
class StockBatches extends Table {
  TextColumn get stockBatchIdentifier => text()();

  TextColumn get productIdentifier => text().references(Products, #productIdentifier)();

  TextColumn get compartmentIdentifier => text().references(Compartments, #compartmentIdentifier)();

  /// The product's canonical unit, copied for self-contained rows; it never
  /// changes once a product has stock (decision D10).
  TextColumn get quantityUnit => text()();

  IntColumn get initialQuantity => integer()();

  /// The fast current state; the movement log is the history.
  IntColumn get quantityRemaining => integer()();

  /// Set when this batch was split off another one.
  TextColumn get parentBatchIdentifier => text().nullable()();

  TextColumn get frozenOn => text().map(const CalendarDateTextConverter())();

  TextColumn get bestBeforeOn => text().map(const CalendarDateTextConverter()).nullable()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {stockBatchIdentifier};
}

/// The append-only movement log: every addition, consumption, discard, move
/// and correction. Rows are never updated or deleted; statistics are computed
/// from this table.
@DataClassName('InventoryMovementRow')
@TableIndex(name: 'inventory_movements_by_time', columns: {#occurredAt})
@TableIndex(
  name: 'inventory_movements_by_product_and_time',
  columns: {#productIdentifier, #occurredAt},
)
@TableIndex(name: 'inventory_movements_by_batch', columns: {#stockBatchIdentifier})
class InventoryMovements extends Table {
  TextColumn get movementIdentifier => text()();

  TextColumn get stockBatchIdentifier => text().references(StockBatches, #stockBatchIdentifier)();

  TextColumn get productIdentifier => text().references(Products, #productIdentifier)();

  TextColumn get compartmentIdentifier => text().references(Compartments, #compartmentIdentifier)();

  /// `added`, `consumed`, `discarded`, `moved` or `corrected`.
  TextColumn get movementKind => text()();

  /// Change of the batch's quantity in the product's base unit; negative for removals.
  IntColumn get quantityDelta => integer()();

  /// `tooOld`, `freezerBurn`, `unwanted` or `other` for discards.
  TextColumn get discardReason => text().nullable()();

  /// Set on a compensating movement (undo); it has the same kind and the
  /// opposite delta, so sums per kind stay correct.
  TextColumn get reversesMovementIdentifier => text().nullable()();

  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {movementIdentifier};
}
