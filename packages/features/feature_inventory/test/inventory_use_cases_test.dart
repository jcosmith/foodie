import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_inventory/src/application/inventory_providers.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/inventory_test_harness.dart';

void main() {
  late InventoryTestHarness harness;
  late List<Compartment> drawers;
  late Product mincedMeat;
  late Product fishFingers;

  setUp(() async {
    harness = InventoryTestHarness();
    drawers = await harness.setUpCatalogAndFreezer();
    mincedMeat = await harness.seededProduct('mincedMeat');
    fishFingers = await harness.seededProduct('fishFingers');
  });
  tearDown(() async {
    expect(await harness.repository.findInconsistentBatches(), isEmpty);
    await harness.dispose();
  });

  Quantity grams(int amount) => Quantity(amountInBaseUnits: amount, unit: QuantityUnit.gram);

  Future<StockBatchIdentifier> addMincedMeat({int grams = 500}) =>
      harness.addBatch(product: mincedMeat, compartment: drawers[0], amountInBaseUnits: grams);

  group('adding', () {
    test('puts a batch into the drawer and announces it', () async {
      final batchIdentifier = await addMincedMeat();

      final batch = await harness.readBatch(batchIdentifier);
      expect(batch.quantityRemaining, grams(500));
      expect(batch.compartmentIdentifier, drawers[0].identifier);
      expect(harness.publishedEvents.whereType<StockBatchAdded>().single.quantity, grams(500));
      expect(
        await harness
            .read(inventoryQueryServiceProvider)
            .readLastCompartmentOfProduct(mincedMeat.identifier),
        drawers[0].identifier,
      );
    });

    test('refuses nothing, a wrong unit and a date in the future', () async {
      final addStockBatch = harness.read(addStockBatchUseCaseProvider);
      AddStockBatchCommand command({required Quantity quantity, CalendarDate? frozenOn}) =>
          AddStockBatchCommand(
            productIdentifier: mincedMeat.identifier,
            compartmentIdentifier: drawers[0].identifier,
            quantity: quantity,
            frozenOn: frozenOn ?? InventoryTestHarness.today,
          );

      expect(
        (await addStockBatch.execute(command(quantity: grams(0)))).failureOrNull,
        isA<QuantityNotPositive>(),
      );
      expect(
        (await addStockBatch.execute(
          command(quantity: const Quantity(amountInBaseUnits: 1000, unit: QuantityUnit.piece)),
        )).failureOrNull,
        isA<QuantityUnitMismatch>(),
      );
      expect(
        (await addStockBatch.execute(
          command(quantity: grams(500), frozenOn: InventoryTestHarness.today.addDays(1)),
        )).failureOrNull,
        isA<FrozenOnInFuture>(),
      );
      expect(await harness.read(inventoryQueryServiceProvider).readActiveBatches(), isEmpty);
    });

    test('adds several bags at once, or none when one is wrong', () async {
      final addStockBatch = harness.read(addStockBatchUseCaseProvider);
      AddStockBatchCommand command(Product product, Quantity quantity) => AddStockBatchCommand(
        productIdentifier: product.identifier,
        compartmentIdentifier: drawers[1].identifier,
        quantity: quantity,
        frozenOn: InventoryTestHarness.today,
      );
      final fishFingerBox = fishFingers.defaultPackageQuantity!;

      final refused = await addStockBatch.executeAll([
        command(mincedMeat, grams(500)),
        command(fishFingers, grams(0)),
      ]);
      expect(refused.failureOrNull, isA<QuantityNotPositive>());
      expect(await harness.read(inventoryQueryServiceProvider).readActiveBatches(), isEmpty);
      expect(harness.publishedEvents.whereType<StockBatchAdded>(), isEmpty);

      final added = await addStockBatch.executeAll([
        command(mincedMeat, grams(500)),
        command(mincedMeat, grams(420)),
        command(fishFingers, fishFingerBox),
      ]);

      expect(added.valueOrNull, hasLength(3));
      expect(await harness.read(inventoryQueryServiceProvider).readActiveBatches(), hasLength(3));
      expect(harness.publishedEvents.whereType<StockBatchAdded>(), hasLength(3));
    });
  });

  group('taking out', () {
    test('takes part of a bag and leaves the rest', () async {
      final batchIdentifier = await addMincedMeat();

      final result = await harness
          .read(consumeStockUseCaseProvider)
          .execute(stockBatchIdentifier: batchIdentifier, quantity: grams(200));

      expect(result.valueOrNull!.quantityRemaining, grams(300));
      expect((await harness.readBatch(batchIdentifier)).quantityRemaining, grams(300));
      expect(harness.publishedEvents.whereType<StockBatchConsumed>().single.quantity, grams(200));
    });

    test('a used-up bag leaves the freezer list', () async {
      final batchIdentifier = await addMincedMeat();

      await harness
          .read(consumeStockUseCaseProvider)
          .execute(stockBatchIdentifier: batchIdentifier, quantity: grams(500));

      expect((await harness.readBatch(batchIdentifier)).isDepleted, isTrue);
      expect(await harness.read(inventoryQueryServiceProvider).readActiveBatches(), isEmpty);
    });

    test('refuses nothing and more than is left', () async {
      final batchIdentifier = await addMincedMeat();
      final consumeStock = harness.read(consumeStockUseCaseProvider);

      expect(
        (await consumeStock.execute(
          stockBatchIdentifier: batchIdentifier,
          quantity: grams(0),
        )).failureOrNull,
        isA<QuantityNotPositive>(),
      );
      expect(
        (await consumeStock.execute(
          stockBatchIdentifier: batchIdentifier,
          quantity: grams(501),
        )).failureOrNull,
        isA<QuantityExceedsRemaining>(),
      );
      expect((await harness.readBatch(batchIdentifier)).quantityRemaining, grams(500));
    });

    test('throwing away records the reason', () async {
      final batchIdentifier = await addMincedMeat();

      final result = await harness
          .read(discardStockUseCaseProvider)
          .execute(
            stockBatchIdentifier: batchIdentifier,
            quantity: grams(500),
            discardReason: DiscardReason.freezerBurn,
          );

      final movement = await harness.repository.readMovement(
        result.valueOrNull!.movementIdentifier,
      );
      expect(movement!.kind, MovementKind.discarded);
      expect(movement.discardReason, DiscardReason.freezerBurn);
      expect(movement.quantityDelta, grams(-500));
      expect(
        harness.publishedEvents.whereType<StockBatchDiscarded>().single.discardReason,
        DiscardReason.freezerBurn,
      );
    });

    test('undo puts the amount back once', () async {
      final batchIdentifier = await addMincedMeat();
      final removal =
          (await harness
                  .read(consumeStockUseCaseProvider)
                  .execute(stockBatchIdentifier: batchIdentifier, quantity: grams(500)))
              .valueOrNull!;
      final undoStockRemoval = harness.read(undoStockRemovalUseCaseProvider);

      expect((await undoStockRemoval.execute(removal.movementIdentifier)).isSuccess, isTrue);
      expect((await harness.readBatch(batchIdentifier)).quantityRemaining, grams(500));
      expect(
        (await undoStockRemoval.execute(removal.movementIdentifier)).failureOrNull,
        isA<MovementCannotBeUndone>(),
      );
      expect((await harness.readBatch(batchIdentifier)).quantityRemaining, grams(500));
    });
  });

  group('moving', () {
    test('moves a whole bag and keeps its identity', () async {
      final batchIdentifier = await addMincedMeat();

      final result = await harness
          .read(moveStockBatchUseCaseProvider)
          .execute(
            stockBatchIdentifier: batchIdentifier,
            destinationCompartmentIdentifier: drawers[1].identifier,
            quantity: grams(500),
          );

      expect(result.valueOrNull, batchIdentifier);
      expect(
        (await harness.readBatch(batchIdentifier)).compartmentIdentifier,
        drawers[1].identifier,
      );
      final moved = harness.publishedEvents.whereType<StockBatchMoved>().single;
      expect(moved.splitOffBatchIdentifier, isNull);
      expect(moved.sourceCompartmentIdentifier, drawers[0].identifier);
    });

    test('moving part of a bag splits it, keeping the freezing date', () async {
      final batchIdentifier = await harness.addBatch(
        product: fishFingers,
        compartment: drawers[0],
        amountInBaseUnits: 15000,
        frozenOn: InventoryTestHarness.today.addDays(-30),
      );

      final result = await harness
          .read(moveStockBatchUseCaseProvider)
          .execute(
            stockBatchIdentifier: batchIdentifier,
            destinationCompartmentIdentifier: drawers[2].identifier,
            quantity: const Quantity(amountInBaseUnits: 5000, unit: QuantityUnit.piece),
          );

      final splitOffBatch = await harness.readBatch(result.valueOrNull!);
      final originalBatch = await harness.readBatch(batchIdentifier);
      expect(splitOffBatch.identifier, isNot(batchIdentifier));
      expect(splitOffBatch.parentBatchIdentifier, batchIdentifier);
      expect(splitOffBatch.compartmentIdentifier, drawers[2].identifier);
      expect(splitOffBatch.quantityRemaining.amountInBaseUnits, 5000);
      expect(splitOffBatch.frozenOn, originalBatch.frozenOn);
      expect(originalBatch.quantityRemaining.amountInBaseUnits, 10000);
      expect(originalBatch.compartmentIdentifier, drawers[0].identifier);
    });

    test('refuses the drawer it is already in', () async {
      final batchIdentifier = await addMincedMeat();

      final result = await harness
          .read(moveStockBatchUseCaseProvider)
          .execute(
            stockBatchIdentifier: batchIdentifier,
            destinationCompartmentIdentifier: drawers[0].identifier,
            quantity: grams(500),
          );

      expect(result.failureOrNull, isA<AlreadyInCompartment>());
    });
  });

  group('correcting', () {
    test('sets what is really left', () async {
      final batchIdentifier = await addMincedMeat();
      final correctRemainingQuantity = harness.read(correctRemainingQuantityUseCaseProvider);

      await correctRemainingQuantity.execute(
        stockBatchIdentifier: batchIdentifier,
        actualRemainingQuantity: grams(350),
      );

      expect((await harness.readBatch(batchIdentifier)).quantityRemaining, grams(350));
      expect(
        harness.publishedEvents.whereType<StockBatchCorrected>().single.quantityDelta,
        grams(-150),
      );
      expect(
        (await correctRemainingQuantity.execute(
          stockBatchIdentifier: batchIdentifier,
          actualRemainingQuantity: grams(350),
        )).failureOrNull,
        isA<QuantityUnchanged>(),
      );
    });
  });

  group('compartment contents for the storage layout', () {
    test('counts items per drawer and moves them all out', () async {
      await addMincedMeat();
      await addMincedMeat(grams: 250);
      final compartmentContents = harness.read(compartmentContentsPortProvider);

      expect(await compartmentContents.countItemsInCompartment(drawers[0].identifier), 2);
      await harness
          .read(transactionRunnerProvider)
          .runInTransaction(
            () => compartmentContents.moveAllContents(
              sourceCompartmentIdentifier: drawers[0].identifier,
              destinationCompartmentIdentifier: drawers[1].identifier,
            ),
          );

      expect(await compartmentContents.watchItemCountsByCompartment().first, {
        drawers[1].identifier: 2,
      });
    });
  });

  test('the overview joins products, drawers and storage age', () async {
    await harness.addBatch(
      product: mincedMeat,
      compartment: drawers[1],
      amountInBaseUnits: 500,
      frozenOn: InventoryTestHarness.today.addDays(-250),
    );

    // Riverpod pauses providers nobody listens to.
    final subscription = harness.container.listen(inventoryOverviewProvider, (_, _) {});
    addTearDown(subscription.close);
    final overview = await harness.container.read(inventoryOverviewProvider.future);

    final item = overview.items.single;
    expect(item.product.identifier, mincedMeat.identifier);
    expect(item.compartment?.identifier, drawers[1].identifier);
    expect(item.storageAgeStatus, StorageAgeStatus.urgent);
    expect(overview.itemsIn(drawers[1].identifier), [item]);
  });
}
