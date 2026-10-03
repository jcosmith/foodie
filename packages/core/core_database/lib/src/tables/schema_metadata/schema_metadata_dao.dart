import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'schema_metadata_entries_table.dart';

part 'schema_metadata_dao.g.dart';

@DriftAccessor(tables: [SchemaMetadataEntries])
class SchemaMetadataDao extends DatabaseAccessor<ApplicationDatabase>
    with _$SchemaMetadataDaoMixin {
  SchemaMetadataDao(super.attachedDatabase);

  static const int _singletonIdentifier = 1;

  Future<SchemaMetadataRow?> readSchemaMetadata() => (select(
    schemaMetadataEntries,
  )..where((row) => row.singletonIdentifier.equals(_singletonIdentifier))).getSingleOrNull();

  Future<void> recordMigration({
    required int schemaVersion,
    required String applicationVersion,
    required DateTime migratedAt,
  }) => into(schemaMetadataEntries).insertOnConflictUpdate(
    SchemaMetadataEntriesCompanion.insert(
      singletonIdentifier: const Value(_singletonIdentifier),
      schemaVersion: schemaVersion,
      lastMigratedByApplicationVersion: applicationVersion,
      migratedAt: migratedAt,
    ),
  );
}
