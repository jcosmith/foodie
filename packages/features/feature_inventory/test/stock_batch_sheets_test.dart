import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/inventory_test_harness.dart';
import 'support/shelves_module.dart';

void main() {
  late InventoryTestHarness harness;
  late StockBatchIdentifier breadIdentifier;
  final today = InventoryTestHarness.today;

  setUp(
    () => harness = InventoryTestHarness(
      registeredModules: const [FreezerFeatureModule(), ShelvesModule()],
    ),
  );
  tearDown(() => harness.dispose());

  Future<void> settle(WidgetTester tester) async {
    for (var round = 0; round < 3; round++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
    }
  }

  /// Bread bought five days ago on a cupboard shelf, shown in the shelves tab.
  Future<void> showShelvesTab(
    WidgetTester tester, {
    int amountInBaseUnits = 1000,
    Future<void> Function(StockBatchIdentifier batch)? beforeShowing,
  }) async {
    breadIdentifier = (await tester.runAsync(() async {
      await harness.setUpCatalogAndStoragePlace();
      final shelves = await harness.addStoragePlace(ShelvesModule.cupboard);
      return harness.addBatch(
        product: await harness.seededProduct('wholegrainBread'),
        compartment: shelves.first,
        amountInBaseUnits: amountInBaseUnits,
        storedOn: today.addDays(-5),
        bestBeforeOn: today.addDays(3),
      );
    }))!;
    if (beforeShowing != null) await tester.runAsync(() => beforeShowing(breadIdentifier));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: [
            ...const InventoryFeatureModule().localizationDelegates,
            ...const ProductCatalogFeatureModule().localizationDelegates,
            ...const StorageLayoutFeatureModule().localizationDelegates,
          ],
          home: const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.pantry),
        ),
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Wholegrain bread'));
    await settle(tester);
  }

  testWidgets('marking a batch as opened is one tap and can be undone', (tester) async {
    await showShelvesTab(tester);

    await tester.tap(find.text('Mark as opened'));
    await settle(tester);

    expect(find.text('Wholegrain bread marked as opened'), findsOneWidget);
    expect((await tester.runAsync(() => harness.readBatch(breadIdentifier)))!.openedOn, today);
    expect(find.text('opened today'), findsOneWidget);

    await tester.tap(find.text('Wholegrain bread'));
    await settle(tester);
    expect(find.text('Mark as opened'), findsNothing, reason: 'it is opened already');
    expect(find.text('Mark as not opened'), findsOneWidget);
    await tester.tap(find.text('Mark as not opened'));
    await settle(tester);
    expect((await tester.runAsync(() => harness.readBatch(breadIdentifier)))!.openedOn, isNull);
  });

  testWidgets('taking out starts with the usual amount of the product', (tester) async {
    await showShelvesTab(
      tester,
      amountInBaseUnits: 8000,
      beforeShowing: (batch) async {
        final consume = harness.read(consumeStockUseCaseProvider);
        for (final thousandths in [2000, 3000]) {
          await consume.execute(
            stockBatchIdentifier: batch,
            quantity: Quantity(amountInBaseUnits: thousandths, unit: QuantityUnit.piece),
          );
        }
      },
    );

    expect(find.text('Usually 2.5 pcs'), findsOneWidget);
    expect(find.text('Take 2.5 pcs'), findsOneWidget);
  });

  testWidgets('without earlier removals the take sheet starts at about a fifth', (tester) async {
    await showShelvesTab(tester, amountInBaseUnits: 10000);

    expect(find.textContaining('Usually'), findsNothing);
    expect(find.text('Take 2 pcs'), findsOneWidget);
  });

  testWidgets('moving into the freezer offers "Frozen today", switched on', (tester) async {
    await showShelvesTab(tester);

    await tester.tap(find.text('Move'));
    await settle(tester);
    expect(find.text('Frozen today'), findsNothing, reason: 'another shelf is chosen first');

    final drawerChip = find.ancestor(
      of: find.textContaining('Drawer 1'),
      matching: find.byType(ChoiceChip),
    );
    await tester.ensureVisible(drawerChip);
    await tester.tap(drawerChip);
    await settle(tester);
    expect(
      tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Frozen today')).value,
      isTrue,
    );

    await tester.ensureVisible(find.byType(FilledButton).last);
    await tester.tap(find.byType(FilledButton).last);
    await settle(tester);

    final moved = (await tester.runAsync(() => harness.readBatch(breadIdentifier)))!;
    expect(moved.storedOn, today);
    expect(moved.bestBeforeOn, isNull);
  });

  testWidgets('switching "Frozen today" off keeps the dates', (tester) async {
    await showShelvesTab(tester);

    await tester.tap(find.text('Move'));
    await settle(tester);
    final drawerChip = find.ancestor(
      of: find.textContaining('Drawer 1'),
      matching: find.byType(ChoiceChip),
    );
    await tester.ensureVisible(drawerChip);
    await tester.tap(drawerChip);
    await settle(tester);
    await tester.tap(find.text('Frozen today'));
    await settle(tester);
    await tester.ensureVisible(find.byType(FilledButton).last);
    await tester.tap(find.byType(FilledButton).last);
    await settle(tester);

    final moved = (await tester.runAsync(() => harness.readBatch(breadIdentifier)))!;
    expect(moved.storedOn, today.addDays(-5));
    expect(moved.bestBeforeOn, today.addDays(3));
  });
}
