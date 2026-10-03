import 'dart:typed_data';

import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:meta/meta.dart';

import '../domain/item_picture.dart';
import '../domain/item_picture_events.dart';
import '../domain/item_picture_failure.dart';
import '../domain/item_picture_repository.dart';

/// A picture whose files are written but that belongs to no item yet, such
/// as one taken in the add form before the batch is saved.
@immutable
final class StagedItemPicture {
  const StagedItemPicture({required this.reference, required this.pictureBytes});

  final ItemPictureReference reference;

  /// The re-encoded picture, for the preview.
  final Uint8List pictureBytes;
}

/// Shrinks and re-encodes a new picture (dropping its location data) and
/// writes it encrypted. The row comes later, in [AttachItemPictureUseCase]:
/// file first, row second (decision D11).
final class StageItemPictureUseCase {
  const StageItemPictureUseCase({
    required ImageProcessingService imageProcessingService,
    required MediaFileStore mediaFileStore,
  }) : _imageProcessingService = imageProcessingService,
       _mediaFileStore = mediaFileStore;

  final ImageProcessingService _imageProcessingService;
  final MediaFileStore _mediaFileStore;

  Future<Result<StagedItemPicture, ItemPictureFailure>> execute(Uint8List sourceBytes) async {
    final processingResult = await _imageProcessingService.processPicture(sourceBytes);
    final processedPicture = processingResult.valueOrNull;
    if (processedPicture == null) return const Result.failure(PictureNotReadable());
    final storedReference = await _mediaFileStore.storePicture(processedPicture);
    return Result.success(
      StagedItemPicture(
        reference: ItemPictureReference(
          encryptedFileName: storedReference.fileName,
          thumbnailFileName: storedReference.thumbnailFileName,
          widthPixels: storedReference.widthPixels,
          heightPixels: storedReference.heightPixels,
          byteSize: storedReference.byteSize,
        ),
        pictureBytes: processedPicture.pictureBytes,
      ),
    );
  }
}

/// Deletes the files of a staged picture the user took back.
final class DiscardStagedItemPictureUseCase {
  const DiscardStagedItemPictureUseCase({required MediaFileStore mediaFileStore})
    : _mediaFileStore = mediaFileStore;

  final MediaFileStore _mediaFileStore;

  Future<void> execute(StagedItemPicture stagedPicture) =>
      _mediaFileStore.deleteFiles(stagedPicture.reference.allFileNames);
}

/// Makes a staged picture the picture of [ItemPictureOwner], replacing the
/// one it had.
final class AttachItemPictureUseCase {
  const AttachItemPictureUseCase({
    required ItemPictureRepository repository,
    required MediaFileStore mediaFileStore,
    required TransactionRunner transactionRunner,
    required DomainEventBus domainEventBus,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
  }) : _repository = repository,
       _mediaFileStore = mediaFileStore,
       _transactionRunner = transactionRunner,
       _domainEventBus = domainEventBus,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final ItemPictureRepository _repository;
  final MediaFileStore _mediaFileStore;
  final TransactionRunner _transactionRunner;
  final DomainEventBus _domainEventBus;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;

  Future<ItemPicture> execute({
    required ItemPictureOwner owner,
    required StagedItemPicture stagedPicture,
  }) async {
    final picture = ItemPicture(
      identifier: _identifierGenerator.createIdentifier(),
      owner: owner,
      reference: stagedPicture.reference,
      createdAt: _clock.nowUtc(),
    );
    final replacedPicture = await _transactionRunner.runInTransaction(() async {
      final previousPicture = await _repository.readPictureOf(owner);
      if (previousPicture != null) await _repository.deletePicture(previousPicture.identifier);
      await _repository.insertPicture(picture);
      return previousPicture;
    });
    // Row first, then the old files: a crash in between leaves orphan
    // files for the start-up sweep, never a row without its file.
    if (replacedPicture != null) {
      await _mediaFileStore.deleteFiles(replacedPicture.reference.allFileNames);
    }
    await _domainEventBus.publish(
      ItemPictureAttached(
        itemPictureIdentifier: picture.identifier,
        owner: owner,
        occurredAt: picture.createdAt,
      ),
    );
    return picture;
  }
}

/// Removes the picture of an owner, row first and files second.
final class RemoveItemPictureUseCase {
  const RemoveItemPictureUseCase({
    required ItemPictureRepository repository,
    required MediaFileStore mediaFileStore,
    required DomainEventBus domainEventBus,
    required Clock clock,
  }) : _repository = repository,
       _mediaFileStore = mediaFileStore,
       _domainEventBus = domainEventBus,
       _clock = clock;

  final ItemPictureRepository _repository;
  final MediaFileStore _mediaFileStore;
  final DomainEventBus _domainEventBus;
  final Clock _clock;

  /// Whether there was a picture to remove.
  Future<bool> execute(ItemPictureOwner owner) async {
    final picture = await _repository.readPictureOf(owner);
    if (picture == null) return false;
    await _repository.deletePicture(picture.identifier);
    await _mediaFileStore.deleteFiles(picture.reference.allFileNames);
    await _domainEventBus.publish(ItemPictureRemoved(owner: owner, occurredAt: _clock.nowUtc()));
    return true;
  }
}

/// What the start-up clean-up removed.
typedef ItemPictureCleanupReport = ({int removedPictures, int removedFiles});

/// Runs at every start (architecture document, section 10.2): removes
/// pictures of batches that are used up and of archived products (in case
/// an event was missed), rows whose files are gone, and files without a row
/// (a picture taken in a form that was never saved, or a crash between
/// writing a file and its row).
final class CleanUpItemPicturesUseCase {
  const CleanUpItemPicturesUseCase({
    required ItemPictureRepository repository,
    required MediaFileStore mediaFileStore,
    required InventoryQueryService inventory,
    required ProductCatalogQueryService productCatalog,
  }) : _repository = repository,
       _mediaFileStore = mediaFileStore,
       _inventory = inventory,
       _productCatalog = productCatalog;

  final ItemPictureRepository _repository;
  final MediaFileStore _mediaFileStore;
  final InventoryQueryService _inventory;
  final ProductCatalogQueryService _productCatalog;

  Future<ItemPictureCleanupReport> execute() async {
    final activeBatchIdentifiers = {
      for (final batch in await _inventory.readActiveBatches()) batch.identifier,
    };
    final catalog = await _productCatalog.readCatalog();
    final storedFileNames = await _mediaFileStore.listFileNames();
    final keptPictures = <ItemPicture>[];
    var removedPictureCount = 0;
    for (final picture in await _repository.readPictures()) {
      final ownerIsGone = switch (picture.owner) {
        StockBatchPictureOwner(:final stockBatchIdentifier) => !activeBatchIdentifiers.contains(
          stockBatchIdentifier,
        ),
        ProductPictureOwner(:final productIdentifier) =>
          catalog.productOf(productIdentifier)?.isArchived ?? true,
      };
      final filesAreMissing = !storedFileNames.containsAll(picture.reference.allFileNames);
      if (ownerIsGone || filesAreMissing) {
        await _repository.deletePicture(picture.identifier);
        removedPictureCount++;
      } else {
        keptPictures.add(picture);
      }
    }
    final removedFileCount = await _mediaFileStore.sweepOrphanFiles(
      ItemPictureCatalog(keptPictures).referencedFileNames,
    );
    return (removedPictures: removedPictureCount, removedFiles: removedFileCount);
  }
}
