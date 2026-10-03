import 'package:drift/drift.dart';

import '../product_catalog/product_catalog_tables.dart';

/// Barcodes the user taught the app, owned by feature_barcode_scanning
/// (architecture document, section 10.3). A code belongs to one product; a
/// product can have several codes (two brands of peas).
@DataClassName('ProductBarcodeRow')
@TableIndex(name: 'product_barcodes_by_product', columns: {#productIdentifier})
class ProductBarcodes extends Table {
  /// The code as scanned, or for weighed goods only its item part (for
  /// example `2412345` of `2412345012340`), so every package matches.
  TextColumn get barcodeValue => text()();

  TextColumn get productIdentifier => text().references(Products, #productIdentifier)();

  /// `ean13`, `ean8`, `upc_a`, `upc_e`, `code128`, `qr_code` or `other`.
  TextColumn get symbology => text()();

  /// A weighed-goods code (GS1 prefixes 02 and 20 to 29).
  BoolColumn get isVariableMeasure => boolean()();

  DateTimeColumn get learnedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {barcodeValue};
}
