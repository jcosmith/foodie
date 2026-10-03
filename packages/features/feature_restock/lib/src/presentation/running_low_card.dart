import 'package:core_design_system/core_design_system.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/restock_providers.dart';
import '../l10n/generated/restock_localizations.dart';
import 'restock_routes.dart';

/// "Running low" on Home (UI example phone 1): products below their minimum.
class RunningLowCard extends ConsumerWidget {
  const RunningLowCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = RestockLocalizations.of(context);
    final runningLowProducts = ref.watch(runningLowProductsProvider) ?? const [];
    final catalog = ref.watch(productCatalogProvider).value;
    final nameResolver = context.productDisplayNameResolver;
    return SectionCard(
      title: localizations.runningLowTitle,
      trailingActionLabel: localizations.shoppingListLink,
      onTrailingActionPressed: () => context.go(RestockRoutes.shoppingList),
      child: runningLowProducts.isEmpty || catalog == null
          ? Text(localizations.runningLowEmpty)
          : Wrap(
              spacing: FreezerSpacing.small,
              runSpacing: FreezerSpacing.small,
              children: [
                for (final product in runningLowProducts)
                  Chip(
                    avatar: ProductIcon.ofProduct(product, catalog, size: 18),
                    label: Text(nameResolver.productName(product)),
                  ),
              ],
            ),
    );
  }
}
