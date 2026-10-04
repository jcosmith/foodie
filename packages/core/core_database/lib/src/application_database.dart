import 'package:core_foundation/core_foundation.dart';
import 'package:drift/drift.dart';

import 'application_database.steps.dart';
import 'converters/calendar_date_converter.dart';
import 'tables/barcode_scanning/product_barcodes_dao.dart';
import 'tables/barcode_scanning/product_barcodes_table.dart';
import 'tables/inventory/inventory_dao.dart';
import 'tables/inventory/inventory_tables.dart';
import 'tables/item_pictures/item_pictures_dao.dart';
import 'tables/item_pictures/item_pictures_table.dart';
import 'tables/notifications/scheduled_notification_records_table.dart';
import 'tables/notifications/scheduled_notifications_dao.dart';
import 'tables/preferences/preference_entries_table.dart';
import 'tables/preferences/preferences_dao.dart';
import 'tables/product_catalog/product_catalog_dao.dart';
import 'tables/product_catalog/product_catalog_tables.dart';
import 'tables/restock/restock_dao.dart';
import 'tables/restock/restock_tables.dart';
import 'tables/schema_metadata/schema_metadata_dao.dart';
import 'tables/schema_metadata/schema_metadata_entries_table.dart';
import 'tables/statistics/statistics_dao.dart';
import 'tables/storage_layout/storage_layout_dao.dart';
import 'tables/storage_layout/storage_layout_tables.dart';

part 'application_database.g.dart';

/// The single database of the app (decision D4).
///
/// All tables live here, organised in folders named after the feature that
/// owns them. A feature package only uses the DAOs in its own folder; the
/// statistics module is the one read-only exception.
///
/// Schema changes: bump [schemaVersion], run
/// `dart run drift_dev make-migrations` in this package, and add the step to
/// [migration]. The generated migration tests then check every upgrade path.
@DriftDatabase(
  tables: [
    PreferenceEntries,
    SchemaMetadataEntries,
    StoragePlaces,
    Compartments,
    Categories,
    Products,
    StockBatches,
    InventoryMovements,
    ScheduledNotificationRecords,
    RestockRules,
    ShoppingListEntries,
    ItemPictures,
    ProductBarcodes,
  ],
  daos: [
    PreferencesDao,
    SchemaMetadataDao,
    StorageLayoutDao,
    ProductCatalogDao,
    InventoryDao,
    ScheduledNotificationsDao,
    RestockDao,
    ItemPicturesDao,
    ProductBarcodesDao,
    StatisticsDao,
  ],
)
class ApplicationDatabase extends _$ApplicationDatabase {
  ApplicationDatabase(
    super.executor, {
    Clock clock = const SystemClock(),
    String applicationVersion = 'unknown',
  }) : _clock = clock,
       _applicationVersion = applicationVersion;

  final Clock _clock;
  final String _applicationVersion;

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: stepByStep(
      from1To2: (migrator, schema) async {
        // Phase 1: storage layout, product catalog and inventory.
        await migrator.createTable(schema.freezers);
        await migrator.createTable(schema.compartments);
        await migrator.createTable(schema.categories);
        await migrator.createTable(schema.products);
        await migrator.createTable(schema.stockBatches);
        await migrator.createTable(schema.inventoryMovements);
        await migrator.createIndex(schema.inventoryMovementsByTime);
        await migrator.createIndex(schema.inventoryMovementsByProductAndTime);
        await migrator.createIndex(schema.inventoryMovementsByBatch);
      },
      from2To3: (migrator, schema) async {
        // Phase 3: storage reminders.
        await migrator.createTable(schema.scheduledNotificationRecords);
      },
      from3To4: (migrator, schema) async {
        // Phase 4: restock rules and the shopping list.
        await migrator.createTable(schema.restockRules);
        await migrator.createTable(schema.shoppingListEntries);
      },
      from4To5: (migrator, schema) async {
        // Phase 6: item pictures.
        await migrator.createTable(schema.itemPictures);
        await migrator.createIndex(schema.itemPicturesByOwner);
      },
      from5To6: (migrator, schema) async {
        // Phase 7: learned barcodes.
        await migrator.createTable(schema.productBarcodes);
        await migrator.createIndex(schema.productBarcodesByProduct);
      },
      from6To7: (migrator, schema) async {
        // Issue #17: a default drawer per product.
        await migrator.addColumn(schema.products, schema.products.defaultCompartmentIdentifier);
      },
      from7To8: (migrator, schema) async {
        // Issue #21: a picture as a product's icon.
        await migrator.addColumn(schema.products, schema.products.iconImage);
      },
      from8To9: (migrator, schema) async {
        // Household scope (architecture 10.7 to 10.9): neutral names, the
        // storage domain of categories, opened packages, shelf life after
        // opening, and categories without a shelf life. No data changes shape.
        await customStatement('ALTER TABLE freezers RENAME TO storage_places');
        await customStatement(
          'ALTER TABLE storage_places RENAME COLUMN freezer_identifier TO storage_place_identifier',
        );
        await customStatement(
          'ALTER TABLE compartments RENAME COLUMN freezer_identifier TO storage_place_identifier',
        );
        await customStatement('ALTER TABLE stock_batches RENAME COLUMN frozen_on TO stored_on');
        await migrator.addColumn(schema.stockBatches, schema.stockBatches.openedOn);
        await migrator.addColumn(schema.categories, schema.categories.storageDomain);
        await migrator.addColumn(schema.categories, schema.categories.shelfLifeAfterOpeningDays);
        await migrator.addColumn(schema.products, schema.products.shelfLifeAfterOpeningDays);
        // Supplies keep no time: a category's shelf life may be empty.
        // SQLite cannot drop NOT NULL, so the table is copied.
        await migrator.alterTable(TableMigration(schema.categories));
      },
    ),
    beforeOpen: (openingDetails) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (openingDetails.wasCreated || openingDetails.hadUpgrade) {
        await schemaMetadataDao.recordMigration(
          schemaVersion: openingDetails.versionNow,
          applicationVersion: _applicationVersion,
          migratedAt: _clock.nowUtc(),
        );
      }
    },
  );
}
