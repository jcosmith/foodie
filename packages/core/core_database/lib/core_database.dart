/// The single encrypted database of the app: tables and DAOs organised by
/// owning feature, migrations, encryption and transactions.
library;

export 'src/application_database.dart'
    show
        ApplicationDatabase,
        CategoryRow,
        CompartmentRow,
        StoragePlaceRow,
        InventoryMovementRow,
        ItemPictureRow,
        ProductBarcodeRow,
        ProductRow,
        RestockRuleRow,
        ScheduledNotificationRecordRow,
        ShoppingListEntryRow,
        StockBatchRow;
export 'src/backup/database_backup_gateway.dart';
export 'src/database_providers.dart';
export 'src/encryption/database_encryption_key.dart';
export 'src/encryption/database_encryption_key_store.dart';
export 'src/encryption/encrypted_database_opener.dart';
export 'src/encryption/sqlcipher_setup.dart' show SqlCipherUnavailableException;
export 'src/tables/barcode_scanning/product_barcodes_dao.dart';
export 'src/tables/inventory/inventory_dao.dart';
export 'src/tables/item_pictures/item_pictures_dao.dart';
export 'src/tables/notifications/scheduled_notifications_dao.dart';
export 'src/tables/preferences/preferences_dao.dart';
export 'src/tables/product_catalog/product_catalog_dao.dart';
export 'src/tables/restock/restock_dao.dart';
export 'src/tables/schema_metadata/schema_metadata_dao.dart';
export 'src/tables/statistics/statistics_dao.dart';
export 'src/tables/storage_layout/storage_layout_dao.dart';
export 'src/transaction_runner.dart';
