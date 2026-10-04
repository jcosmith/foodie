import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/storage_layout_providers.dart';
import '../domain/compartment.dart';
import '../domain/compartment_display_name_resolver.dart';
import '../domain/layout_name_policy.dart';
import '../domain/storage_kind.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_place.dart';
import '../l10n/generated/storage_layout_localizations.dart';
import 'layout_localization.dart';

enum _StoragePlaceMenuAction { rename, remove }

/// Edits one storage place (UI example phone 11): rename compartments inline, reorder
/// them with arrows, change their colour tag, add and remove compartments.
class StoragePlaceEditorScreen extends ConsumerWidget {
  const StoragePlaceEditorScreen({required this.storagePlaceIdentifier, super.key});

  final StoragePlaceIdentifier storagePlaceIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = StorageLayoutLocalizations.of(context);
    final layout = ref.watch(storageLayoutProvider).value;
    if (layout == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final storagePlaceLayout = layout.storagePlaceLayoutOf(storagePlaceIdentifier);
    if (storagePlaceLayout == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyStateView(
          icon: Icons.kitchen_outlined,
          title: localizations.storagePlaceNotFound,
        ),
      );
    }
    final itemCounts = ref.watch(compartmentItemCountsProvider).value ?? const {};
    final nameResolver = context.compartmentDisplayNameResolver(layout);
    final storagePlace = storagePlaceLayout.storagePlace;
    final compartments = storagePlaceLayout.compartments;
    final archivedCompartments = layout.archivedCompartmentsOf(storagePlaceIdentifier);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nameResolver.storagePlaceName(storagePlace)),
            Text(
              context.storagePlaceSummaryOf(storagePlaceLayout),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<_StoragePlaceMenuAction>(
            onSelected: (action) => switch (action) {
              _StoragePlaceMenuAction.rename => _renameStoragePlace(context, storagePlace),
              _StoragePlaceMenuAction.remove => _removeStoragePlace(
                context,
                ref,
                storagePlace,
                nameResolver,
              ),
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _StoragePlaceMenuAction.rename,
                child: Text(localizations.renameStoragePlaceAction),
              ),
              PopupMenuItem(
                value: _StoragePlaceMenuAction.remove,
                child: Text(localizations.removeStoragePlaceAction),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: FoodieSpacing.extraSmall),
              child: Column(
                children: [
                  for (final (index, compartment) in compartments.indexed)
                    CompartmentEditorRow(
                      key: ValueKey(compartment.identifier),
                      compartment: compartment,
                      storageKind: storagePlace.storageKind,
                      itemCount: itemCounts[compartment.identifier] ?? 0,
                      onMoveUp: index == 0
                          ? null
                          : () => _moveCompartment(ref, storagePlaceLayout, index, index - 1),
                      onMoveDown: index == compartments.length - 1
                          ? null
                          : () => _moveCompartment(ref, storagePlaceLayout, index, index + 1),
                      onRemove: compartments.length == 1
                          ? null
                          : () => _removeCompartment(
                              context,
                              ref,
                              layout,
                              compartment,
                              itemCounts[compartment.identifier] ?? 0,
                            ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: FoodieSpacing.small),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(addCompartmentUseCaseProvider).execute(storagePlaceIdentifier),
            icon: const Icon(Icons.add),
            label: Text(context.addCompartmentLabelOf(storagePlace.storageKind)),
          ),
          if (compartments.length == 1) _HintText(localizations.lastCompartmentHint),
          _HintText(localizations.layoutHint),
          if (archivedCompartments.isNotEmpty)
            _HintText(
              localizations.removedCompartmentsNote(
                archivedCompartments.map(nameResolver.plainCompartmentName).join(', '),
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> _moveCompartment(
    WidgetRef ref,
    StoragePlaceLayout storagePlaceLayout,
    int fromIndex,
    int toIndex,
  ) async {
    final orderedIdentifiers = <CompartmentIdentifier>[
      for (final compartment in storagePlaceLayout.compartments) compartment.identifier,
    ];
    final movedIdentifier = orderedIdentifiers.removeAt(fromIndex);
    orderedIdentifiers.insert(toIndex, movedIdentifier);
    await ref
        .read(reorderCompartmentsUseCaseProvider)
        .execute(
          storagePlaceIdentifier: storagePlaceLayout.storagePlace.identifier,
          orderedCompartmentIdentifiers: orderedIdentifiers,
        );
  }

  static Future<void> _removeCompartment(
    BuildContext context,
    WidgetRef ref,
    StorageLayout layout,
    Compartment compartment,
    int itemCount,
  ) async {
    CompartmentIdentifier? destinationIdentifier;
    if (itemCount > 0) {
      destinationIdentifier = await showDialog<CompartmentIdentifier>(
        context: context,
        builder: (dialogContext) => _MoveContentsDialog(
          layout: layout,
          compartmentToRemove: compartment,
          itemCount: itemCount,
        ),
      );
      if (destinationIdentifier == null) return;
    }
    final result = await ref
        .read(moveContentsAndArchiveCompartmentUseCaseProvider)
        .execute(
          compartmentIdentifier: compartment.identifier,
          destinationCompartmentIdentifier: destinationIdentifier,
        );
    if (result case FailedResult(:final failure) when context.mounted) {
      _showMessage(context, StorageLayoutLocalizations.of(context).describeFailure(failure));
    }
  }

  static Future<void> _renameStoragePlace(BuildContext context, StoragePlace storagePlace) =>
      showDialog<void>(
        context: context,
        builder: (dialogContext) => _RenameStoragePlaceDialog(storagePlace: storagePlace),
      );

  static Future<void> _removeStoragePlace(
    BuildContext context,
    WidgetRef ref,
    StoragePlace storagePlace,
    CompartmentDisplayNameResolver nameResolver,
  ) async {
    final localizations = StorageLayoutLocalizations.of(context);
    final commonLocalizations = context.commonLocalizations;
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          localizations.removeStoragePlaceDialogTitle(nameResolver.storagePlaceName(storagePlace)),
        ),
        content: Text(localizations.removeStoragePlaceDialogText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(commonLocalizations.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(commonLocalizations.actionRemove),
          ),
        ],
      ),
    );
    if (isConfirmed != true) return;
    final result = await ref
        .read(archiveStoragePlaceUseCaseProvider)
        .execute(storagePlace.identifier);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) => context.pop(),
      onFailure: (failure) =>
          _showMessage(context, localizations.describeFailure(failure, isAboutStoragePlace: true)),
    );
  }

  static void _showMessage(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// One compartment: colour tag, inline name field, item count, arrows and remove.
class CompartmentEditorRow extends ConsumerStatefulWidget {
  const CompartmentEditorRow({
    required this.compartment,
    required this.storageKind,
    required this.itemCount,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    super.key,
  });

  final Compartment compartment;
  final StorageKind storageKind;
  final int itemCount;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemove;

  @override
  ConsumerState<CompartmentEditorRow> createState() => _CompartmentEditorRowState();
}

class _CompartmentEditorRowState extends ConsumerState<CompartmentEditorRow> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.compartment.customName ?? '',
  );
  final FocusNode _nameFocusNode = FocusNode();
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) _saveName();
    });
  }

  @override
  void didUpdateWidget(CompartmentEditorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final storedName = widget.compartment.customName ?? '';
    if (!_nameFocusNode.hasFocus && _nameError == null && _nameController.text != storedName) {
      _nameController.text = storedName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim() == (widget.compartment.customName ?? '')) {
      if (_nameError != null) setState(() => _nameError = null);
      return;
    }
    final localizations = StorageLayoutLocalizations.of(context);
    final result = await ref
        .read(renameCompartmentUseCaseProvider)
        .execute(
          compartmentIdentifier: widget.compartment.identifier,
          enteredName: _nameController.text,
          defaultNames: context.layoutDefaultNames,
        );
    if (!mounted) return;
    final failure = result.failureOrNull;
    setState(() => _nameError = failure == null ? null : localizations.describeFailure(failure));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = StorageLayoutLocalizations.of(context);
    final defaultName = context.layoutDefaultNames.compartmentName(
      widget.storageKind,
      widget.compartment.defaultNumber,
    );
    final displayName = widget.compartment.customName ?? defaultName;
    final colorTagIndex = widget.compartment.colorTagIndex;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        FoodieSpacing.small,
        FoodieSpacing.extraSmall,
        FoodieSpacing.extraSmall,
        FoodieSpacing.extraSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: localizations.changeColor,
            onPressed: () => ref
                .read(changeCompartmentColorUseCaseProvider)
                .execute(
                  compartmentIdentifier: widget.compartment.identifier,
                  colorTagIndex: CompartmentColorPalette.nextIndexAfter(colorTagIndex),
                ),
            icon: Icon(Icons.circle, color: CompartmentColorPalette.colorAt(colorTagIndex)),
          ),
          Expanded(
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              textCapitalization: TextCapitalization.sentences,
              maxLength: LayoutNamePolicy.maximumNameLength + 10,
              buildCounter:
                  (context, {required currentLength, required isFocused, required maxLength}) =>
                      null,
              decoration: InputDecoration(
                isDense: true,
                hintText: defaultName,
                semanticCounterText: '',
                errorText: _nameError,
                helperText: localizations.compartmentItemCount(widget.itemCount),
              ),
              onSubmitted: (_) => _saveName(),
              onTapOutside: (_) => _nameFocusNode.unfocus(),
            ),
          ),
          IconButton(
            tooltip: '${localizations.moveUp}: $displayName',
            onPressed: widget.onMoveUp,
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            tooltip: '${localizations.moveDown}: $displayName',
            onPressed: widget.onMoveDown,
            icon: const Icon(Icons.arrow_downward),
          ),
          IconButton(
            tooltip: '${localizations.removeCompartment}: $displayName',
            onPressed: widget.onRemove,
            icon: Icon(
              Icons.close,
              color: widget.onRemove == null ? null : Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks where the items of a compartment that is being removed should go.
class _MoveContentsDialog extends StatefulWidget {
  const _MoveContentsDialog({
    required this.layout,
    required this.compartmentToRemove,
    required this.itemCount,
  });

  final StorageLayout layout;
  final Compartment compartmentToRemove;
  final int itemCount;

  @override
  State<_MoveContentsDialog> createState() => _MoveContentsDialogState();
}

class _MoveContentsDialogState extends State<_MoveContentsDialog> {
  late final List<Compartment> _destinations = [
    // Siblings first, then the compartments of other storage places.
    for (final compartment in widget.layout.activeCompartments)
      if (compartment.identifier != widget.compartmentToRemove.identifier &&
          compartment.storagePlaceIdentifier == widget.compartmentToRemove.storagePlaceIdentifier)
        compartment,
    for (final compartment in widget.layout.activeCompartments)
      if (compartment.storagePlaceIdentifier != widget.compartmentToRemove.storagePlaceIdentifier)
        compartment,
  ];
  late CompartmentIdentifier _selectedDestination = _destinations.first.identifier;

  @override
  Widget build(BuildContext context) {
    final localizations = StorageLayoutLocalizations.of(context);
    final nameResolver = context.compartmentDisplayNameResolver(widget.layout);
    return AlertDialog(
      title: Text(
        localizations.removeCompartmentDialogTitle(
          nameResolver.compartmentName(widget.compartmentToRemove),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(localizations.removeCompartmentDialogText(widget.itemCount)),
          const SizedBox(height: FoodieSpacing.medium),
          DropdownButtonFormField<CompartmentIdentifier>(
            initialValue: _selectedDestination,
            decoration: InputDecoration(labelText: localizations.moveDestinationLabel),
            items: [
              for (final destination in _destinations)
                DropdownMenuItem(
                  value: destination.identifier,
                  child: Text(nameResolver.compartmentNameWithStoragePlace(destination)),
                ),
            ],
            onChanged: (destination) {
              if (destination != null) setState(() => _selectedDestination = destination);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.commonLocalizations.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedDestination),
          child: Text(localizations.moveAndRemoveButton),
        ),
      ],
    );
  }
}

class _RenameStoragePlaceDialog extends ConsumerStatefulWidget {
  const _RenameStoragePlaceDialog({required this.storagePlace});

  final StoragePlace storagePlace;

  @override
  ConsumerState<_RenameStoragePlaceDialog> createState() => _RenameStoragePlaceDialogState();
}

class _RenameStoragePlaceDialogState extends ConsumerState<_RenameStoragePlaceDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.storagePlace.customName ?? '',
  );
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final localizations = StorageLayoutLocalizations.of(context);
    final result = await ref
        .read(renameStoragePlaceUseCaseProvider)
        .execute(
          storagePlaceIdentifier: widget.storagePlace.identifier,
          enteredName: _nameController.text,
          defaultNames: context.layoutDefaultNames,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (_) => Navigator.of(context).pop(),
      onFailure: (failure) => setState(
        () => _nameError = localizations.describeFailure(failure, isAboutStoragePlace: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = StorageLayoutLocalizations.of(context);
    final commonLocalizations = context.commonLocalizations;
    return AlertDialog(
      title: Text(localizations.renameStoragePlaceDialogTitle),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        maxLength: LayoutNamePolicy.maximumNameLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: context.layoutDefaultNames.storagePlaceName(widget.storagePlace.storageKind),
          errorText: _nameError,
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(commonLocalizations.actionCancel),
        ),
        FilledButton(onPressed: _save, child: Text(commonLocalizations.actionSave)),
      ],
    );
  }
}

class _HintText extends StatelessWidget {
  const _HintText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: FoodieSpacing.medium),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.foodieColors.textMuted),
    ),
  );
}
