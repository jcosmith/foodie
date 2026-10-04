import 'dart:typed_data';

import 'package:core_foundation/core_foundation.dart';
import 'package:core_media_storage/core_media_storage.dart';

/// Receipt page images as encrypted files (decision D11), in a folder apart
/// from item pictures.
final class ReceiptPageImages {
  const ReceiptPageImages({
    required MediaFileStore store,
    required ImageProcessingService imageProcessing,
  }) : _store = store,
       _imageProcessing = imageProcessing;

  final MediaFileStore _store;
  final ImageProcessingService _imageProcessing;

  /// Straightens, greys and strips the photo, stores it and returns its
  /// reference.
  Future<Result<String, MediaStorageFailure>> store(Uint8List photoBytes) async {
    switch (await _imageProcessing.processDocumentPage(photoBytes)) {
      case SuccessfulResult(value: final pageBytes):
        final fileName = createMediaFileName();
        await _store.writeFile(fileName, pageBytes);
        return Result.success(fileName);
      case FailedResult(:final failure):
        return Result.failure(failure);
    }
  }

  Future<Uint8List> read(String reference) => _store.readFile(reference);

  Future<void> delete(Iterable<String> references) => _store.deleteFiles(references);

  /// Removes images no receipt refers to, such as those of a scan the app
  /// was closed in the middle of.
  Future<int> sweep(Set<String> referencedImages) => _store.sweepOrphanFiles(referencedImages);
}
