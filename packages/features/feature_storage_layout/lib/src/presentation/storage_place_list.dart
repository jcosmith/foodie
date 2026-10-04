import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_layout_providers.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_place.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'layout_localization.dart';
import 'storage_layout_routes.dart';

/// The "Storage place layout" section of the Config tab: one row per storage place and
/// a button to add another.
class StorageLayoutConfigSection extends ConsumerWidget {
  const StorageLayoutConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(storageLayoutProvider).value ?? StorageLayout.empty;
    return StoragePlaceList(layout: layout, allowsReordering: false);
  }
}

/// Storage places with their summaries; tapping one opens its editor.
class StoragePlaceList extends ConsumerWidget {
  const StoragePlaceList({required this.layout, required this.allowsReordering, super.key});

  final StorageLayout layout;
  final bool allowsReordering;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = StorageLayoutLocalizations.of(context);
    final nameResolver = context.compartmentDisplayNameResolver(layout);
    final storagePlaces = layout.storagePlaces;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, storagePlaceLayout) in storagePlaces.indexed)
          ListTile(
            contentPadding: const EdgeInsetsDirectional.only(start: FoodieSpacing.small),
            leading: const Icon(Icons.kitchen_outlined),
            title: Text(nameResolver.storagePlaceName(storagePlaceLayout.storagePlace)),
            subtitle: Text(context.storagePlaceSummaryOf(storagePlaceLayout)),
            onTap: () => context.push(
              StorageLayoutRoutes.storagePlaceEditor(storagePlaceLayout.storagePlace.identifier),
            ),
            trailing: allowsReordering && storagePlaces.length > 1
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: localizations.moveUp,
                        onPressed: index == 0
                            ? null
                            : () => _moveStoragePlace(ref, storagePlaces, index, index - 1),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                      IconButton(
                        tooltip: localizations.moveDown,
                        onPressed: index == storagePlaces.length - 1
                            ? null
                            : () => _moveStoragePlace(ref, storagePlaces, index, index + 1),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    ],
                  )
                : const Icon(Icons.chevron_right),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => context.push(StorageLayoutRoutes.newStoragePlace),
            icon: const Icon(Icons.add),
            label: Text(localizations.addStoragePlaceButton),
          ),
        ),
      ],
    );
  }

  static Future<void> _moveStoragePlace(
    WidgetRef ref,
    List<StoragePlaceLayout> storagePlaces,
    int fromIndex,
    int toIndex,
  ) async {
    final orderedIdentifiers = <StoragePlaceIdentifier>[
      for (final storagePlaceLayout in storagePlaces) storagePlaceLayout.storagePlace.identifier,
    ];
    final movedIdentifier = orderedIdentifiers.removeAt(fromIndex);
    orderedIdentifiers.insert(toIndex, movedIdentifier);
    await ref.read(reorderStoragePlacesUseCaseProvider).execute(orderedIdentifiers);
  }
}
