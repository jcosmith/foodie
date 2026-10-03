import 'package:core_design_system/testing.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_product_catalog/src/application/product_catalog_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/product_catalog_test_harness.dart';

void main() {
  late ProductCatalogTestHarness harness;

  setUp(() => harness = ProductCatalogTestHarness());
  tearDown(() => harness.dispose());

  testWidgets('finds a product by its translated name and returns it', (tester) async {
    await tester.runAsync(() => harness.read(seedCatalogUseCaseProvider).execute());
    ProductIdentifier? pickedProduct;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestApplication(
          locale: const Locale('de'),
          featureLocalizationDelegates: const ProductCatalogFeatureModule().localizationDelegates,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => pickedProduct = await showProductPickerSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _settle(tester);

    expect(find.text('Produkt wählen'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'spin');
    await _settle(tester);
    expect(find.text('Blattspinat'), findsOneWidget);
    expect(find.text('Erbsen'), findsNothing);
    expect(find.text('„spin“ anlegen'), findsOneWidget);

    await tester.tap(find.text('Blattspinat'));
    await _settle(tester);

    final catalog = (await tester.runAsync(harness.readCatalog))!;
    expect(catalog.productOf(pickedProduct!)!.catalogKey, 'leafSpinach');
  });
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}
