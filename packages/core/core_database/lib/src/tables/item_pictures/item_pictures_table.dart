import 'package:drift/drift.dart';

/// One picture of a product or a stock batch, owned by feature_item_pictures
/// (decision D11). The picture itself is an encrypted file; this row only
/// says where it is. An owner has at most one picture.
@DataClassName('ItemPictureRow')
@TableIndex(name: 'item_pictures_by_owner', columns: {#ownerKind, #ownerIdentifier}, unique: true)
class ItemPictures extends Table {
  TextColumn get itemPictureIdentifier => text()();

  /// `product` or `stock_batch`. No foreign key, because the owner is one of
  /// two tables; the module removes pictures of removed owners itself.
  TextColumn get ownerKind => text()();

  TextColumn get ownerIdentifier => text()();

  TextColumn get encryptedFileName => text()();

  TextColumn get thumbnailFileName => text()();

  IntColumn get widthPixels => integer()();

  IntColumn get heightPixels => integer()();

  IntColumn get byteSize => integer()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemPictureIdentifier};
}
