import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/application_shell_localizations.dart';

/// The Lists tab (UI example phone 15): the shopping list and, while receipt
/// scanning is on, the receipts, as segments at the top.
class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({this.initialSegmentIdentifier, super.key});

  /// The segment to show first, for links such as "see the shopping list".
  final String? initialSegmentIdentifier;

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  late String? _chosenSegmentIdentifier = widget.initialSegmentIdentifier;

  @override
  Widget build(BuildContext context) {
    final localizations = ApplicationShellLocalizations.of(context);
    final segments = [
      for (final module
          in ref.watch(enabledFeatureModulesProvider).value ?? const <FeatureModule>[])
        ...module.listsSegments,
    ]..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
    final selectedSegment =
        segments.where((segment) => segment.identifier == _chosenSegmentIdentifier).firstOrNull ??
        segments.firstOrNull;
    final subtitle = selectedSegment?.subtitleBuilder?.call(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.listsTitle),
            if (subtitle != null) Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        bottom: segments.length < 2
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    FoodieSpacing.screenGutter,
                    0,
                    FoodieSpacing.screenGutter,
                    FoodieSpacing.small,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        for (final segment in segments)
                          ButtonSegment(
                            value: segment.identifier,
                            label: Text(segment.labelBuilder(context)),
                          ),
                      ],
                      selected: {selectedSegment!.identifier},
                      onSelectionChanged: (selection) =>
                          setState(() => _chosenSegmentIdentifier = selection.single),
                    ),
                  ),
                ),
              ),
      ),
      body: selectedSegment == null
          ? const SizedBox.shrink()
          : KeyedSubtree(
              key: ValueKey(selectedSegment.identifier),
              child: selectedSegment.builder(context),
            ),
    );
  }
}
