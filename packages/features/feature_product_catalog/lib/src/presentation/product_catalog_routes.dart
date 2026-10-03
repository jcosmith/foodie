import 'package:go_router/go_router.dart';

import '../domain/product.dart';
import 'product_editor_screen.dart';
import 'product_list_screen.dart';

/// Paths of the product catalog screens, for other features to link to.
abstract final class ProductCatalogRoutes {
  static const String productList = '/product_catalog';

  /// The editor for a new product; returns its identifier when popped.
  static String newProduct({String initialName = ''}) => Uri(
    path: '/product_catalog/products/new',
    queryParameters: initialName.trim().isEmpty ? null : {'name': initialName.trim()},
  ).toString();

  static String productEditor(ProductIdentifier productIdentifier) =>
      '/product_catalog/products/${Uri.encodeComponent(productIdentifier.value)}';
}

List<RouteBase> buildProductCatalogRoutes() => [
  GoRoute(
    path: ProductCatalogRoutes.productList,
    builder: (context, state) => const ProductListScreen(),
    routes: [
      GoRoute(
        path: 'products/new',
        builder: (context, state) =>
            ProductEditorScreen(initialName: state.uri.queryParameters['name'] ?? ''),
      ),
      GoRoute(
        path: 'products/:productIdentifier',
        builder: (context, state) => ProductEditorScreen(
          productIdentifier: ProductIdentifier(state.pathParameters['productIdentifier']!),
        ),
      ),
    ],
  ),
];
