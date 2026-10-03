import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_layout_providers.dart';
import '../domain/freezer.dart';
import '../domain/storage_layout.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'layout_localization.dart';
import 'storage_layout_routes.dart';

/// The "Freezer layout" section of the Config tab: one row per freezer and
/// a button to add another.
class FreezerLayoutConfigSection extends ConsumerWidget {
  const FreezerLayoutConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(storageLayoutProvider).value ?? StorageLayout.empty;
    return FreezerLayoutList(layout: layout, allowsReordering: false);
  }
}

/// Freezers with their summaries; tapping one opens its editor.
class FreezerLayoutList extends ConsumerWidget {
  const FreezerLayoutList({required this.layout, required this.allowsReordering, super.key});

  final StorageLayout layout;
  final bool allowsReordering;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = StorageLayoutLocalizations.of(context);
    final nameResolver = context.compartmentDisplayNameResolver(layout);
    final freezers = layout.freezers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, freezerLayout) in freezers.indexed)
          ListTile(
            contentPadding: const EdgeInsetsDirectional.only(start: FreezerSpacing.small),
            leading: const Icon(Icons.kitchen_outlined),
            title: Text(nameResolver.freezerName(freezerLayout.freezer)),
            subtitle: Text(localizations.freezerSummaryOf(freezerLayout)),
            onTap: () =>
                context.push(StorageLayoutRoutes.freezerEditor(freezerLayout.freezer.identifier)),
            trailing: allowsReordering && freezers.length > 1
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: localizations.moveUp,
                        onPressed: index == 0
                            ? null
                            : () => _moveFreezer(ref, freezers, index, index - 1),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                      IconButton(
                        tooltip: localizations.moveDown,
                        onPressed: index == freezers.length - 1
                            ? null
                            : () => _moveFreezer(ref, freezers, index, index + 1),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    ],
                  )
                : const Icon(Icons.chevron_right),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => context.push(StorageLayoutRoutes.newFreezer),
            icon: const Icon(Icons.add),
            label: Text(localizations.addFreezerButton),
          ),
        ),
      ],
    );
  }

  static Future<void> _moveFreezer(
    WidgetRef ref,
    List<FreezerLayout> freezers,
    int fromIndex,
    int toIndex,
  ) async {
    final orderedIdentifiers = <FreezerIdentifier>[
      for (final freezerLayout in freezers) freezerLayout.freezer.identifier,
    ];
    final movedIdentifier = orderedIdentifiers.removeAt(fromIndex);
    orderedIdentifiers.insert(toIndex, movedIdentifier);
    await ref.read(reorderFreezersUseCaseProvider).execute(orderedIdentifiers);
  }
}
