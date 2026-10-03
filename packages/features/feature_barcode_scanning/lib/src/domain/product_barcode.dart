import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

import 'scanned_barcode.dart';

/// A code the user taught the app: scanning it again finds [productIdentifier].
@immutable
final class ProductBarcode {
  const ProductBarcode({
    required this.barcodeValue,
    required this.productIdentifier,
    required this.symbology,
    required this.isVariableMeasure,
    required this.learnedAt,
  });

  final String barcodeValue;
  final ProductIdentifier productIdentifier;
  final BarcodeSymbology symbology;
  final bool isVariableMeasure;
  final DateTime learnedAt;

  @override
  bool operator ==(Object other) =>
      other is ProductBarcode &&
      other.barcodeValue == barcodeValue &&
      other.productIdentifier == productIdentifier &&
      other.symbology == symbology &&
      other.isVariableMeasure == isVariableMeasure &&
      other.learnedAt == learnedAt;

  @override
  int get hashCode =>
      Object.hash(barcodeValue, productIdentifier, symbology, isVariableMeasure, learnedAt);
}
