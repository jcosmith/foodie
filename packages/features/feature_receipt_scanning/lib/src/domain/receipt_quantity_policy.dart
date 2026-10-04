import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';

import 'receipt_parser.dart';

/// How much of a product a receipt line stands for.
abstract final class ReceiptQuantityPolicy {
  /// The weight on the receipt for weighed goods, else the package size
  /// times the pieces bought, else the pieces themselves for products
  /// counted in pieces; `null` when the user has to type it.
  static Quantity? suggest(ParsedReceiptLine line, Product product) {
    final unit = product.canonicalUnit;
    final weight = line.weightInGrams;
    if (weight != null && weight > 0 && unit == QuantityUnit.gram) {
      return Quantity(amountInBaseUnits: weight, unit: unit);
    }
    final pieces = line.quantity < 1 ? 1 : line.quantity;
    final package = product.defaultPackageQuantity;
    if (package != null && package.unit == unit) {
      return Quantity(amountInBaseUnits: package.amountInBaseUnits * pieces, unit: unit);
    }
    if (unit.dimension == QuantityDimension.count) {
      return Quantity(amountInBaseUnits: pieces * unit.baseUnitsPerDisplayUnit, unit: unit);
    }
    return null;
  }
}
