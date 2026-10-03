import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ApplicationDatabase database;
  final createdAt = DateTime.utc(2026, 9, 1);
  var movementNumber = 0;

  Future<void> appendMovement({
    required String batch,
    required String compartment,
    required String kind,
    required int delta,
    required DateTime occurredAt,
    String? discardReason,
    String? reverses,
  }) => database.inventoryDao.appendMovement(
    InventoryMovementRow(
      movementIdentifier: 'movement-${++movementNumber}',
      stockBatchIdentifier: batch,
      productIdentifier: 'product-1',
      compartmentIdentifier: compartment,
      movementKind: kind,
      quantityDelta: delta,
      discardReason: discardReason,
      reversesMovementIdentifier: reverses,
      occurredAt: occurredAt,
    ),
  );

  Future<void> insertBatch(String identifier, String compartment) =>
      database.inventoryDao.insertBatch(
        StockBatchRow(
          stockBatchIdentifier: identifier,
          productIdentifier: 'product-1',
          compartmentIdentifier: compartment,
          quantityUnit: 'gram',
          initialQuantity: 1000,
          quantityRemaining: 0,
          frozenOn: CalendarDate(2026, 9, 1),
          createdAt: createdAt,
        ),
      );

  setUp(() async {
    movementNumber = 0;
    database = createInMemoryApplicationDatabase();
    await database.storageLayoutDao.insertFreezer(
      FreezerRow(
        freezerIdentifier: 'freezer-1',
        defaultNameKey: 'kitchen_freezer',
        storageKind: 'upright',
        sortOrder: 0,
        isArchived: false,
        createdAt: createdAt,
      ),
    );
    for (final number in [1, 2]) {
      await database.storageLayoutDao.insertCompartment(
        CompartmentRow(
          compartmentIdentifier: 'drawer-$number',
          freezerIdentifier: 'freezer-1',
          defaultNumber: number,
          colorTagIndex: number - 1,
          sortOrder: number,
          isArchived: false,
          createdAt: createdAt,
        ),
      );
    }
    await database.productCatalogDao.insertCategory(
      const CategoryRow(
        categoryIdentifier: 'category-1',
        catalogKey: 'vegetables',
        recommendedMaximumStorageDays: 365,
        iconEmoji: '🥦',
        sortOrder: 0,
      ),
    );
    await database.productCatalogDao.insertProduct(
      ProductRow(
        productIdentifier: 'product-1',
        categoryIdentifier: 'category-1',
        catalogKey: 'spinach',
        canonicalUnit: 'gram',
        isArchived: false,
        createdAt: createdAt,
      ),
    );
    await insertBatch('batch-1', 'drawer-1');
    await insertBatch('batch-2', 'drawer-2');
  });

  tearDown(() => database.close());

  Future<List<MovementDailyAggregateRow>> readAggregates() => database.statisticsDao
      .watchDailyMovementAggregates(
        occurredFrom: DateTime.utc(2026, 9, 1),
        occurredBefore: DateTime.utc(2026, 10, 1),
      )
      .first;

  test('sums each kind as a positive amount per day and leaves out undone removals', () async {
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'added',
      delta: 1000,
      occurredAt: DateTime.utc(2026, 9, 1, 10),
    );
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'consumed',
      delta: -200,
      occurredAt: DateTime.utc(2026, 9, 20, 10),
    );
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'consumed',
      delta: -100,
      occurredAt: DateTime.utc(2026, 9, 20, 18),
    );
    // Eaten and undone on the 21st: nothing remains.
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'consumed',
      delta: -50,
      occurredAt: DateTime.utc(2026, 9, 21, 12),
    );
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'consumed',
      delta: 50,
      reverses: 'movement-4',
      occurredAt: DateTime.utc(2026, 9, 21, 12, 1),
    );
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'discarded',
      delta: -100,
      discardReason: 'tooOld',
      occurredAt: DateTime.utc(2026, 9, 22, 12),
    );
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'corrected',
      delta: -10,
      occurredAt: DateTime.utc(2026, 9, 22, 13),
    );
    // A move counts once, in its destination.
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'moved',
      delta: -300,
      occurredAt: DateTime.utc(2026, 9, 23, 12),
    );
    await appendMovement(
      batch: 'batch-2',
      compartment: 'drawer-2',
      kind: 'moved',
      delta: 300,
      occurredAt: DateTime.utc(2026, 9, 23, 12),
    );
    // Outside the period.
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'consumed',
      delta: -10,
      occurredAt: DateTime.utc(2026, 10, 1, 12),
    );

    final aggregates = await readAggregates();

    expect(
      [
        for (final row in aggregates)
          (
            row.localDay.toIso8601String(),
            row.movementKind,
            row.compartmentIdentifier,
            row.quantityInBaseUnits,
            row.movementCount,
            row.storedDays,
            row.discardReason,
          ),
      ],
      [
        ('2026-09-01', 'added', 'drawer-1', 1000, 1, 0, null),
        ('2026-09-20', 'consumed', 'drawer-1', 300, 2, 19, null),
        ('2026-09-22', 'discarded', 'drawer-1', 100, 1, 21, 'tooOld'),
        ('2026-09-23', 'moved', 'drawer-2', 300, 1, 22, null),
      ],
    );
    expect(aggregates.first.categoryIdentifier, 'category-1');
    expect(aggregates.first.quantityUnit, 'gram');
  });

  test('reports when the movement log starts', () async {
    expect(await database.statisticsDao.watchFirstMovementTime().first, isNull);
    await appendMovement(
      batch: 'batch-1',
      compartment: 'drawer-1',
      kind: 'added',
      delta: 1000,
      occurredAt: DateTime.utc(2026, 9, 3, 10),
    );
    expect(
      await database.statisticsDao.watchFirstMovementTime().first,
      DateTime.utc(2026, 9, 3, 10),
    );
  });
}
