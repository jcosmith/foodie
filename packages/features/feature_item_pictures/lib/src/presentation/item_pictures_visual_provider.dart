import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';

import 'item_picture_editor.dart';
import 'item_picture_slot.dart';
import 'item_picture_thumbnail.dart';

/// Supplies thumbnails to lists, the photo slot of the add form and the
/// picture editor, without any module importing this one.
final class ItemPicturesVisualProvider implements ItemVisualProvider {
  const ItemPicturesVisualProvider();

  @override
  Widget buildItemVisual(
    BuildContext context,
    ItemVisualSubject subject, {
    required double size,
    required Widget fallback,
  }) => ItemPictureThumbnail(subject: subject, size: size, fallback: fallback);

  @override
  Widget buildPictureSlot(BuildContext context, ItemPictureDraft draft) =>
      ItemPictureSlot(draft: draft);

  @override
  Widget buildPictureEditor(BuildContext context, ItemVisualSubject subject) =>
      ItemPictureEditor(subject: subject);
}
