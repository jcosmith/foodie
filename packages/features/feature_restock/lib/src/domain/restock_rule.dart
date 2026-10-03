import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

/// How much of a product the user wants to keep in the freezer.
@immutable
final class RestockRule {
  const RestockRule({
    required this.productIdentifier,
    required this.minimumQuantity,
    required this.isActive,
    this.targetQuantity,
  });

  final ProductIdentifier productIdentifier;

  /// Below this the product is running low.
  final Quantity minimumQuantity;

  /// What to buy up to; `null` buys up to the minimum, at least one package.
  final Quantity? targetQuantity;

  final bool isActive;

  @override
  bool operator ==(Object other) =>
      other is RestockRule &&
      other.productIdentifier == productIdentifier &&
      other.minimumQuantity == minimumQuantity &&
      other.targetQuantity == targetQuantity &&
      other.isActive == isActive;

  @override
  int get hashCode => Object.hash(productIdentifier, minimumQuantity, targetQuantity, isActive);
}
