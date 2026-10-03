// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restock_dao.dart';

// ignore_for_file: type=lint
mixin _$RestockDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $FreezersTable get freezers => attachedDatabase.freezers;
  $CompartmentsTable get compartments => attachedDatabase.compartments;
  $ProductsTable get products => attachedDatabase.products;
  $RestockRulesTable get restockRules => attachedDatabase.restockRules;
  $ShoppingListEntriesTable get shoppingListEntries =>
      attachedDatabase.shoppingListEntries;
  RestockDaoManager get managers => RestockDaoManager(this);
}

class RestockDaoManager {
  final _$RestockDaoMixin _db;
  RestockDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$FreezersTableTableManager get freezers =>
      $$FreezersTableTableManager(_db.attachedDatabase, _db.freezers);
  $$CompartmentsTableTableManager get compartments =>
      $$CompartmentsTableTableManager(_db.attachedDatabase, _db.compartments);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$RestockRulesTableTableManager get restockRules =>
      $$RestockRulesTableTableManager(_db.attachedDatabase, _db.restockRules);
  $$ShoppingListEntriesTableTableManager get shoppingListEntries =>
      $$ShoppingListEntriesTableTableManager(
        _db.attachedDatabase,
        _db.shoppingListEntries,
      );
}
