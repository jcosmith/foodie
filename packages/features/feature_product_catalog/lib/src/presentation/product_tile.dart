import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product.dart';
import '../domain/product_catalog.dart';
import '../domain/product_icon_image.dart';
import 'catalog_localization.dart';

/// A product row: icon, name and usual package size.
class ProductTile extends StatelessWidget {
  const ProductTile({required this.product, required this.catalog, this.onTap, super.key});

  final Product product;
  final ProductCatalog catalog;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final packageQuantity = product.defaultPackageQuantity;
    return ListTile(
      leading: ProductVisual(product: product, catalog: catalog),
      title: Text(context.productDisplayNameResolver.productName(product)),
      subtitle: packageQuantity == null
          ? null
          : Text(
              context.quantityFormatter.format(
                packageQuantity,
                pieceLabel: product.displayPieceLabel,
              ),
            ),
      onTap: onTap,
    );
  }
}

/// A product's photo from an enabled item visual provider (item pictures),
/// or else its icon picture or emoji.
class ProductVisual extends ConsumerWidget {
  const ProductVisual({required this.product, required this.catalog, this.size = 40, super.key});

  final Product product;
  final ProductCatalog catalog;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = ProductIcon.ofProduct(product, catalog, size: size);
    final itemVisualProvider = ref.watch(enabledItemVisualProvider);
    if (itemVisualProvider == null) return fallback;
    return itemVisualProvider.buildItemVisual(
      context,
      ProductItemVisualSubject(productIdentifier: product.identifier.value),
      size: size,
      fallback: fallback,
    );
  }
}

/// The icon of a product or category in a soft rounded square: the
/// picture the user chose, or else the emoji.
class ProductIcon extends StatelessWidget {
  const ProductIcon({required this.emoji, this.image, this.size = 40, super.key});

  /// A product's own picture or emoji, else its category's emoji.
  ProductIcon.ofProduct(Product product, ProductCatalog catalog, {double size = 40, Key? key})
    : this(emoji: catalog.iconEmojiOf(product), image: product.iconImage, size: size, key: key);

  final String emoji;
  final ProductIconImage? image;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconImage = image;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(size / 4),
        ),
        child: iconImage == null
            ? Text(emoji, style: TextStyle(fontSize: size * 0.5))
            : Padding(
                padding: EdgeInsets.all(size / 10),
                child: Image.memory(
                  iconImage.pngBytes,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  // The emoji stands in should the picture ever be unreadable.
                  errorBuilder: (context, error, stackTrace) =>
                      Text(emoji, style: TextStyle(fontSize: size * 0.5)),
                ),
              ),
      ),
    );
  }
}

/// Active products grouped by category, in category order and by name;
/// categories without a match are left out.
List<(String categoryName, List<Product> products)> groupProductsByCategory(
  BuildContext context,
  ProductCatalog catalog, {
  String searchText = '',
}) {
  final nameResolver = context.productDisplayNameResolver;
  final normalizedSearch = searchText.trim().toLowerCase();
  bool matchesSearch(Product product) =>
      normalizedSearch.isEmpty ||
      nameResolver.productName(product).toLowerCase().contains(normalizedSearch);

  final groups = <(String, List<Product>)>[];
  for (final category in catalog.categories) {
    final products =
        catalog.activeProductsInCategory(category.identifier).where(matchesSearch).toList()..sort(
          (first, second) => nameResolver
              .productName(first)
              .toLowerCase()
              .compareTo(nameResolver.productName(second).toLowerCase()),
        );
    if (products.isNotEmpty) groups.add((nameResolver.categoryName(category), products));
  }
  return groups;
}
