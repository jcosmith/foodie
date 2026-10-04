// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_layout_dao.dart';

// ignore_for_file: type=lint
mixin _$StorageLayoutDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  $StoragePlacesTable get storagePlaces => attachedDatabase.storagePlaces;
  $CompartmentsTable get compartments => attachedDatabase.compartments;
  StorageLayoutDaoManager get managers => StorageLayoutDaoManager(this);
}

class StorageLayoutDaoManager {
  final _$StorageLayoutDaoMixin _db;
  StorageLayoutDaoManager(this._db);
  $$StoragePlacesTableTableManager get storagePlaces =>
      $$StoragePlacesTableTableManager(_db.attachedDatabase, _db.storagePlaces);
  $$CompartmentsTableTableManager get compartments =>
      $$CompartmentsTableTableManager(_db.attachedDatabase, _db.compartments);
}
