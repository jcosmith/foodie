import 'package:core_module_contract/core_module_contract.dart';

/// Paths of the restock screens.
abstract final class RestockRoutes {
  /// Identifies the shopping list among the segments of the Lists tab.
  static const String shoppingListSegment = 'restock.shopping_list';

  /// The shopping list in the Lists tab.
  static final String shoppingList = Uri(
    path: ShellRoutePaths.lists,
    queryParameters: {'segment': shoppingListSegment},
  ).toString();

  static const String rules = '/restock/rules';
}
