import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ApplicationDatabase database;
  final learnedAt = DateTime.utc(2026, 10, 3);

  ProductBarcodeRow barcode(String barcodeValue, String productIdentifier) => ProductBarcodeRow(
    barcodeValue: barcodeValue,
    productIdentifier: productIdentifier,
    symbology: 'ean13',
    isVariableMeasure: false,
    learnedAt: learnedAt,
  );

  setUp(() async {
    database = createInMemoryApplicationDatabase();
    await database.productCatalogDao.insertCategory(
      const CategoryRow(
        categoryIdentifier: 'category-1',
        catalogKey: 'vegetables',
        recommendedMaximumStorageDays: 365,
        iconEmoji: '🥦',
        sortOrder: 0,
      ),
    );
    for (final productIdentifier in ['peas', 'spinach']) {
      await database.productCatalogDao.insertProduct(
        ProductRow(
          productIdentifier: productIdentifier,
          categoryIdentifier: 'category-1',
          canonicalUnit: 'gram',
          isArchived: false,
          createdAt: learnedAt,
        ),
      );
    }
  });
  tearDown(() => database.close());

  test('a product has several codes; a code learned wrong moves to the right product', () async {
    final dao = database.productBarcodesDao;
    await dao.saveBarcode(barcode('4001234567890', 'peas'));
    await dao.saveBarcode(barcode('4006040012345', 'peas'));
    expect(await dao.watchBarcodesOfProduct('peas').first, hasLength(2));

    await dao.saveBarcode(barcode('4006040012345', 'spinach'));

    expect((await dao.readBarcode('4006040012345'))?.productIdentifier, 'spinach');
    expect(await dao.watchBarcodesOfProduct('peas').first, hasLength(1));
    await dao.deleteBarcode('4001234567890');
    expect(await dao.readBarcode('4001234567890'), isNull);
  });

  test('a code needs an existing product', () async {
    await expectLater(
      database.productBarcodesDao.saveBarcode(barcode('4001234567890', 'missing')),
      throwsA(isA<Exception>()),
    );
  });
}
