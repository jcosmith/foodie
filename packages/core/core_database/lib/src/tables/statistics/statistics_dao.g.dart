// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_dao.dart';

// ignore_for_file: type=lint
mixin _$StatisticsDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $StoragePlacesTable get storagePlaces => attachedDatabase.storagePlaces;
  $CompartmentsTable get compartments => attachedDatabase.compartments;
  $ProductsTable get products => attachedDatabase.products;
  $StockBatchesTable get stockBatches => attachedDatabase.stockBatches;
  $InventoryMovementsTable get inventoryMovements =>
      attachedDatabase.inventoryMovements;
  StatisticsDaoManager get managers => StatisticsDaoManager(this);
}

class StatisticsDaoManager {
  final _$StatisticsDaoMixin _db;
  StatisticsDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$StoragePlacesTableTableManager get storagePlaces =>
      $$StoragePlacesTableTableManager(_db.attachedDatabase, _db.storagePlaces);
  $$CompartmentsTableTableManager get compartments =>
      $$CompartmentsTableTableManager(_db.attachedDatabase, _db.compartments);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$StockBatchesTableTableManager get stockBatches =>
      $$StockBatchesTableTableManager(_db.attachedDatabase, _db.stockBatches);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(
        _db.attachedDatabase,
        _db.inventoryMovements,
      );
}
