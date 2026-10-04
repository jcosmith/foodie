// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_barcodes_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductBarcodesDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $StoragePlacesTable get storagePlaces => attachedDatabase.storagePlaces;
  $CompartmentsTable get compartments => attachedDatabase.compartments;
  $ProductsTable get products => attachedDatabase.products;
  $ProductBarcodesTable get productBarcodes => attachedDatabase.productBarcodes;
  ProductBarcodesDaoManager get managers => ProductBarcodesDaoManager(this);
}

class ProductBarcodesDaoManager {
  final _$ProductBarcodesDaoMixin _db;
  ProductBarcodesDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$StoragePlacesTableTableManager get storagePlaces =>
      $$StoragePlacesTableTableManager(_db.attachedDatabase, _db.storagePlaces);
  $$CompartmentsTableTableManager get compartments =>
      $$CompartmentsTableTableManager(_db.attachedDatabase, _db.compartments);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$ProductBarcodesTableTableManager get productBarcodes =>
      $$ProductBarcodesTableTableManager(
        _db.attachedDatabase,
        _db.productBarcodes,
      );
}
