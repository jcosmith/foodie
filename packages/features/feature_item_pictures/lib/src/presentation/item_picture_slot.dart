import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/item_picture_providers.dart';
import '../application/item_picture_use_cases.dart';
import '../l10n/generated/item_pictures_localizations.dart';
import 'item_picture_owners.dart';
import 'item_picture_viewer.dart';
import 'picture_capture.dart';

/// The photo slot of a form whose item does not exist yet (UI examples
/// document, phone 5). The picture is stored as soon as it is taken and
/// staged in the [ItemPictureDraft]; the form attaches it after saving. If
/// the form is left without saving, its files are deleted again.
class ItemPictureSlot extends ConsumerStatefulWidget {
  const ItemPictureSlot({required this.draft, super.key});

  final ItemPictureDraft draft;

  @override
  ConsumerState<ItemPictureSlot> createState() => _ItemPictureSlotState();
}

class _ItemPictureSlotState extends ConsumerState<ItemPictureSlot> {
  StagedItemPicture? _stagedPicture;
  bool _isProcessing = false;
  // Read up front: the slot needs it while being disposed, when ref is gone.
  late final DiscardStagedItemPictureUseCase _discardStagedPicture;

  @override
  void initState() {
    super.initState();
    _discardStagedPicture = ref.read(discardStagedItemPictureUseCaseProvider);
  }

  @override
  void dispose() {
    // Still staged means the form was left without saving.
    if (_stagedPicture case final stagedPicture? when widget.draft.hasPicture) {
      widget.draft.clear();
      _discardStagedPicture.execute(stagedPicture);
    }
    super.dispose();
  }

  Future<void> _takeOrChoose() async {
    final stagedPicture = await takeOrChooseAndStagePicture(
      context,
      ref,
      onProcessingStarted: () {
        if (mounted) setState(() => _isProcessing = true);
      },
    );
    if (!mounted) {
      if (stagedPicture != null) await _discardStagedPicture.execute(stagedPicture);
      return;
    }
    setState(() => _isProcessing = false);
    if (stagedPicture == null) return;
    _replaceStagedPicture(stagedPicture);
  }

  void _replaceStagedPicture(StagedItemPicture? stagedPicture) {
    final previousPicture = _stagedPicture;
    if (previousPicture != null) _discardStagedPicture.execute(previousPicture);
    setState(() => _stagedPicture = stagedPicture);
    if (stagedPicture == null) {
      widget.draft.clear();
      return;
    }
    final attachItemPicture = ref.read(attachItemPictureUseCaseProvider);
    widget.draft.stage(
      (subject) => attachItemPicture.execute(
        owner: itemPictureOwnerOf(subject),
        stagedPicture: stagedPicture,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ItemPicturesLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.foodieColors;
    final stagedPicture = _stagedPicture;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: tokens.surfaceMuted,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: stagedPicture == null
                ? BorderSide(color: tokens.border, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: _isProcessing
                ? null
                : stagedPicture == null
                ? _takeOrChoose
                : () => showItemPictureViewer(context, stagedPicture.reference),
            child: SizedBox(
              height: 150,
              child: switch ((stagedPicture, _isProcessing)) {
                (_, true) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: FoodieSpacing.small),
                      Text(localizations.photoProcessing, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                (null, false) => Center(
                  child: Text(
                    localizations.takeOrChoosePhoto,
                    style: theme.textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
                  ),
                ),
                (final stagedPicture?, false) => _StagedPicturePreview(
                  stagedPicture: stagedPicture,
                  onRemoved: () => _replaceStagedPicture(null),
                  onReplaced: _takeOrChoose,
                ),
              },
            ),
          ),
        ),
        if (stagedPicture == null) ...[
          const SizedBox(height: FoodieSpacing.extraSmall),
          Text(
            localizations.photoOptional,
            style: theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
        ],
      ],
    );
  }
}

class _StagedPicturePreview extends StatelessWidget {
  const _StagedPicturePreview({
    required this.stagedPicture,
    required this.onRemoved,
    required this.onReplaced,
  });

  final StagedItemPicture stagedPicture;
  final VoidCallback onRemoved;
  final VoidCallback onReplaced;

  @override
  Widget build(BuildContext context) {
    final localizations = ItemPicturesLocalizations.of(context);
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Semantics(
          image: true,
          label: localizations.photoSemanticsLabel,
          child: Image.memory(stagedPicture.pictureBytes, fit: BoxFit.cover),
        ),
        PositionedDirectional(
          top: FoodieSpacing.extraSmall,
          end: FoodieSpacing.extraSmall,
          child: Row(
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.photo_camera_outlined),
                tooltip: localizations.replacePhoto,
                onPressed: onReplaced,
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.delete_outline),
                tooltip: localizations.removePhoto,
                onPressed: onRemoved,
              ),
            ],
          ),
        ),
        PositionedDirectional(
          start: FoodieSpacing.small,
          end: FoodieSpacing.small,
          bottom: FoodieSpacing.small,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FoodieSpacing.small,
                vertical: FoodieSpacing.extraSmall,
              ),
              child: Text(
                localizations.photoAdded,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF24303F)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
