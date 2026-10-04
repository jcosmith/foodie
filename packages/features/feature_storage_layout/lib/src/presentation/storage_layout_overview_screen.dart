import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_layout_providers.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'freezer_layout_list.dart';
import 'storage_layout_routes.dart';

/// All freezers, in the user's order.
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
        final layout when !layout.hasFreezer => EmptyStateView(
          icon: Icons.kitchen_outlined,
          title: localizations.noFreezerTitle,
          message: localizations.noFreezerMessage,
          actionLabel: localizations.addFreezerButton,
          onActionPressed: () => context.push(StorageLayoutRoutes.newFreezer),
        ),
        final layout => ListView(
          padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: FoodieSpacing.small),
                child: FreezerLayoutList(layout: layout, allowsReordering: true),
              ),
            ),
          ],
        ),
      },
    );
  }
}
