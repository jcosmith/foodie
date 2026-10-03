import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/product_catalog_providers.dart';
import '../domain/product_catalog.dart';
import '../l10n/generated/product_catalog_localizations.dart';
import 'product_catalog_routes.dart';
import 'product_tile.dart';

/// Every product the user can pick, grouped by category; tap one to edit it.
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ProductCatalogLocalizations.of(context);
    final catalog = ref.watch(productCatalogProvider).value ?? ProductCatalog.empty;
    final groups = groupProductsByCategory(context, catalog);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.productListTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(ProductCatalogRoutes.newProduct()),
        icon: const Icon(Icons.add),
        label: Text(localizations.createProductAction),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(FreezerSpacing.screenGutter),
            child: Text(
              localizations.productListHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final (categoryName, products) in groups) ...[
            ListTile(
              dense: true,
              title: Semantics(
                header: true,
                child: Text(categoryName, style: Theme.of(context).textTheme.labelLarge),
              ),
            ),
            for (final product in products)
              ProductTile(
                product: product,
                catalog: catalog,
                onTap: () => context.push(ProductCatalogRoutes.productEditor(product.identifier)),
              ),
          ],
        ],
      ),
    );
  }
}

/// The "Products" section of the Config tab.
class ProductsConfigSection extends ConsumerWidget {
  const ProductsConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ProductCatalogLocalizations.of(context);
    final catalog = ref.watch(productCatalogProvider).value ?? ProductCatalog.empty;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: FreezerSpacing.small),
      leading: const Icon(Icons.category_outlined),
      title: Text(localizations.productCount(catalog.activeProducts.length)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(ProductCatalogRoutes.productList),
    );
  }
}
