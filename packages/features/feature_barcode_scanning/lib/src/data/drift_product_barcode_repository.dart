import 'package:core_database/core_database.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';

import '../domain/product_barcode.dart';
import '../domain/product_barcode_repository.dart';
import '../domain/scanned_barcode.dart';

final class DriftProductBarcodeRepository implements ProductBarcodeRepository {
  DriftProductBarcodeRepository({required ProductBarcodesDao productBarcodesDao})
    : _productBarcodesDao = productBarcodesDao;

  final ProductBarcodesDao _productBarcodesDao;

  @override
  Future<ProductBarcode?> readBarcode(String barcodeValue) async {
    final row = await _productBarcodesDao.readBarcode(barcodeValue);
    return row == null ? null : _barcodeFromRow(row);
  }

  @override
  Stream<List<ProductBarcode>> watchBarcodesOfProduct(ProductIdentifier productIdentifier) =>
      _productBarcodesDao
          .watchBarcodesOfProduct(productIdentifier.value)
          .map((rows) => rows.map(_barcodeFromRow).toList());

  @override
  Future<void> saveBarcode(ProductBarcode barcode) => _productBarcodesDao.saveBarcode(
    ProductBarcodeRow(
      barcodeValue: barcode.barcodeValue,
      productIdentifier: barcode.productIdentifier.value,
      symbology: barcode.symbology.storageName,
      isVariableMeasure: barcode.isVariableMeasure,
      learnedAt: barcode.learnedAt,
    ),
  );

  @override
  Future<void> deleteBarcode(String barcodeValue) =>
      _productBarcodesDao.deleteBarcode(barcodeValue);

  static ProductBarcode _barcodeFromRow(ProductBarcodeRow row) => ProductBarcode(
    barcodeValue: row.barcodeValue,
    productIdentifier: ProductIdentifier(row.productIdentifier),
    symbology: BarcodeSymbology.fromStorage(row.symbology),
    isVariableMeasure: row.isVariableMeasure,
    learnedAt: row.learnedAt.toUtc(),
  );
}
