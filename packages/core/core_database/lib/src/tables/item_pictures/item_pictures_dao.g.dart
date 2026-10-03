// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_pictures_dao.dart';

// ignore_for_file: type=lint
mixin _$ItemPicturesDaoMixin on DatabaseAccessor<ApplicationDatabase> {
  $ItemPicturesTable get itemPictures => attachedDatabase.itemPictures;
  ItemPicturesDaoManager get managers => ItemPicturesDaoManager(this);
}

class ItemPicturesDaoManager {
  final _$ItemPicturesDaoMixin _db;
  ItemPicturesDaoManager(this._db);
  $$ItemPicturesTableTableManager get itemPictures =>
      $$ItemPicturesTableTableManager(_db.attachedDatabase, _db.itemPictures);
}
