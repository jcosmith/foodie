import 'package:core_design_system/testing.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_inventory/src/presentation/add_stock_batch_screen.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/inventory_test_harness.dart';

void main() {
  late InventoryTestHarness harness;

  setUp(() => harness = InventoryTestHarness());
  tearDown(() => harness.dispose());

  /// Minced meat went into drawer 1 last time; [defaultDrawerIndex] sets its
  /// default drawer.
  Future<void> showAddFormForMincedMeat(WidgetTester tester, {int? defaultDrawerIndex}) async {
    final mincedMeat = await tester.runAsync(() async {
      final drawers = await harness.setUpCatalogAndFreezer();
      final mincedMeat = await harness.seededProduct('mincedMeat');
      await harness.addBatch(product: mincedMeat, compartment: drawers[0], amountInBaseUnits: 500);
      if (defaultDrawerIndex != null) {
        await harness.database.customStatement(
          'UPDATE products SET default_compartment_identifier = ? WHERE product_identifier = ?',
          [drawers[defaultDrawerIndex].identifier.value, mincedMeat.identifier.value],
        );
      }
      return mincedMeat;
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: [
            ...const InventoryFeatureModule().localizationDelegates,
            ...const ProductCatalogFeatureModule().localizationDelegates,
            ...const StorageLayoutFeatureModule().localizationDelegates,
          ],
          home: AddStockBatchScreen(initialProductIdentifier: mincedMeat!.identifier),
        ),
      ),
    );
    for (var round = 0; round < 3; round++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
    }
  }

  bool isDrawerSelected(WidgetTester tester, String drawerName) =>
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, drawerName)).selected;

  testWidgets('preselects the product’s default drawer', (tester) async {
    await showAddFormForMincedMeat(tester, defaultDrawerIndex: 2);

    expect(isDrawerSelected(tester, 'Drawer 3'), isTrue);
    expect(isDrawerSelected(tester, 'Drawer 1'), isFalse);
  });

  testWidgets('without a default drawer, preselects the drawer used last time', (tester) async {
    await showAddFormForMincedMeat(tester);

    expect(isDrawerSelected(tester, 'Drawer 1'), isTrue);
    expect(isDrawerSelected(tester, 'Drawer 3'), isFalse);
  });
}
