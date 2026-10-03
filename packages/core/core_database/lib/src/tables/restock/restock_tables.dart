import 'package:drift/drift.dart';

import '../product_catalog/product_catalog_tables.dart';

/// How much of a product the user wants to keep, owned by feature_restock.
@DataClassName('RestockRuleRow')
class RestockRules extends Table {
  TextColumn get productIdentifier => text().references(Products, #productIdentifier)();

  /// The product's canonical unit, copied for self-contained rows.
  TextColumn get quantityUnit => text()();

  /// Below this, in base units, the product is running low.
  IntColumn get minimumQuantity => integer()();

  /// What to buy up to; `null` means up to the minimum, at least one package.
  IntColumn get targetQuantity => integer().nullable()();

  BoolColumn get isActive => boolean()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {productIdentifier};
}

/// The shopping list: entries the user added and entries restock rules added.
@DataClassName('ShoppingListEntryRow')
class ShoppingListEntries extends Table {
  TextColumn get shoppingListEntryIdentifier => text()();

  TextColumn get productIdentifier => text().references(Products, #productIdentifier).nullable()();

  /// For something that is not a product in the catalog.
  TextColumn get freeTextName => text().nullable()();

  /// `null` for free text entries.
  TextColumn get quantityUnit => text().nullable()();

  /// In base units of [quantityUnit]; `null` for free text entries.
  IntColumn get requestedQuantity => integer().nullable()();

  /// `manual` or `restock`.
  TextColumn get origin => text()();

  DateTimeColumn get createdAt => dateTime()();

  /// Set while the entry is ticked as bought.
  DateTimeColumn get checkedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {shoppingListEntryIdentifier};
}
