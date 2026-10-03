import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ApplicationDatabase database;
  final createdAt = DateTime.utc(2026, 10, 2);

  setUp(() async {
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
        defaultPackageQuantity: 1000,
        isArchived: false,
        createdAt: createdAt,
      ),
    );
  });

  tearDown(() => database.close());

  test('archived compartments keep their default number reserved', () async {
    await database.storageLayoutDao.archiveCompartment('drawer-2');
    expect(await database.storageLayoutDao.nextCompartmentDefaultNumber('freezer-1'), 3);
    expect(await database.storageLayoutDao.readCompartments(), hasLength(1));
    expect(await database.storageLayoutDao.readCompartments(includeArchived: true), hasLength(2));
  });

  test('detects batches whose remaining quantity drifted from the movement log', () async {
    final inventoryDao = database.inventoryDao;
    await inventoryDao.insertBatch(
      StockBatchRow(
        stockBatchIdentifier: 'batch-1',
        productIdentifier: 'product-1',
        compartmentIdentifier: 'drawer-1',
        quantityUnit: 'gram',
        initialQuantity: 1000,
        quantityRemaining: 800,
        frozenOn: CalendarDate(2026, 3, 3),
        createdAt: createdAt,
      ),
    );
    await inventoryDao.appendMovement(
      InventoryMovementRow(
        movementIdentifier: 'movement-1',
        stockBatchIdentifier: 'batch-1',
        productIdentifier: 'product-1',
        compartmentIdentifier: 'drawer-1',
        movementKind: 'added',
        quantityDelta: 1000,
        occurredAt: createdAt,
      ),
    );
    expect(await inventoryDao.findInconsistentBatchIdentifiers(), ['batch-1']);

    await inventoryDao.appendMovement(
      InventoryMovementRow(
        movementIdentifier: 'movement-2',
        stockBatchIdentifier: 'batch-1',
        productIdentifier: 'product-1',
        compartmentIdentifier: 'drawer-1',
        movementKind: 'consumed',
        quantityDelta: -200,
        occurredAt: createdAt,
      ),
    );
    expect(await inventoryDao.findInconsistentBatchIdentifiers(), isEmpty);
    expect((await inventoryDao.readActiveBatches()).single.frozenOn, CalendarDate(2026, 3, 3));
  });

  test('foreign keys are enforced', () async {
    await expectLater(
      database.inventoryDao.insertBatch(
        StockBatchRow(
          stockBatchIdentifier: 'batch-2',
          productIdentifier: 'missing-product',
          compartmentIdentifier: 'drawer-1',
          quantityUnit: 'gram',
          initialQuantity: 1,
          quantityRemaining: 1,
          frozenOn: CalendarDate(2026, 3, 3),
          createdAt: createdAt,
        ),
      ),
      throwsA(anything),
    );
  });
}
