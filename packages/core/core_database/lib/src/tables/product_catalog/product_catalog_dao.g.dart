// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_catalog_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductCatalogDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $FreezersTable get freezers => attachedDatabase.freezers;
  $CompartmentsTable get compartments => attachedDatabase.compartments;
  $ProductsTable get products => attachedDatabase.products;
  ProductCatalogDaoManager get managers => ProductCatalogDaoManager(this);
}

class ProductCatalogDaoManager {
  final _$ProductCatalogDaoMixin _db;
  ProductCatalogDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$FreezersTableTableManager get freezers =>
      $$FreezersTableTableManager(_db.attachedDatabase, _db.freezers);
  $$CompartmentsTableTableManager get compartments =>
      $$CompartmentsTableTableManager(_db.attachedDatabase, _db.compartments);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
}
