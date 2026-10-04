import 'package:core_design_system/testing.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_statistics/feature_statistics.dart';
import 'package:feature_statistics/src/presentation/statistics_filter_sheet.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/statistics_test_harness.dart';

Future<void> _pumpFilterSheet(
  WidgetTester tester,
  StatisticsTestHarness harness, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1200, 9000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: harness.container,
      child: buildLocalizedTestApplication(
        locale: locale,
        featureLocalizationDelegates: const [
          StatisticsLocalizations.delegate,
          ProductCatalogLocalizations.delegate,
          StorageLayoutLocalizations.delegate,
        ],
        home: const Scaffold(body: StatisticsFilterSheet()),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var round = 0; round < 5; round++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}

/// The product chips in the order the sheet lists them.
List<ProductIdentifier> _listedProducts(WidgetTester tester) => [
  for (final chip in tester.widgetList<FilterChip>(find.byType(FilterChip)))
    if (chip.key case ValueKey<ProductIdentifier>(:final value)) value,
];

Finder _productChip(Product product) => find.byKey(ValueKey(product.identifier));

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await _settle(tester);
}

void main() {
  late StatisticsTestHarness harness;
  late Product peas;
  late Product chicken;
  late Product pizza;
  late Product mango;
  late Product broccoli;

  setUp(() => harness = StatisticsTestHarness());
  tearDown(() => harness.dispose());

  /// The whole seeded catalog, of which only peas (3 movements), chicken (2)
  /// and pizza (1) have history in the last three months; mango was only
  /// added before that.
  Future<void> recordHistory() async {
    await harness.seedCatalogAndStoragePlace();
    peas = await harness.productWithKey('gardenPeas');
    chicken = await harness.productWithKey('chickenBreast');
    pizza = await harness.productWithKey('pizzaMargherita');
    mango = await harness.productWithKey('mango');
    broccoli = await harness.productWithKey('broccoli');
    final peasBatch = await harness.addBatch(peas, 1000, daysAgo: 40);
    final chickenBatch = await harness.addBatch(chicken, 800, daysAgo: 30);
    await harness.addBatch(pizza, 2, daysAgo: 30);
    await harness.addBatch(mango, 500, daysAgo: 200);
    await harness.consume(peasBatch, peas, 300, daysAgo: 20);
    await harness.consume(peasBatch, peas, 200, daysAgo: 5);
    await harness.discard(chickenBatch, chicken, 400, daysAgo: 10);
  }

  testWidgets('lists products with history in the period, most used first', (tester) async {
    await tester.runAsync(recordHistory);
    await _pumpFilterSheet(tester, harness);

    expect(_listedProducts(tester), [peas.identifier, chicken.identifier, pizza.identifier]);
    expect(find.text('Show all'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All time'));
    await _settle(tester);
    // Mango and pizza have one movement each and follow by name.
    expect(_listedProducts(tester), [
      peas.identifier,
      chicken.identifier,
      mango.identifier,
      pizza.identifier,
    ]);
  });

  testWidgets('search finds every product, also those without history', (tester) async {
    await tester.runAsync(recordHistory);
    await _pumpFilterSheet(tester, harness);
    expect(_productChip(broccoli), findsNothing);

    await _search(tester, 'broc');
    expect(_listedProducts(tester), [broccoli.identifier]);

    await _search(tester, 'MANGO');
    expect(_listedProducts(tester), [mango.identifier]);

    await _search(tester, '');
    expect(_listedProducts(tester), [peas.identifier, chicken.identifier, pizza.identifier]);
  });

  testWidgets('selected products come first and can be deselected', (tester) async {
    await tester.runAsync(recordHistory);
    await _pumpFilterSheet(tester, harness);

    await tester.tap(_productChip(pizza));
    await _settle(tester);
    expect(harness.read(statisticsFilterProvider).productIdentifiers, {pizza.identifier});
    // Selecting a product does not hide the others.
    expect(_listedProducts(tester), [pizza.identifier, peas.identifier, chicken.identifier]);

    await _search(tester, 'broc');
    await tester.tap(_productChip(broccoli));
    await _settle(tester);
    // While searching, the selection stays visible above the matches.
    expect(_listedProducts(tester), [broccoli.identifier, pizza.identifier]);

    await _search(tester, '');
    expect(_listedProducts(tester), [
      broccoli.identifier,
      pizza.identifier,
      peas.identifier,
      chicken.identifier,
    ]);
    expect(tester.widget<FilterChip>(_productChip(broccoli)).selected, isTrue);
    expect(tester.widget<FilterChip>(_productChip(peas)).selected, isFalse);

    await tester.tap(_productChip(broccoli));
    await _settle(tester);
    expect(harness.read(statisticsFilterProvider).productIdentifiers, {pizza.identifier});
    expect(_listedProducts(tester), [pizza.identifier, peas.identifier, chicken.identifier]);

    // An archived product stays listed, and removable, while selected.
    await tester.runAsync(() async {
      // As the catalog's archive use case stores it.
      final productCatalogDao = harness.database.productCatalogDao;
      final row = await productCatalogDao.readProduct(pizza.identifier.value);
      await productCatalogDao.replaceProduct(row!.copyWith(isArchived: true));
    });
    await _settle(tester);
    expect(_listedProducts(tester), [pizza.identifier, peas.identifier, chicken.identifier]);
    await tester.tap(_productChip(pizza));
    await _settle(tester);
    expect(_listedProducts(tester), [peas.identifier, chicken.identifier]);
  });

  /// Twelve products with history; the first was also eaten from.
  Future<List<Product>> recordTwelveProducts() async {
    await harness.seedCatalogAndStoragePlace();
    final catalog = await harness.read(productCatalogQueryServiceProvider).readCatalog();
    final products = catalog.activeProducts.take(12).toList();
    for (final product in products) {
      final batch = await harness.addBatch(product, 2, daysAgo: 20);
      if (product == products.first) await harness.consume(batch, product, 1, daysAgo: 10);
    }
    return products;
  }

  testWidgets('a long list shows the top ten until "Show all" is tapped', (tester) async {
    final products = (await tester.runAsync(recordTwelveProducts))!;
    await _pumpFilterSheet(tester, harness);

    expect(_listedProducts(tester), hasLength(10));
    expect(_listedProducts(tester).first, products.first.identifier);

    await tester.tap(find.widgetWithText(TextButton, 'Show all'));
    await _settle(tester);
    expect(_listedProducts(tester).toSet(), {for (final product in products) product.identifier});
    expect(find.text('Show all'), findsNothing);
  });

  testWidgets('"Show all" is translated', (tester) async {
    await tester.runAsync(recordTwelveProducts);
    await _pumpFilterSheet(tester, harness, locale: const Locale('de'));

    expect(_listedProducts(tester), hasLength(10));
    expect(find.widgetWithText(TextButton, 'Alle anzeigen'), findsOneWidget);
  });
}
