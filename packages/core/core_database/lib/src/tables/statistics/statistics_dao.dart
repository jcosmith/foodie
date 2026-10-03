import 'package:core_foundation/core_foundation.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../../application_database.dart';
import '../inventory/inventory_tables.dart';
import '../product_catalog/product_catalog_tables.dart';

part 'statistics_dao.g.dart';

/// Movements of one local day that share kind, product, compartment, unit,
/// discard reason and storage age, summed.
///
/// Quantities are positive for every kind: what was added, eaten, thrown
/// away or moved. Undone removals cancel out, because their compensating
/// movement has the same kind and the opposite delta.
@immutable
final class MovementDailyAggregateRow {
  const MovementDailyAggregateRow({
    required this.localDay,
    required this.movementKind,
    required this.productIdentifier,
    required this.categoryIdentifier,
    required this.compartmentIdentifier,
    required this.quantityUnit,
    required this.discardReason,
    required this.storedDays,
    required this.quantityInBaseUnits,
    required this.movementCount,
  });

  /// The day in the device's time zone.
  final CalendarDate localDay;

  /// `added`, `consumed`, `discarded` or `moved`.
  final String movementKind;
  final String productIdentifier;

  /// The product's current category.
  final String categoryIdentifier;

  /// Where it happened; for moves, the destination.
  final String compartmentIdentifier;
  final String quantityUnit;
  final String? discardReason;

  /// Whole days between the batch's freezing date and [localDay].
  final int storedDays;
  final int quantityInBaseUnits;

  /// Number of movements, net of undone ones.
  final int movementCount;

  @override
  bool operator ==(Object other) =>
      other is MovementDailyAggregateRow &&
      other.localDay == localDay &&
      other.movementKind == movementKind &&
      other.productIdentifier == productIdentifier &&
      other.categoryIdentifier == categoryIdentifier &&
      other.compartmentIdentifier == compartmentIdentifier &&
      other.quantityUnit == quantityUnit &&
      other.discardReason == discardReason &&
      other.storedDays == storedDays &&
      other.quantityInBaseUnits == quantityInBaseUnits &&
      other.movementCount == movementCount;

  @override
  int get hashCode => Object.hash(
    localDay,
    movementKind,
    productIdentifier,
    categoryIdentifier,
    compartmentIdentifier,
    quantityUnit,
    discardReason,
    storedDays,
    quantityInBaseUnits,
    movementCount,
  );

  @override
  String toString() =>
      'MovementDailyAggregateRow($localDay, $movementKind, $productIdentifier, '
      '$quantityInBaseUnits $quantityUnit, $movementCount×)';
}

/// Read-only aggregates over the movement log for feature_statistics, the
/// one feature allowed to read other features' tables (decision D4). It has
/// no write methods on purpose.
@DriftAccessor(tables: [StockBatches, InventoryMovements, Products])
class StatisticsDao extends DatabaseAccessor<ApplicationDatabase> with _$StatisticsDaoMixin {
  StatisticsDao(super.attachedDatabase);

  /// Daily aggregates of the movements that happened from [occurredFrom]
  /// (inclusive) to [occurredBefore] (exclusive), oldest day first. Updates
  /// whenever a movement, batch or product changes.
  ///
  /// Corrections are left out: they fix a count, they are not activity.
  /// Moves count once, on the incoming side.
  Stream<List<MovementDailyAggregateRow>> watchDailyMovementAggregates({
    required DateTime occurredFrom,
    required DateTime occurredBefore,
  }) =>
      customSelect(
        'SELECT date(m.occurred_at, \'localtime\') AS local_day, '
        'm.movement_kind AS movement_kind, '
        'm.product_identifier AS product_identifier, '
        'p.category_identifier AS category_identifier, '
        'm.compartment_identifier AS compartment_identifier, '
        'b.quantity_unit AS quantity_unit, '
        'm.discard_reason AS discard_reason, '
        'CAST(julianday(date(m.occurred_at, \'localtime\')) - julianday(b.frozen_on) AS INTEGER) '
        'AS stored_days, '
        'SUM(CASE WHEN m.movement_kind IN (\'added\', \'moved\') '
        'THEN m.quantity_delta ELSE -m.quantity_delta END) AS quantity_in_base_units, '
        'SUM(CASE WHEN m.reverses_movement_identifier IS NULL THEN 1 ELSE -1 END) '
        'AS movement_count '
        'FROM inventory_movements m '
        'INNER JOIN stock_batches b ON b.stock_batch_identifier = m.stock_batch_identifier '
        'INNER JOIN products p ON p.product_identifier = m.product_identifier '
        'WHERE m.occurred_at >= ?1 AND m.occurred_at < ?2 '
        'AND m.movement_kind IN (\'added\', \'consumed\', \'discarded\', \'moved\') '
        'AND (m.movement_kind != \'moved\' OR m.quantity_delta > 0) '
        'GROUP BY local_day, m.movement_kind, m.product_identifier, m.compartment_identifier, '
        'b.quantity_unit, m.discard_reason, stored_days '
        'HAVING movement_count != 0 OR quantity_in_base_units != 0 '
        'ORDER BY local_day',
        variables: [
          Variable<DateTime>(occurredFrom.toUtc()),
          Variable<DateTime>(occurredBefore.toUtc()),
        ],
        readsFrom: {inventoryMovements, stockBatches, products},
      ).watch().map(
        (rows) => [
          for (final row in rows)
            MovementDailyAggregateRow(
              localDay: CalendarDate.parseIso8601(row.read<String>('local_day')),
              movementKind: row.read<String>('movement_kind'),
              productIdentifier: row.read<String>('product_identifier'),
              categoryIdentifier: row.read<String>('category_identifier'),
              compartmentIdentifier: row.read<String>('compartment_identifier'),
              quantityUnit: row.read<String>('quantity_unit'),
              discardReason: row.readNullable<String>('discard_reason'),
              storedDays: row.read<int>('stored_days'),
              quantityInBaseUnits: row.read<int>('quantity_in_base_units'),
              movementCount: row.read<int>('movement_count'),
            ),
        ],
      );

  /// When the first movement happened, for the "All time" period; `null`
  /// while the log is empty.
  Stream<DateTime?> watchFirstMovementTime() {
    final firstOccurredAt = inventoryMovements.occurredAt.min();
    return (selectOnly(
      inventoryMovements,
    )..addColumns([firstOccurredAt])).map((row) => row.read(firstOccurredAt)).watchSingle();
  }
}
