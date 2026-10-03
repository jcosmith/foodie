import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'item_pictures_table.dart';

part 'item_pictures_dao.g.dart';

/// Picture rows of products and stock batches.
@DriftAccessor(tables: [ItemPictures])
class ItemPicturesDao extends DatabaseAccessor<ApplicationDatabase> with _$ItemPicturesDaoMixin {
  ItemPicturesDao(super.attachedDatabase);

  Stream<List<ItemPictureRow>> watchPictures() => select(itemPictures).watch();

  Future<List<ItemPictureRow>> readPictures() => select(itemPictures).get();

  Future<ItemPictureRow?> readPictureOf({
    required String ownerKind,
    required String ownerIdentifier,
  }) =>
      (select(itemPictures)..where(
            (picture) =>
                picture.ownerKind.equals(ownerKind) &
                picture.ownerIdentifier.equals(ownerIdentifier),
          ))
          .getSingleOrNull();

  Future<void> insertPicture(ItemPictureRow picture) => into(itemPictures).insert(picture);

  Future<void> deletePicture(String itemPictureIdentifier) => (delete(
    itemPictures,
  )..where((picture) => picture.itemPictureIdentifier.equals(itemPictureIdentifier))).go();
}
