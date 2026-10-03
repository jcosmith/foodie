import 'package:core_events/core_events.dart';
import 'package:feature_product_catalog/domain.dart';

import 'shopping_list_entry.dart';

final class ShoppingListEntryAdded extends DomainEvent {
  const ShoppingListEntryAdded({
    required this.shoppingListEntryIdentifier,
    required this.origin,
    required super.occurredAt,
    this.productIdentifier,
  });

  final ShoppingListEntryIdentifier shoppingListEntryIdentifier;
  final ProductIdentifier? productIdentifier;
  final ShoppingListEntryOrigin origin;
}
