import 'package:riverpod/riverpod.dart';

import 'application_database.dart';
import 'backup/database_backup_gateway.dart';
import 'tables/inventory/inventory_dao.dart';
import 'tables/preferences/preferences_dao.dart';
import 'tables/product_catalog/product_catalog_dao.dart';
import 'tables/storage_layout/storage_layout_dao.dart';
import 'transaction_runner.dart';

/// The open application database. The app shell overrides this provider with
/// the database it opened at start-up; tests override it with an in-memory one.
final applicationDatabaseProvider = Provider<ApplicationDatabase>(
  (ref) => throw UnimplementedError('applicationDatabaseProvider must be overridden'),
);

final databaseBackupGatewayProvider = Provider<DatabaseBackupGateway>(
  (ref) => DatabaseBackupGateway(ref.watch(applicationDatabaseProvider)),
);

final transactionRunnerProvider = Provider<TransactionRunner>(
  (ref) => DriftTransactionRunner(ref.watch(applicationDatabaseProvider)),
);

final preferencesDaoProvider = Provider<PreferencesDao>(
  (ref) => ref.watch(applicationDatabaseProvider).preferencesDao,
);

final storageLayoutDaoProvider = Provider<StorageLayoutDao>(
  (ref) => ref.watch(applicationDatabaseProvider).storageLayoutDao,
);

final productCatalogDaoProvider = Provider<ProductCatalogDao>(
  (ref) => ref.watch(applicationDatabaseProvider).productCatalogDao,
);

final inventoryDaoProvider = Provider<InventoryDao>(
  (ref) => ref.watch(applicationDatabaseProvider).inventoryDao,
);
