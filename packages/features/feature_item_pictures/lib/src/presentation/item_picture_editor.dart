import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/item_picture_providers.dart';
import '../domain/item_picture.dart';
import '../l10n/generated/item_pictures_localizations.dart';
import 'item_picture_owners.dart';
import 'item_picture_viewer.dart';
import 'picture_capture.dart';

/// The picture of an existing product or batch: add one, view it full
/// screen, replace or remove it. Changes are saved at once.
class ItemPictureEditor extends ConsumerStatefulWidget {
  const ItemPictureEditor({required this.subject, super.key});

  final ItemVisualSubject subject;

  @override
  ConsumerState<ItemPictureEditor> createState() => _ItemPictureEditorState();
}

class _ItemPictureEditorState extends ConsumerState<ItemPictureEditor> {
  bool _isProcessing = false;

  ItemPictureOwner get _owner => itemPictureOwnerOf(widget.subject);

  Future<void> _takeOrChoose() async {
    final attachItemPicture = ref.read(attachItemPictureUseCaseProvider);
    final stagedPicture = await takeOrChooseAndStagePicture(
      context,
      ref,
      onProcessingStarted: () {
        if (mounted) setState(() => _isProcessing = true);
      },
    );
    if (stagedPicture != null) {
      await attachItemPicture.execute(owner: _owner, stagedPicture: stagedPicture);
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _remove() async {
    final localizations = ItemPicturesLocalizations.of(context);
    final commonLocalizations = context.commonLocalizations;
    final removeItemPicture = ref.read(removeItemPictureUseCaseProvider);
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.removePhotoQuestion),
        content: Text(localizations.removePhotoExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(commonLocalizations.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.removePhoto),
          ),
        ],
      ),
    );
    if (isConfirmed ?? false) await removeItemPicture.execute(_owner);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ItemPicturesLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.freezerColors;
    final catalog = ref.watch(itemPictureCatalogProvider).value;
    if (catalog == null) return const SizedBox(height: 150);
    final picture = catalog.pictureOf(_owner);
    final thumbnailBytes = picture == null
        ? null
        : ref.watch(pictureThumbnailBytesProvider(picture.reference.thumbnailFileName)).value;
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(color: tokens.textMuted);

    final Widget frameContent;
    if (_isProcessing) {
      frameContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: FreezerSpacing.small),
            Text(localizations.photoProcessing, style: theme.textTheme.bodySmall),
          ],
        ),
      );
    } else if (picture == null) {
      frameContent = Center(
        child: Text(
          localizations.takeOrChoosePhoto,
          style: theme.textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
        ),
      );
    } else {
      frameContent = Semantics(
        image: true,
        label: localizations.photoSemanticsLabel,
        child: thumbnailBytes == null
            ? const SizedBox.expand()
            : Image.memory(thumbnailBytes, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: tokens.surfaceMuted,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: picture == null ? BorderSide(color: tokens.border, width: 2) : BorderSide.none,
          ),
          child: InkWell(
            onTap: _isProcessing
                ? null
                : picture == null
                ? _takeOrChoose
                : () => showItemPictureViewer(context, picture.reference),
            child: SizedBox(height: 150, child: frameContent),
          ),
        ),
        const SizedBox(height: FreezerSpacing.extraSmall),
        if (picture == null)
          Text(
            widget.subject is StockBatchItemVisualSubject
                ? localizations.batchPhotoHint
                : localizations.photoOptional,
            style: mutedStyle,
          )
        else
          Wrap(
            spacing: FreezerSpacing.small,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.fullscreen),
                label: Text(localizations.viewPhoto),
                onPressed: () => showItemPictureViewer(context, picture.reference),
              ),
              TextButton.icon(
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(localizations.replacePhoto),
                onPressed: _isProcessing ? null : _takeOrChoose,
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(localizations.removePhoto),
                onPressed: _isProcessing ? null : _remove,
              ),
            ],
          ),
      ],
    );
  }
}
