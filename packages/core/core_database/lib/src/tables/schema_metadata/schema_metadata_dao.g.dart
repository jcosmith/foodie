// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_metadata_dao.dart';

// ignore_for_file: type=lint
mixin _$SchemaMetadataDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  $SchemaMetadataEntriesTable get schemaMetadataEntries =>
      attachedDatabase.schemaMetadataEntries;
  SchemaMetadataDaoManager get managers => SchemaMetadataDaoManager(this);
}

class SchemaMetadataDaoManager {
  final _$SchemaMetadataDaoMixin _db;
  SchemaMetadataDaoManager(this._db);
  $$SchemaMetadataEntriesTableTableManager get schemaMetadataEntries =>
      $$SchemaMetadataEntriesTableTableManager(
        _db.attachedDatabase,
        _db.schemaMetadataEntries,
      );
}
