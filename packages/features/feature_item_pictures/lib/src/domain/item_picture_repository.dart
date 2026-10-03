import 'item_picture.dart';

/// Picture rows; the picture files themselves live in the media store.
abstract interface class ItemPictureRepository {
  Stream<List<ItemPicture>> watchPictures();

  Future<List<ItemPicture>> readPictures();

  Future<ItemPicture?> readPictureOf(ItemPictureOwner owner);

  Future<void> insertPicture(ItemPicture picture);

  Future<void> deletePicture(ItemPictureIdentifier itemPictureIdentifier);
}
