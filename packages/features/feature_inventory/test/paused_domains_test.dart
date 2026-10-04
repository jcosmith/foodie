import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_inventory/src/application/inventory_providers.dart';
import 'package:feature_inventory/src/presentation/add_stock_batch_screen.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/inventory_test_harness.dart';
import 'support/shelves_module.dart';

void main() {
  late InventoryTestHarness harness;

  /// Minced meat in the freezer and peas on a shelf, with the shelves'
  /// domain switched off.
  Future<void> setUpWithShelvesSwitchedOff() async {
    final drawers = await harness.setUpCatalogAndStoragePlace();
    final shelves = await harness.addStoragePlace(ShelvesModule.cupboard);
    await harness.addBatch(
      product: await harness.seededProduct('mincedMeat'),
      compartment: drawers.first,
      amountInBaseUnits: 500,
    );
    await harness.addBatch(
      product: await harness.seededProduct('gardenPeas'),
      compartment: shelves.first,
      amountInBaseUnits: 750,
    );
  }

  setUp(
    () => harness = InventoryTestHarness(
      registeredModules: const [FreezerFeatureModule(), ShelvesModule()],
      enabledModules: const [FreezerFeatureModule()],
    ),
  );
  tearDown(() => harness.dispose());

  test('the overview leaves out the places and items of a switched-off domain', () async {
    await setUpWithShelvesSwitchedOff();
    final subscription = harness.container.listen(inventoryOverviewProvider, (_, _) {});
    addTearDown(subscription.close);
    await harness.container.read(enabledFeatureModulesProvider.future);
    final overview = await harness.container.read(inventoryOverviewProvider.future);

    expect(overview.items.map((item) => item.product.catalogKey), ['mincedMeat']);
    expect(overview.layout.storagePlaces.map((place) => place.domainIdentifier), [
      StorageDomainIdentifier.freezer,
    ]);
  });

  test('nothing is deleted while the domain is switched off', () async {
    await setUpWithShelvesSwitchedOff();
    final batches = await harness.read(inventoryQueryServiceProvider).watchActiveBatches().first;
    expect(batches, hasLength(2));
  });

  testWidgets('adding from Home offers no place of a switched-off domain', (tester) async {
    await tester.runAsync(setUpWithShelvesSwitchedOff);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: [
            ...const InventoryFeatureModule().localizationDelegates,
            ...const ProductCatalogFeatureModule().localizationDelegates,
            ...const StorageLayoutFeatureModule().localizationDelegates,
          ],
          home: const AddStockBatchScreen(),
        ),
      ),
    );
    for (var round = 0; round < 3; round++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
    }

    expect(find.widgetWithText(ChoiceChip, 'Drawer 1'), findsOneWidget);
    expect(find.textContaining('Shelf'), findsNothing);
  });
}
