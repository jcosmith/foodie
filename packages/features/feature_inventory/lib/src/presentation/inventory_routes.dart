import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:go_router/go_router.dart';

import 'add_stock_batch_screen.dart';

/// Paths of the inventory screens, for other features to link to. The stock
/// screen itself lives in each domain's tab.
abstract final class InventoryRoutes {
  /// The add form, optionally with a product chosen already and an amount
  /// in the product's base unit (barcode scans, where a weighed-goods code
  /// carries the weight).
  static String addStockBatch({ProductIdentifier? productIdentifier, int? amountInBaseUnits}) {
    final queryParameters = {
      'product': ?productIdentifier?.value,
      'amount': ?amountInBaseUnits?.toString(),
    };
    return Uri(
      path: '/inventory/add',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }
}

/// Screens that open full screen above the tabs.
List<RouteBase> buildInventoryRoutes() => [
  GoRoute(
    path: '/inventory/add',
    builder: (context, state) => AddStockBatchScreen(
      initialProductIdentifier: switch (state.uri.queryParameters['product']) {
        final productIdentifier? => ProductIdentifier(productIdentifier),
        null => null,
      },
      initialAmountInBaseUnits: int.tryParse(state.uri.queryParameters['amount'] ?? ''),
    ),
  ),
];
