import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ApplicationDatabase database;

  ItemPictureRow picture(String identifier, {String ownerIdentifier = 'product-1'}) =>
      ItemPictureRow(
        itemPictureIdentifier: identifier,
        ownerKind: 'product',
        ownerIdentifier: ownerIdentifier,
        encryptedFileName: '$identifier-picture.fzm',
        thumbnailFileName: '$identifier-thumbnail.fzm',
        widthPixels: 1600,
        heightPixels: 1200,
        byteSize: 300000,
        createdAt: DateTime.utc(2026, 10, 2),
      );

  setUp(() => database = createInMemoryApplicationDatabase());
  tearDown(() => database.close());

  test('stores one picture per owner', () async {
    final dao = database.itemPicturesDao;
    await dao.insertPicture(picture('picture-1'));
    await dao.insertPicture(picture('picture-2', ownerIdentifier: 'product-2'));

    expect(
      await dao.readPictureOf(ownerKind: 'product', ownerIdentifier: 'product-1'),
      picture('picture-1'),
    );
    expect(await dao.readPictureOf(ownerKind: 'stock_batch', ownerIdentifier: 'product-1'), isNull);
    // A second picture of the same owner breaks the unique index.
    await expectLater(dao.insertPicture(picture('picture-3')), throwsA(isA<Exception>()));

    await dao.deletePicture('picture-1');
    expect((await dao.readPictures()).single.itemPictureIdentifier, 'picture-2');
  });
}
