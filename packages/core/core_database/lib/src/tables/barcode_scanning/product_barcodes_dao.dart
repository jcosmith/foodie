import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'product_barcodes_table.dart';

part 'product_barcodes_dao.g.dart';

/// Learned barcodes of products.
@DriftAccessor(tables: [ProductBarcodes])
class ProductBarcodesDao extends DatabaseAccessor<ApplicationDatabase>
    with _$ProductBarcodesDaoMixin {
  ProductBarcodesDao(super.attachedDatabase);

  Future<ProductBarcodeRow?> readBarcode(String barcodeValue) => (select(
    productBarcodes,
  )..where((barcode) => barcode.barcodeValue.equals(barcodeValue))).getSingleOrNull();

  Stream<List<ProductBarcodeRow>> watchBarcodesOfProduct(String productIdentifier) =>
      (select(productBarcodes)
            ..where((barcode) => barcode.productIdentifier.equals(productIdentifier))
            ..orderBy([(barcode) => OrderingTerm.asc(barcode.learnedAt)]))
          .watch();

  /// Learns a code, or moves it to another product when it was learned
  /// wrong.
  Future<void> saveBarcode(ProductBarcodeRow barcode) =>
      into(productBarcodes).insertOnConflictUpdate(barcode);

  Future<void> deleteBarcode(String barcodeValue) =>
      (delete(productBarcodes)..where((barcode) => barcode.barcodeValue.equals(barcodeValue))).go();
}
