import 'dart:async';

import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_product_catalog/src/application/product_catalog_providers.dart';
import 'package:feature_product_catalog/src/presentation/product_catalog_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/product_catalog_test_harness.dart';

void main() {
  late ProductCatalogTestHarness harness;

  setUp(() => harness = ProductCatalogTestHarness());
  tearDown(() => harness.dispose());

  Future<Product> mincedMeat() async => (await harness.readCatalog()).activeProducts.singleWhere(
    (product) => product.catalogKey == 'mincedMeat',
  );

  Future<void> openEditor(WidgetTester tester, Product product) async {
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) => const Scaffold(body: Text('start')),
        ),
        ...buildProductCatalogRoutes(),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestRouterApplication(
          routerConfig: router,
          featureLocalizationDelegates: const ProductCatalogFeatureModule().localizationDelegates,
        ),
      ),
    );
    unawaited(router.push(ProductCatalogRoutes.productEditor(product.identifier)));
    await _settle(tester);
  }

  testWidgets('a product keeps for a number of days, weeks or months', (tester) async {
    await tester.runAsync(() => harness.read(seedCatalogUseCaseProvider).execute());
    final product = (await tester.runAsync(mincedMeat))!;
    await openEditor(tester, product);

    final shelfLifeField = find.widgetWithText(TextField, 'Keeps for (optional)');
    await tester.ensureVisible(shelfLifeField);
    expect(find.text('Leave empty to follow the category: about 9 months.'), findsOneWidget);

    await tester.enterText(shelfLifeField, '2');
    await tester.tap(find.text('days'));
    await _settle(tester);
    await tester.tap(find.text('Save'));
    await _settle(tester);

    expect(find.text('start'), findsOneWidget);
    expect((await tester.runAsync(mincedMeat))!.recommendedMaximumStorageDays, 2);

    await openEditor(tester, product);
    await tester.ensureVisible(find.widgetWithText(TextField, 'Keeps for (optional)'));
    expect(find.widgetWithText(TextField, '2'), findsOneWidget);
    expect(
      tester
          .widget<SegmentedButton<ShelfLifeUnit>>(find.byType(SegmentedButton<ShelfLifeUnit>))
          .selected,
      {ShelfLifeUnit.days},
    );
  });

  testWidgets('an out-of-range shelf life is not saved', (tester) async {
    await tester.runAsync(() => harness.read(seedCatalogUseCaseProvider).execute());
    final product = (await tester.runAsync(mincedMeat))!;
    await openEditor(tester, product);

    final shelfLifeField = find.widgetWithText(TextField, 'Keeps for (optional)');
    await tester.ensureVisible(shelfLifeField);
    await tester.enterText(shelfLifeField, '40');
    await tester.tap(find.text('Save'));
    await _settle(tester);

    expect(find.text('Enter between 1 day and 36 months.'), findsOneWidget);
    expect((await tester.runAsync(mincedMeat))!.recommendedMaximumStorageDays, isNull);
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var round = 0; round < 3; round++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}
