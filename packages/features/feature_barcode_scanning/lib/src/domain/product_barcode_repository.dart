import 'package:feature_product_catalog/domain.dart';

import 'product_barcode.dart';

abstract interface class ProductBarcodeRepository {
  Future<ProductBarcode?> readBarcode(String barcodeValue);

  Stream<List<ProductBarcode>> watchBarcodesOfProduct(ProductIdentifier productIdentifier);

  /// Learns a code, or moves it to another product.
  Future<void> saveBarcode(ProductBarcode barcode);

  Future<void> deleteBarcode(String barcodeValue);
}
