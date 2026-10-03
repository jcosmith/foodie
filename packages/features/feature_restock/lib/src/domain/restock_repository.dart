import 'package:feature_product_catalog/domain.dart';

import 'restock_rule.dart';
import 'shopping_list_entry.dart';

/// Restock rules and the shopping list, stored in the encrypted database.
abstract interface class RestockRepository {
  Stream<List<RestockRule>> watchRules();

  Future<List<RestockRule>> readRules();

  Future<void> saveRule(RestockRule rule);

  Future<void> deleteRule(ProductIdentifier productIdentifier);

  /// Oldest first.
  Stream<List<ShoppingListEntry>> watchShoppingList();

  Future<List<ShoppingListEntry>> readShoppingList();

  Future<void> insertShoppingListEntry(ShoppingListEntry entry);

  Future<void> replaceShoppingListEntry(ShoppingListEntry entry);

  Future<void> deleteShoppingListEntry(ShoppingListEntryIdentifier shoppingListEntryIdentifier);
}
