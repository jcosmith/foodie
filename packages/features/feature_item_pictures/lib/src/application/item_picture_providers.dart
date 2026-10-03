import 'dart:typed_data';

import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/item_picture.dart';
import '../domain/item_picture_cleanup_policy.dart';
import '../domain/item_picture_repository.dart';
import 'item_picture_use_cases.dart';
import 'picture_source.dart';

/// Bound to the Drift repository by the module's provider overrides.
final itemPictureRepositoryProvider = Provider<ItemPictureRepository>(
  (ref) => throw UnimplementedError('itemPictureRepositoryProvider must be overridden'),
);

/// Bound to the camera and photo picker by the module's provider overrides.
final pictureSourceProvider = Provider<PictureSource>(
  (ref) => throw UnimplementedError('pictureSourceProvider must be overridden'),
);

final itemPictureCatalogProvider = StreamProvider<ItemPictureCatalog>(
  (ref) => ref.watch(itemPictureRepositoryProvider).watchPictures().map(ItemPictureCatalog.new),
);

/// Decrypted thumbnails, kept in memory once read (architecture document,
/// section 10.2: thumbnails are decrypted lazily and cached).
final pictureThumbnailBytesProvider = FutureProvider.family<Uint8List, String>(
  (ref, thumbnailFileName) => ref.watch(mediaFileStoreProvider).readFile(thumbnailFileName),
);

/// A decrypted full-size picture, released when no screen shows it.
final pictureBytesProvider = FutureProvider.autoDispose.family<Uint8List, String>(
  (ref, encryptedFileName) => ref.watch(mediaFileStoreProvider).readFile(encryptedFileName),
);

final stageItemPictureUseCaseProvider = Provider<StageItemPictureUseCase>(
  (ref) => StageItemPictureUseCase(
    imageProcessingService: ref.watch(imageProcessingServiceProvider),
    mediaFileStore: ref.watch(mediaFileStoreProvider),
  ),
);

final discardStagedItemPictureUseCaseProvider = Provider<DiscardStagedItemPictureUseCase>(
  (ref) => DiscardStagedItemPictureUseCase(mediaFileStore: ref.watch(mediaFileStoreProvider)),
);

final attachItemPictureUseCaseProvider = Provider<AttachItemPictureUseCase>(
  (ref) => AttachItemPictureUseCase(
    repository: ref.watch(itemPictureRepositoryProvider),
    mediaFileStore: ref.watch(mediaFileStoreProvider),
    transactionRunner: ref.watch(transactionRunnerProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
  ),
);

final removeItemPictureUseCaseProvider = Provider<RemoveItemPictureUseCase>(
  (ref) => RemoveItemPictureUseCase(
    repository: ref.watch(itemPictureRepositoryProvider),
    mediaFileStore: ref.watch(mediaFileStoreProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
  ),
);

final cleanUpItemPicturesUseCaseProvider = Provider<CleanUpItemPicturesUseCase>(
  (ref) => CleanUpItemPicturesUseCase(
    repository: ref.watch(itemPictureRepositoryProvider),
    mediaFileStore: ref.watch(mediaFileStoreProvider),
    inventory: ref.watch(inventoryQueryServiceProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
  ),
);

/// Removes pictures as soon as their item goes away; the start-up clean-up
/// catches anything an event missed.
final itemPictureCleanupSubscriptionProvider = Provider<DomainEventSubscription>((ref) {
  final removeItemPicture = ref.watch(removeItemPictureUseCaseProvider);
  final subscription = ref.watch(domainEventBusProvider).subscribe<DomainEvent>((event) async {
    final owner = ItemPictureCleanupPolicy.ownerToCleanUpAfter(event);
    if (owner != null) await removeItemPicture.execute(owner);
  });
  ref.onDispose(subscription.cancel);
  return subscription;
});
