import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/item_picture_providers.dart';
import '../l10n/generated/item_pictures_localizations.dart';
import 'item_picture_owners.dart';

/// The square thumbnail of an item in lists, or [fallback] (the product's
/// icon) while it has no picture or the thumbnail is still being decrypted.
class ItemPictureThumbnail extends ConsumerWidget {
  const ItemPictureThumbnail({
    required this.subject,
    required this.size,
    required this.fallback,
    super.key,
  });

  final ItemVisualSubject subject;
  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(itemPictureCatalogProvider).value;
    final picture = catalog == null ? null : itemPictureToShowFor(catalog, subject);
    if (picture == null) return fallback;
    final thumbnailBytes = ref
        .watch(pictureThumbnailBytesProvider(picture.reference.thumbnailFileName))
        .value;
    if (thumbnailBytes == null) return fallback;
    return Semantics(
      image: true,
      label: ItemPicturesLocalizations.of(context).photoSemanticsLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.25),
        child: Image.memory(
          thumbnailBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        ),
      ),
    );
  }
}
