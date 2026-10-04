import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ApplicationDatabase database;
  final createdAt = DateTime.utc(2026, 10, 2);

  setUp(() async {
    database = createInMemoryApplicationDatabase();
    await database.storageLayoutDao.insertStoragePlace(
      StoragePlaceRow(
        storagePlaceIdentifier: 'freezer-1',
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
          storagePlaceIdentifier: 'freezer-1',
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
        storageDomain: 'freezer',
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
        storedOn: CalendarDate(2026, 3, 3),
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
    expect((await inventoryDao.readActiveBatches()).single.storedOn, CalendarDate(2026, 3, 3));
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
          storedOn: CalendarDate(2026, 3, 3),
          createdAt: createdAt,
        ),
      ),
      throwsA(anything),
    );
  });
  test('a batch keeps its stored-on date and an optional opened-on date', () async {
    final inventoryDao = database.inventoryDao;
    await inventoryDao.insertBatch(
      StockBatchRow(
        stockBatchIdentifier: 'batch-3',
        productIdentifier: 'product-1',
        compartmentIdentifier: 'drawer-1',
        quantityUnit: 'gram',
        initialQuantity: 500,
        quantityRemaining: 500,
        storedOn: CalendarDate(2026, 10, 1),
        bestBeforeOn: CalendarDate(2026, 10, 8),
        openedOn: CalendarDate(2026, 10, 2),
        createdAt: createdAt,
      ),
    );
    final batch = (await inventoryDao.readBatch('batch-3'))!;
    expect(batch.storedOn, CalendarDate(2026, 10, 1));
    expect(batch.bestBeforeOn, CalendarDate(2026, 10, 8));
    expect(batch.openedOn, CalendarDate(2026, 10, 2));
  });

  test(
    'categories carry their storage domain; categories and products a shelf life after opening',
    () async {
      final catalogDao = database.productCatalogDao;
      await catalogDao.insertCategory(
        const CategoryRow(
          categoryIdentifier: 'category-2',
          catalogKey: 'dairyAndEggs',
          recommendedMaximumStorageDays: 7,
          shelfLifeAfterOpeningDays: 3,
          iconEmoji: '🥛',
          sortOrder: 1,
          storageDomain: 'fridge',
        ),
      );
      await catalogDao.insertProduct(
        ProductRow(
          productIdentifier: 'product-2',
          categoryIdentifier: 'category-2',
          catalogKey: 'wholeMilk',
          canonicalUnit: 'milliliter',
          recommendedMaximumStorageDays: 10,
          shelfLifeAfterOpeningDays: 3,
          isArchived: false,
          createdAt: createdAt,
        ),
      );
      final category = (await catalogDao.readCategories()).singleWhere(
        (row) => row.categoryIdentifier == 'category-2',
      );
      expect(category.storageDomain, 'fridge');
      expect(category.shelfLifeAfterOpeningDays, 3);
      expect((await catalogDao.readProduct('product-2'))!.shelfLifeAfterOpeningDays, 3);
    },
  );

  test('storage places are stored in the storage_places table', () async {
    final tables = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((row) => row.read<String>('name'))
        .get();
    expect(tables, containsAll(['storage_places', 'compartments', 'stock_batches']));
    expect(tables, isNot(contains('freezers')));
  });
}
