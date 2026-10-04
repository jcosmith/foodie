import 'dart:typed_data';

import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/item_picture_providers.dart';
import '../application/item_picture_use_cases.dart';
import '../application/picture_source.dart';
import '../domain/item_picture_failure.dart';
import '../l10n/generated/item_pictures_localizations.dart';

/// Asks camera or photos, then shrinks, re-encodes and stores the picture.
/// `null` when the user cancels or it fails; failures are explained in a
/// snack bar. [onProcessingStarted] runs once a picture was taken or
/// chosen, before the slower re-encoding.
Future<StagedItemPicture?> takeOrChooseAndStagePicture(
  BuildContext context,
  WidgetRef ref, {
  VoidCallback? onProcessingStarted,
}) async {
  final localizations = ItemPicturesLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final sourceKind = await showModalBottomSheet<PictureSourceKind>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(localizations.takePhoto),
            onTap: () => Navigator.of(sheetContext).pop(PictureSourceKind.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(localizations.chooseFromPhotos),
            onTap: () => Navigator.of(sheetContext).pop(PictureSourceKind.gallery),
          ),
          const SizedBox(height: FoodieSpacing.small),
        ],
      ),
    ),
  );
  if (sourceKind == null) return null;

  void explain(ItemPictureFailure failure) => messenger?.showSnackBar(
    SnackBar(
      content: Text(switch (failure) {
        PictureNotReadable() => localizations.photoNotReadable,
        PictureSourceUnavailable() => localizations.photoSourceUnavailable,
      }),
    ),
  );

  final stageItemPicture = ref.read(stageItemPictureUseCaseProvider);
  final Uint8List? sourceBytes;
  try {
    sourceBytes = await ref.read(pictureSourceProvider).obtainPicture(sourceKind);
  } on Exception {
    explain(const PictureSourceUnavailable());
    return null;
  }
  if (sourceBytes == null) return null;
  onProcessingStarted?.call();
  final result = await stageItemPicture.execute(sourceBytes);
  switch (result) {
    case SuccessfulResult(:final value):
      return value;
    case FailedResult(:final failure):
      explain(failure);
      return null;
  }
}
