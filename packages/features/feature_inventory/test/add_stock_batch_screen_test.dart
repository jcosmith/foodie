import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_inventory/feature_inventory.dart';
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

  setUp(() => harness = InventoryTestHarness());
  tearDown(() => harness.dispose());

  /// Minced meat went into drawer 1 last time; [defaultDrawerIndex] sets its
  /// default drawer.
  Future<void> showAddFormForMincedMeat(WidgetTester tester, {int? defaultDrawerIndex}) async {
    final mincedMeat = await tester.runAsync(() async {
      final drawers = await harness.setUpCatalogAndStoragePlace();
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

  group('adding inside a domain tab', () {
    late InventoryTestHarness twoDomains;

    setUp(() async {
      twoDomains = InventoryTestHarness(
        registeredModules: const [FreezerFeatureModule(), ShelvesModule()],
      );
    });
    tearDown(() => twoDomains.dispose());

    Future<void> showAddForm(WidgetTester tester, {StorageDomainIdentifier? domain}) async {
      await tester.runAsync(() async {
        await twoDomains.setUpCatalogAndStoragePlace();
        await twoDomains.addStoragePlace(ShelvesModule.cupboard);
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: twoDomains.container,
          child: buildLocalizedTestApplication(
            featureLocalizationDelegates: [
              ...const InventoryFeatureModule().localizationDelegates,
              ...const ProductCatalogFeatureModule().localizationDelegates,
              ...const StorageLayoutFeatureModule().localizationDelegates,
            ],
            home: AddStockBatchScreen(domainIdentifier: domain),
          ),
        ),
      );
      for (var round = 0; round < 3; round++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('offers only the domain\'s compartments, with its words', (tester) async {
      await showAddForm(tester, domain: StorageDomainIdentifier.pantry);

      expect(find.text('Add to the cupboard'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Shelf 1'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Drawer 1'), findsNothing);
      expect(find.text('Bought on'), findsOneWidget);
    });

    testWidgets('the freezer tab adds frozen food', (tester) async {
      await showAddForm(tester, domain: StorageDomainIdentifier.freezer);

      expect(find.text('Add to the freezer'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Shelf 1'), findsNothing);
      expect(find.text('Frozen on'), findsOneWidget);
    });

    testWidgets('from Home, every place is offered and the date follows the choice', (
      tester,
    ) async {
      await showAddForm(tester);
      expect(find.text('Add'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Drawer 1'), findsOneWidget);

      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Shelf 2'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Shelf 2'));
      await tester.pumpAndSettle();
      expect(find.text('Bought on'), findsOneWidget);
    });
  });
}
