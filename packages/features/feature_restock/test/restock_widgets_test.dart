import 'package:core_design_system/core_design_system.dart';
import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_restock/feature_restock.dart';
import 'package:feature_restock/src/application/restock_providers.dart';
import 'package:feature_restock/src/presentation/restock_rules_screen.dart';
import 'package:feature_restock/src/presentation/running_low_card.dart';
import 'package:feature_restock/src/presentation/runs_out_in_chart_card.dart';
import 'package:feature_restock/src/presentation/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/restock_test_harness.dart';

Quantity _grams(int grams) => Quantity(amountInBaseUnits: grams, unit: QuantityUnit.gram);

void main() {
  late RestockTestHarness harness;
  late Product spinach;

  setUp(() async {
    harness = RestockTestHarness();
    await harness.seedCatalogAndStoragePlace();
    await const RestockFeatureModule().initializeModule(harness.initializationContext);
    spinach = await harness.productWithKey('leafSpinach');
    await harness
        .read(saveRestockRuleUseCaseProvider)
        .execute(productIdentifier: spinach.identifier, minimumQuantity: _grams(1500));
  });
  tearDown(() => harness.dispose());

  Future<void> show(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: [
            ...const RestockFeatureModule().localizationDelegates,
            ...const ProductCatalogFeatureModule().localizationDelegates,
            ...const InventoryFeatureModule().localizationDelegates,
          ],
          home: home,
        ),
      ),
    );
    await _settle(tester);
  }

  testWidgets('the Home card shows running-low products', (tester) async {
    await show(tester, const Scaffold(body: SingleChildScrollView(child: RunningLowCard())));

    expect(find.text('Running low'), findsOneWidget);
    expect(find.text('Leaf spinach'), findsOneWidget);
  });

  testWidgets('ticked items go into the freezer in one step', (tester) async {
    await show(tester, const ShoppingListScreen());
    expect(find.text('Running low', skipOffstage: false), findsNothing);
    expect(find.textContaining('· Running low'), findsOneWidget);
    expect(find.text('Tick what you bought'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await _settle(tester);
    await tester.tap(find.text('Put 1 ticked item in the freezer'));
    await _settleUntilFound(tester, find.text('1 item is in the freezer now'));

    expect(find.text('Your shopping list is empty'), findsOneWidget);
    final batches = await tester.runAsync(
      () => harness
          .read(inventoryQueryServiceProvider)
          .readActiveBatchesOfProduct(spinach.identifier),
    );
    expect(batches!.single.quantityRemaining, _grams(1500));
  });

  testWidgets('a minimum is changed in its dialog', (tester) async {
    await show(tester, const RestockRulesScreen());
    expect(find.textContaining('Keep at least 1.5 kg'), findsOneWidget);

    await tester.tap(find.text('Leaf spinach'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).first, '500');
    await tester.enterText(find.byType(TextField).last, '250');
    await tester.tap(find.text('Save'));
    await _settle(tester);
    expect(find.text('This must be at least the minimum.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '2000');
    await tester.tap(find.text('Save'));
    await _settle(tester);

    expect(find.textContaining('Keep at least 500 g, buy up to 2 kg'), findsOneWidget);
  });

  group('runs out in', () {
    final wholePeriod = InsightFilterSnapshot(
      periodStart: DateTime.utc(2026, 7, 4),
      periodEnd: DateTime.utc(2026, 10, 3),
    );

    Future<Product> recordSpinachAndPeas() async {
      final peas = await harness.productWithKey('gardenPeas');
      // Spinach: 1 kg in, 900 g eaten today, so 100 g last about 7 days.
      final spinachBatch = await harness.addBatch(spinach, quantity: _grams(1000));
      await harness
          .read(consumeStockUseCaseProvider)
          .execute(stockBatchIdentifier: spinachBatch, quantity: _grams(900));
      // Peas: well stocked and not eaten lately.
      await harness.addBatch(peas, quantity: _grams(1000));
      await harness
          .read(saveRestockRuleUseCaseProvider)
          .execute(productIdentifier: peas.identifier, minimumQuantity: _grams(500));
      return peas;
    }

    testWidgets('forecasts each product with a minimum and adds it to the list on tap', (
      tester,
    ) async {
      final peas = await tester.runAsync(recordSpinachAndPeas);
      await show(
        tester,
        Scaffold(
          body: SingleChildScrollView(child: RunsOutInChartCard(filter: wholePeriod)),
        ),
      );

      expect(find.text('Runs out in'), findsOneWidget);
      expect(find.bySemanticsLabel('Leaf spinach: ≈ 7 days'), findsOneWidget);
      expect(find.bySemanticsLabel('Garden peas: no recent use'), findsOneWidget);
      expect(
        tester.getTopLeft(find.bySemanticsLabel('Leaf spinach: ≈ 7 days')).dy,
        lessThan(tester.getTopLeft(find.bySemanticsLabel('Garden peas: no recent use')).dy),
      );

      await tester.tap(find.bySemanticsLabel('Garden peas: no recent use'));
      await _settle(tester);
      expect(find.text('Garden peas is on the shopping list'), findsOneWidget);
      final shoppingList = await tester.runAsync(
        () => harness.read(restockRepositoryProvider).readShoppingList(),
      );
      expect(
        shoppingList!.where((entry) => entry.productIdentifier == peas!.identifier),
        hasLength(1),
      );
    });

    testWidgets('follows the product filter of the Insights tab', (tester) async {
      await tester.runAsync(recordSpinachAndPeas);
      await show(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: RunsOutInChartCard(
              filter: InsightFilterSnapshot(
                periodStart: wholePeriod.periodStart,
                periodEnd: wholePeriod.periodEnd,
                productIdentifiers: {spinach.identifier.value},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RankingBarList), findsOneWidget);
      expect(find.textContaining('Leaf spinach'), findsOneWidget);
      expect(find.text('≈ 7 days'), findsOneWidget);
      expect(find.textContaining('Garden peas'), findsNothing);
    });
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var round = 0; round < 3; round++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}

/// Putting items away runs several transactions in real time.
Future<void> _settleUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsOneWidget);
}
