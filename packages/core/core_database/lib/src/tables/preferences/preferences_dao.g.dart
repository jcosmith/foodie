// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_dao.dart';

// ignore_for_file: type=lint
mixin _$PreferencesDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  $PreferenceEntriesTable get preferenceEntries =>
      attachedDatabase.preferenceEntries;
  PreferencesDaoManager get managers => PreferencesDaoManager(this);
}

class PreferencesDaoManager {
  final _$PreferencesDaoMixin _db;
  PreferencesDaoManager(this._db);
  $$PreferenceEntriesTableTableManager get preferenceEntries =>
      $$PreferenceEntriesTableTableManager(
        _db.attachedDatabase,
        _db.preferenceEntries,
      );
}
