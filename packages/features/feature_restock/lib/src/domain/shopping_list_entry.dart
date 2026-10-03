import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

typedef ShoppingListEntryIdentifier = TypedIdentifier<ShoppingListEntry>;

/// Who put an entry on the list.
enum ShoppingListEntryOrigin {
  /// The user added it.
  manual,

  /// A restock rule added it because the product is running low; it updates
  /// and disappears with the stock.
  restock,
}

@immutable
final class ShoppingListEntry {
  const ShoppingListEntry({
    required this.identifier,
    required this.origin,
    required this.createdAt,
    this.productIdentifier,
    this.freeTextName,
    this.requestedQuantity,
    this.checkedAt,
  }) : assert(
         (productIdentifier == null) != (freeTextName == null),
         'An entry is either a product or free text',
       );

  final ShoppingListEntryIdentifier identifier;
  final ProductIdentifier? productIdentifier;
  final String? freeTextName;
  final Quantity? requestedQuantity;
  final ShoppingListEntryOrigin origin;
  final DateTime createdAt;

  /// Set while ticked as bought.
  final DateTime? checkedAt;

  bool get isChecked => checkedAt != null;

  bool get isAutomatic => origin == ShoppingListEntryOrigin.restock;

  ShoppingListEntry copyWith({Quantity? requestedQuantity, DateTime? Function()? checkedAt}) =>
      ShoppingListEntry(
        identifier: identifier,
        origin: origin,
        createdAt: createdAt,
        productIdentifier: productIdentifier,
        freeTextName: freeTextName,
        requestedQuantity: requestedQuantity ?? this.requestedQuantity,
        checkedAt: checkedAt == null ? this.checkedAt : checkedAt(),
      );

  @override
  bool operator ==(Object other) =>
      other is ShoppingListEntry &&
      other.identifier == identifier &&
      other.productIdentifier == productIdentifier &&
      other.freeTextName == freeTextName &&
      other.requestedQuantity == requestedQuantity &&
      other.origin == origin &&
      other.createdAt == createdAt &&
      other.checkedAt == checkedAt;

  @override
  int get hashCode => Object.hash(
    identifier,
    productIdentifier,
    freeTextName,
    requestedQuantity,
    origin,
    createdAt,
    checkedAt,
  );
}
