import 'package:core_database/core_database.dart';

import '../domain/item_picture.dart';
import '../domain/item_picture_repository.dart';

final class DriftItemPictureRepository implements ItemPictureRepository {
  DriftItemPictureRepository({required ItemPicturesDao itemPicturesDao})
    : _itemPicturesDao = itemPicturesDao;

  final ItemPicturesDao _itemPicturesDao;

  @override
  Stream<List<ItemPicture>> watchPictures() =>
      _itemPicturesDao.watchPictures().map((rows) => rows.map(_pictureFromRow).toList());

  @override
  Future<List<ItemPicture>> readPictures() async =>
      (await _itemPicturesDao.readPictures()).map(_pictureFromRow).toList();

  @override
  Future<ItemPicture?> readPictureOf(ItemPictureOwner owner) async {
    final row = await _itemPicturesDao.readPictureOf(
      ownerKind: owner.kindStorageName,
      ownerIdentifier: owner.identifierValue,
    );
    return row == null ? null : _pictureFromRow(row);
  }

  @override
  Future<void> insertPicture(ItemPicture picture) => _itemPicturesDao.insertPicture(
    ItemPictureRow(
      itemPictureIdentifier: picture.identifier.value,
      ownerKind: picture.owner.kindStorageName,
      ownerIdentifier: picture.owner.identifierValue,
      encryptedFileName: picture.reference.encryptedFileName,
      thumbnailFileName: picture.reference.thumbnailFileName,
      widthPixels: picture.reference.widthPixels,
      heightPixels: picture.reference.heightPixels,
      byteSize: picture.reference.byteSize,
      createdAt: picture.createdAt,
    ),
  );

  @override
  Future<void> deletePicture(ItemPictureIdentifier itemPictureIdentifier) =>
      _itemPicturesDao.deletePicture(itemPictureIdentifier.value);

  static ItemPicture _pictureFromRow(ItemPictureRow row) => ItemPicture(
    identifier: ItemPictureIdentifier(row.itemPictureIdentifier),
    owner: ItemPictureOwner.fromStorage(kind: row.ownerKind, identifier: row.ownerIdentifier),
    reference: ItemPictureReference(
      encryptedFileName: row.encryptedFileName,
      thumbnailFileName: row.thumbnailFileName,
      widthPixels: row.widthPixels,
      heightPixels: row.heightPixels,
      byteSize: row.byteSize,
    ),
    createdAt: row.createdAt.toUtc(),
  );
}
