import 'package:drift/drift.dart';

/// Storage places (freezers, fridges, pantries, cupboards) owned by
/// feature_storage_layout. Called `freezers` before schema version 9.
@DataClassName('StoragePlaceRow')
class StoragePlaces extends Table {
  TextColumn get storagePlaceIdentifier => text()();

  /// Translation key of the default name, used until the user renames it.
  TextColumn get defaultNameKey => text()();

  TextColumn get customName => text().nullable()();

  /// The stored name of a storage kind contributed by a domain module, such
  /// as `upright`, `chest` or `fridgeFreezerCompartment`.
  TextColumn get storageKind => text()();

  IntColumn get sortOrder => integer()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {storagePlaceIdentifier};
}

/// Drawers, baskets or shelves of a storage place. Never deleted, only archived,
/// so past statistics keep their names (decision D13).
@DataClassName('CompartmentRow')
class Compartments extends Table {
  TextColumn get compartmentIdentifier => text()();

  TextColumn get storagePlaceIdentifier =>
      text().references(StoragePlaces, #storagePlaceIdentifier)();

  /// The number in the default name "Drawer {number}"; stays fixed when reordering.
  IntColumn get defaultNumber => integer()();

  TextColumn get customName => text().nullable()();

  /// Index into the design system's compartment colour palette.
  IntColumn get colorTagIndex => integer()();

  IntColumn get sortOrder => integer()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {compartmentIdentifier};
}
