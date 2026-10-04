import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_layout_providers.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'storage_layout_routes.dart';
import 'storage_place_list.dart';

/// All storage places, in the user's order.
class StorageLayoutOverviewScreen extends ConsumerWidget {
  const StorageLayoutOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = StorageLayoutLocalizations.of(context);
    final layout = ref.watch(storageLayoutProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.layoutOverviewTitle)),
      body: switch (layout) {
        null => const Center(child: CircularProgressIndicator()),
        final layout when !layout.hasStoragePlace => EmptyStateView(
          icon: Icons.kitchen_outlined,
          title: localizations.noStoragePlaceTitle,
          message: localizations.noStoragePlaceMessage,
          actionLabel: localizations.addStoragePlaceButton,
          onActionPressed: () => context.push(StorageLayoutRoutes.newStoragePlace),
        ),
        final layout => ListView(
          padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: FoodieSpacing.small),
                child: StoragePlaceList(layout: layout, allowsReordering: true),
              ),
            ),
          ],
        ),
      },
    );
  }
}
