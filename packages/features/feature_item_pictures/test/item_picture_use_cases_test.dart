import 'dart:typed_data';

import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_media_storage/testing.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_item_pictures/feature_item_pictures.dart';
import 'package:feature_item_pictures/src/application/item_picture_providers.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/item_pictures_test_harness.dart';

void main() {
  late ItemPicturesTestHarness harness;

  setUp(() async {
    harness = ItemPicturesTestHarness();
    await harness.seedCatalogAndStoragePlace();
    await harness.startPictureModule();
  });
  tearDown(() => harness.dispose());

  Future<StagedItemPicture> stage({int red = 200}) async =>
      (await harness.read(stageItemPictureUseCaseProvider).execute(createTestPhotoBytes(red: red)))
          .valueOrNull!;

  test('a staged picture is stored first and attached second', () async {
    final spinach = await harness.productWithKey('leafSpinach');

    final stagedPicture = await stage();
    expect(harness.mediaFileStore.filesByName.keys, stagedPicture.reference.allFileNames);
    expect(await harness.readPictures(), isEmpty);

    final picture = await harness
        .read(attachItemPictureUseCaseProvider)
        .execute(owner: ProductPictureOwner(spinach.identifier), stagedPicture: stagedPicture);

    expect(await harness.readPictures(), [picture]);
    expect(picture.reference.widthPixels, 64);
    expect(harness.publishedEvents.whereType<ItemPictureAttached>().single.owner, picture.owner);
  });

  test('a new picture replaces the old one and deletes its files', () async {
    final spinach = await harness.productWithKey('leafSpinach');
    final owner = ProductPictureOwner(spinach.identifier);
    final attach = harness.read(attachItemPictureUseCaseProvider);
    final firstPicture = await attach.execute(owner: owner, stagedPicture: await stage());

    final secondPicture = await attach.execute(owner: owner, stagedPicture: await stage(red: 20));

    expect(await harness.readPictures(), [secondPicture]);
    expect(harness.mediaFileStore.filesByName.keys, secondPicture.reference.allFileNames);
    expect(
      harness.mediaFileStore.filesByName.keys.toSet().intersection(
        firstPicture.reference.allFileNames,
      ),
      isEmpty,
    );
  });

  test('refuses files that are no picture', () async {
    final result = await harness
        .read(stageItemPictureUseCaseProvider)
        .execute(Uint8List.fromList('a text file'.codeUnits));

    expect(result.failureOrNull, isA<PictureNotReadable>());
    expect(harness.mediaFileStore.filesByName, isEmpty);
  });

  test('removing a picture deletes its row and its files', () async {
    final spinach = await harness.productWithKey('leafSpinach');
    final owner = ProductPictureOwner(spinach.identifier);
    await harness
        .read(attachItemPictureUseCaseProvider)
        .execute(owner: owner, stagedPicture: await stage());

    expect(await harness.read(removeItemPictureUseCaseProvider).execute(owner), isTrue);

    expect(await harness.readPictures(), isEmpty);
    expect(harness.mediaFileStore.filesByName, isEmpty);
    expect(harness.publishedEvents.whereType<ItemPictureRemoved>(), hasLength(1));
    expect(await harness.read(removeItemPictureUseCaseProvider).execute(owner), isFalse);
  });

  test('a used-up batch and an archived product lose their pictures', () async {
    final spinach = await harness.productWithKey('leafSpinach');
    final peas = await harness.productWithKey('gardenPeas');
    final batch = await harness.addBatch(spinach, amountInBaseUnits: 500);
    final attach = harness.read(attachItemPictureUseCaseProvider);
    await attach.execute(owner: StockBatchPictureOwner(batch), stagedPicture: await stage());
    final peasPicture = await attach.execute(
      owner: ProductPictureOwner(peas.identifier),
      stagedPicture: await stage(),
    );

    await harness
        .read(consumeStockUseCaseProvider)
        .execute(
          stockBatchIdentifier: batch,
          quantity: const Quantity(amountInBaseUnits: 200, unit: QuantityUnit.gram),
        );
    expect(await harness.readPictures(), hasLength(2));

    await harness
        .read(consumeStockUseCaseProvider)
        .execute(
          stockBatchIdentifier: batch,
          quantity: const Quantity(amountInBaseUnits: 300, unit: QuantityUnit.gram),
        );
    await pumpEventQueue();
    expect(await harness.readPictures(), [peasPicture]);

    await harness
        .read(domainEventBusProvider)
        .publish(
          ProductArchived(productIdentifier: peas.identifier, occurredAt: harness.clock.nowUtc()),
        );
    expect(await harness.readPictures(), isEmpty);
    expect(harness.mediaFileStore.filesByName, isEmpty);
  });

  test('the start-up clean-up removes orphans in both directions', () async {
    final spinach = await harness.productWithKey('leafSpinach');
    final peas = await harness.productWithKey('gardenPeas');
    final attach = harness.read(attachItemPictureUseCaseProvider);
    final keptPicture = await attach.execute(
      owner: ProductPictureOwner(spinach.identifier),
      stagedPicture: await stage(),
    );
    final pictureWithoutFile = await attach.execute(
      owner: ProductPictureOwner(peas.identifier),
      stagedPicture: await stage(),
    );
    // A batch that was never saved, such as one from a crashed add form.
    await attach.execute(
      owner: const StockBatchPictureOwner(StockBatchIdentifier('gone')),
      stagedPicture: await stage(),
    );
    // A picture taken in a form that was then left.
    final abandonedPicture = await stage();
    await harness.mediaFileStore.deleteFiles([pictureWithoutFile.reference.thumbnailFileName]);

    final report = await harness.read(cleanUpItemPicturesUseCaseProvider).execute();

    expect(await harness.readPictures(), [keptPicture]);
    expect(report.removedPictures, 2);
    // The abandoned pair, the gone batch's pair and the lone picture file.
    expect(report.removedFiles, 5);
    expect(harness.mediaFileStore.filesByName.keys, keptPicture.reference.allFileNames);
    expect(
      harness.mediaFileStore.filesByName.keys.toSet().intersection(
        abandonedPicture.reference.allFileNames,
      ),
      isEmpty,
    );
  });

  test('the clean-up policy names the owner whose picture goes', () {
    final occurredAt = DateTime.utc(2026, 10, 2);
    const batch = StockBatchIdentifier('batch');
    StockBatchConsumed consumed(int remaining) => StockBatchConsumed(
      stockBatchIdentifier: batch,
      productIdentifier: const ProductIdentifier('product'),
      movementIdentifier: const InventoryMovementIdentifier('movement'),
      quantity: const Quantity(amountInBaseUnits: 100, unit: QuantityUnit.gram),
      quantityRemaining: Quantity(amountInBaseUnits: remaining, unit: QuantityUnit.gram),
      occurredAt: occurredAt,
    );

    expect(ItemPictureCleanupPolicy.ownerToCleanUpAfter(consumed(100)), isNull);
    expect(
      ItemPictureCleanupPolicy.ownerToCleanUpAfter(consumed(0)),
      const StockBatchPictureOwner(batch),
    );
  });

  test('stored pictures carry no location data', () async {
    final stagedPicture = await stage();
    final storedBytes =
        harness.mediaFileStore.filesByName[stagedPicture.reference.encryptedFileName]!;

    expect(String.fromCharCodes(storedBytes).contains('Exif'), isFalse);
    expect(ImageProcessingService.maximumLongestEdgeInPixels, 1600);
  });
}
