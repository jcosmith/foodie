import 'package:drift/drift.dart';

import '../storage_layout/storage_layout_tables.dart';

/// Product categories owned by feature_product_catalog.
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get categoryIdentifier => text()();

  /// Set for seeded categories (for example `vegetables`); the name is then
  /// translated until the user renames it.
  TextColumn get catalogKey => text().nullable().unique()();

  TextColumn get customName => text().nullable()();

  IntColumn get recommendedMaximumStorageDays => integer()();

  TextColumn get iconEmoji => text()();

  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {categoryIdentifier};
}

/// Products owned by feature_product_catalog.
@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get productIdentifier => text()();

  TextColumn get categoryIdentifier => text().references(Categories, #categoryIdentifier)();

  TextColumn get catalogKey => text().nullable().unique()();

  TextColumn get customName => text().nullable()();

  /// `gram`, `milliliter`, `piece` or `portion`; every quantity of this
  /// product is stored in this unit's base unit (decision D10).
  TextColumn get canonicalUnit => text()();

  IntColumn get defaultPackageQuantity => integer().nullable()();

  /// Overrides the category's recommendation when set.
  IntColumn get recommendedMaximumStorageDays => integer().nullable()();

  /// Falls back to the category icon when null.
  TextColumn get iconEmoji => text().nullable()();

  /// A picture the user chose as the icon, shown instead of [iconEmoji]: a
  /// small square PNG made by core_media_storage (a few kilobytes, so it
  /// lives in the encrypted database and travels with backups).
  BlobColumn get iconImage => blob().nullable()();

  /// The drawer a new batch of this product goes into unless the user picks
  /// another; `null` suggests the drawer it went into last time.
  TextColumn get defaultCompartmentIdentifier =>
      text().nullable().references(Compartments, #compartmentIdentifier)();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {productIdentifier};
}
