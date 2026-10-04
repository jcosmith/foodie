import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/product_catalog_providers.dart';
import '../domain/product.dart';
import '../domain/product_catalog.dart';
import '../l10n/generated/product_catalog_localizations.dart';
import 'product_catalog_routes.dart';
import 'product_tile.dart';

/// Lets the user search and pick a product, or create a new one. Returns the
/// chosen product, or `null` when dismissed.
Future<ProductIdentifier?> showProductPickerSheet(BuildContext context) =>
    showModalBottomSheet<ProductIdentifier>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) =>
          const FractionallySizedBox(heightFactor: 0.9, child: ProductPickerSheet()),
    );

class ProductPickerSheet extends ConsumerStatefulWidget {
  const ProductPickerSheet({super.key});

  @override
  ConsumerState<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<ProductPickerSheet> {
  String _searchText = '';

  Future<void> _createProduct() async {
    final createdProduct = await context.push<ProductIdentifier>(
      ProductCatalogRoutes.newProduct(initialName: _searchText),
    );
    if (createdProduct != null && mounted) Navigator.of(context).pop(createdProduct);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ProductCatalogLocalizations.of(context);
    final catalog = ref.watch(productCatalogProvider).value ?? ProductCatalog.empty;
    final groups = groupProductsByCategory(context, catalog, searchText: _searchText);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.screenGutter),
          child: Text(localizations.pickerTitle, style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: localizations.searchHint,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (searchText) => setState(() => _searchText = searchText),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              if (groups.isEmpty && _searchText.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
                  child: Text(localizations.noProductsFound(_searchText.trim())),
                ),
              for (final (categoryName, products) in groups) ...[
                _CategoryHeader(categoryName),
                for (final product in products)
                  ProductTile(
                    product: product,
                    catalog: catalog,
                    onTap: () => Navigator.of(context).pop(product.identifier),
                  ),
              ],
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(
                  _searchText.trim().isEmpty
                      ? localizations.createProductAction
                      : localizations.createProductWithName(_searchText.trim()),
                ),
                onTap: _createProduct,
              ),
              const SizedBox(height: FoodieSpacing.large),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(
      FoodieSpacing.screenGutter,
      FoodieSpacing.medium,
      FoodieSpacing.screenGutter,
      FoodieSpacing.extraSmall,
    ),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: context.foodieColors.textMuted),
      ),
    ),
  );
}
