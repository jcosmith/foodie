import 'package:drift/drift.dart';

/// One row describing which schema version and app version last migrated the
/// database. Used to validate backups on restore.
@DataClassName('SchemaMetadataRow')
class SchemaMetadataEntries extends Table {
  @override
  String get tableName => 'schema_metadata';

  /// Always 1; the table holds a single row.
  IntColumn get singletonIdentifier => integer()();

  IntColumn get schemaVersion => integer()();

  TextColumn get lastMigratedByApplicationVersion => text()();

  DateTimeColumn get migratedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {singletonIdentifier};
}
