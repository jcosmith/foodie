import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_restock/feature_restock.dart';
import 'package:feature_restock/src/application/restock_providers.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/restock_test_harness.dart';

Quantity _grams(int grams) => Quantity(amountInBaseUnits: grams, unit: QuantityUnit.gram);

void main() {
  late RestockTestHarness harness;
  late Product spinach;

  Future<List<ShoppingListEntry>> shoppingList() =>
      harness.read(restockRepositoryProvider).readShoppingList();

  Future<Quantity> stockOf(Product product) async {
    final batches = await harness
        .read(inventoryQueryServiceProvider)
        .readActiveBatchesOfProduct(product.identifier);
    return batches.fold<Quantity>(
      Quantity.zero(product.canonicalUnit),
      (sum, batch) => sum + batch.quantityRemaining,
    );
  }

  setUp(() async {
    harness = RestockTestHarness();
    await harness.seedCatalogAndStoragePlace();
    await const RestockFeatureModule().initializeModule(harness.initializationContext);
    spinach = await harness.productWithKey('leafSpinach');
  });
  tearDown(() => harness.dispose());

  test('a minimum puts a running-low product on the list and stock takes it off', () async {
    await harness
        .read(saveRestockRuleUseCaseProvider)
        .execute(productIdentifier: spinach.identifier, minimumQuantity: _grams(1500));
    final listWhenEmpty = await shoppingList();

    await harness.addBatch(spinach, quantity: _grams(1000));
    final listAfterOneBag = await shoppingList();
    await harness.addBatch(spinach, quantity: _grams(1000));
    final listWhenStocked = await shoppingList();

    expect(listWhenEmpty.single.isAutomatic, isTrue);
    expect(listWhenEmpty.single.requestedQuantity, _grams(1500));
    expect(listAfterOneBag.single.requestedQuantity, _grams(1000));
    expect(listWhenStocked, isEmpty);
    expect(harness.publishedEvents.whereType<ShoppingListEntryAdded>(), hasLength(1));
  });

  test('eating food below the minimum puts it on the list', () async {
    final batchIdentifier = await harness.addBatch(spinach, quantity: _grams(2000));
    await harness
        .read(saveRestockRuleUseCaseProvider)
        .execute(productIdentifier: spinach.identifier, minimumQuantity: _grams(1500));
    expect(await shoppingList(), isEmpty);

    await harness
        .read(consumeStockUseCaseProvider)
        .execute(stockBatchIdentifier: batchIdentifier, quantity: _grams(800));

    expect((await shoppingList()).single.productIdentifier, spinach.identifier);
  });

  test('refuses a minimum of zero, a target below it and another unit', () async {
    final saveRule = harness.read(saveRestockRuleUseCaseProvider);

    expect(
      (await saveRule.execute(
        productIdentifier: spinach.identifier,
        minimumQuantity: _grams(0),
      )).failureOrNull,
      isA<MinimumQuantityNotPositive>(),
    );
    expect(
      (await saveRule.execute(
        productIdentifier: spinach.identifier,
        minimumQuantity: _grams(1000),
        targetQuantity: _grams(500),
      )).failureOrNull,
      isA<TargetBelowMinimum>(),
    );
    expect(
      (await saveRule.execute(
        productIdentifier: spinach.identifier,
        minimumQuantity: Quantity.fromDisplayAmount(2, QuantityUnit.piece),
      )).failureOrNull,
      isA<RestockUnitMismatch>(),
    );
  });

  test('ticked items go into the drawer the product went into last time', () async {
    final peas = await harness.productWithKey('gardenPeas');
    final previousBatch = await harness.addBatch(peas, compartmentIndex: 2);
    await harness
        .read(consumeStockUseCaseProvider)
        .execute(
          stockBatchIdentifier: previousBatch,
          quantity: (await harness.read(inventoryQueryServiceProvider).readBatch(previousBatch))!
              .quantityRemaining,
        );
    final entryIdentifier =
        (await harness.read(addProductToShoppingListUseCaseProvider).execute(peas.identifier))
            .valueOrNull!;
    await harness
        .read(tickShoppingListEntryUseCaseProvider)
        .execute(entryIdentifier, isChecked: true);

    final result = await harness.read(putTickedItemsAwayUseCaseProvider).execute();

    final layout = await harness.read(storageLayoutQueryServiceProvider).readStorageLayout();
    final newBatch =
        (await harness
                .read(inventoryQueryServiceProvider)
                .readActiveBatchesOfProduct(peas.identifier))
            .single;
    expect(result.valueOrNull, 1);
    expect(newBatch.compartmentIdentifier, layout.activeCompartments[2].identifier);
    expect(newBatch.quantityRemaining, peas.defaultPackageQuantity);
    expect(newBatch.storedOn, harness.today);
    expect(await shoppingList(), isEmpty);
  });

  test('a running-low entry stays until the minimum is reached', () async {
    await harness
        .read(saveRestockRuleUseCaseProvider)
        .execute(
          productIdentifier: spinach.identifier,
          minimumQuantity: _grams(3000),
          targetQuantity: _grams(3000),
        );
    final automaticEntry = (await shoppingList()).single;
    expect(
      (await harness
              .read(removeShoppingListEntryUseCaseProvider)
              .execute(automaticEntry.identifier))
          .failureOrNull,
      isA<AutomaticEntryCannotBeRemoved>(),
    );
    await harness
        .read(tickShoppingListEntryUseCaseProvider)
        .execute(automaticEntry.identifier, isChecked: true);

    await harness.read(putTickedItemsAwayUseCaseProvider).execute();

    expect(await stockOf(spinach), _grams(3000));
    expect(await shoppingList(), isEmpty);
  });

  test('the same product is not added to the list twice', () async {
    final addToList = harness.read(addProductToShoppingListUseCaseProvider);

    final first = await addToList.execute(spinach.identifier);
    final second = await addToList.execute(spinach.identifier);

    expect(second.valueOrNull, first.valueOrNull);
    expect(await shoppingList(), hasLength(1));
  });

  test('removing a minimum takes its entry off the list', () async {
    await harness
        .read(saveRestockRuleUseCaseProvider)
        .execute(productIdentifier: spinach.identifier, minimumQuantity: _grams(1500));

    await harness.read(removeRestockRuleUseCaseProvider).execute(spinach.identifier);

    expect(await shoppingList(), isEmpty);
  });

  group('a switched-off domain', () {
    late RestockTestHarness pausedFreezer;
    late Product pausedSpinach;

    setUp(() async {
      pausedFreezer = RestockTestHarness(
        registeredModules: const [FreezerFeatureModule(), _PantryModule()],
        enabledModules: const [_PantryModule()],
      );
      await pausedFreezer.seedCatalogAndStoragePlace();
      // Riverpod pauses providers nobody listens to.
      final switches = pausedFreezer.container.listen(enabledFeatureModulesProvider, (_, _) {});
      addTearDown(switches.close);
      await pausedFreezer.read(enabledFeatureModulesProvider.future);
      await const RestockFeatureModule().initializeModule(pausedFreezer.initializationContext);
      pausedSpinach = await pausedFreezer.productWithKey('leafSpinach');
    });
    tearDown(() => pausedFreezer.dispose());

    test('pauses the minimums of its products', () async {
      await pausedFreezer
          .read(saveRestockRuleUseCaseProvider)
          .execute(productIdentifier: pausedSpinach.identifier, minimumQuantity: _grams(1500));

      expect(await pausedFreezer.read(restockRepositoryProvider).readShoppingList(), isEmpty);
      expect(await pausedFreezer.read(restockRepositoryProvider).readRules(), hasLength(1));
      final runningLow = pausedFreezer.container.listen(runningLowProductsProvider, (_, _) {});
      addTearDown(runningLow.close);
      await pausedFreezer.read(restockRulesProvider.future);
      await pausedFreezer.read(stockByProductProvider.future);
      await pausedFreezer.read(productCatalogProvider.future);
      expect(pausedFreezer.read(runningLowProductsProvider), isEmpty);
    });

    test('hides its products on the shopping list without deleting them', () async {
      await pausedFreezer
          .read(addProductToShoppingListUseCaseProvider)
          .execute(pausedSpinach.identifier);
      final subscription = pausedFreezer.container.listen(shoppingListEntriesProvider, (_, _) {});
      addTearDown(subscription.close);

      expect(await pausedFreezer.read(shoppingListEntriesProvider.future), isEmpty);
      expect(await pausedFreezer.read(restockRepositoryProvider).readShoppingList(), hasLength(1));
    });
  });
}

String _label(BuildContext context) => 'Pantry';

/// Another domain, so the freezer can be the one switched off.
final class _PantryModule extends FeatureModuleBase {
  const _PantryModule();

  @override
  String get moduleIdentifier => 'pantry';

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: true);

  @override
  StorageDomainContribution get storageDomain => const StorageDomainContribution(
    identifier: StorageDomainIdentifier.pantry,
    sortOrder: 30,
    iconEmoji: '🥫',
    labelBuilder: _label,
    descriptionBuilder: _label,
    storedOnLabelBuilder: _label,
    countsDiscardsAsWaste: true,
  );
}
