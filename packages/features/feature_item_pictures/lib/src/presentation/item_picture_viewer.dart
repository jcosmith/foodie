import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/item_picture_providers.dart';
import '../domain/item_picture.dart';
import '../l10n/generated/item_pictures_localizations.dart';

/// Shows a picture full screen, with pinch to zoom.
Future<void> showItemPictureViewer(BuildContext context, ItemPictureReference reference) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: _ItemPictureViewer(reference: reference),
      ),
    );

class _ItemPictureViewer extends ConsumerWidget {
  const _ItemPictureViewer({required this.reference});

  final ItemPictureReference reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pictureBytes = ref.watch(pictureBytesProvider(reference.encryptedFileName)).value;
    return Stack(
      children: [
        Positioned.fill(
          child: pictureBytes == null
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                  maxScale: 5,
                  child: Center(
                    child: Semantics(
                      image: true,
                      label: ItemPicturesLocalizations.of(context).photoSemanticsLabel,
                      child: Image.memory(pictureBytes, fit: BoxFit.contain),
                    ),
                  ),
                ),
        ),
        SafeArea(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.close),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }
}
