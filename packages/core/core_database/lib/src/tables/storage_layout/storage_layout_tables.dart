import 'package:drift/drift.dart';

/// Freezers (and later fridges or pantries) owned by feature_storage_layout.
@DataClassName('FreezerRow')
class Freezers extends Table {
  TextColumn get freezerIdentifier => text()();

  /// Translation key of the default name, used until the user renames it.
  TextColumn get defaultNameKey => text()();

  TextColumn get customName => text().nullable()();

  /// `upright`, `chest` or `fridgeFreezerCompartment`.
  TextColumn get storageKind => text()();

  IntColumn get sortOrder => integer()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {freezerIdentifier};
}

/// Drawers, baskets or shelves of a freezer. Never deleted, only archived,
/// so past statistics keep their names (decision D13).
@DataClassName('CompartmentRow')
class Compartments extends Table {
  TextColumn get compartmentIdentifier => text()();

  TextColumn get freezerIdentifier => text().references(Freezers, #freezerIdentifier)();

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
