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

  setUp(() => harness = InventoryTestHarness());
  tearDown(() => harness.dispose());

  Future<void> showOverviewWithMincedMeat(WidgetTester tester, {String? note}) async {
    await tester.runAsync(() async {
      final drawers = await harness.setUpCatalogAndStoragePlace();
      await harness.addBatch(
        product: await harness.seededProduct('mincedMeat'),
        compartment: drawers.first,
        amountInBaseUnits: 500,
        note: note,
      );
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
          home: const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.freezer),
        ),
      ),
    );
    await _settle(tester);
  }

  testWidgets('a domain tab shows only the places and items of its domain', (tester) async {
    final twoDomains = InventoryTestHarness(
      registeredModules: const [FreezerFeatureModule(), ShelvesModule()],
    );
    addTearDown(twoDomains.dispose);
    await tester.runAsync(() async {
      final drawers = await twoDomains.setUpCatalogAndStoragePlace();
      final shelves = await twoDomains.addStoragePlace(ShelvesModule.cupboard);
      await twoDomains.addBatch(
        product: await twoDomains.seededProduct('mincedMeat'),
        compartment: drawers.first,
        amountInBaseUnits: 500,
      );
      await twoDomains.addBatch(
        product: await twoDomains.seededProduct('gardenPeas'),
        compartment: shelves.last,
        amountInBaseUnits: 750,
      );
    });
    Future<void> showDomain(StorageDomainIdentifier domainIdentifier) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: twoDomains.container,
          child: buildLocalizedTestApplication(
            featureLocalizationDelegates: [
              ...const InventoryFeatureModule().localizationDelegates,
              ...const ProductCatalogFeatureModule().localizationDelegates,
              ...const StorageLayoutFeatureModule().localizationDelegates,
            ],
            home: InventoryOverviewScreen(
              key: ValueKey(domainIdentifier),
              domainIdentifier: domainIdentifier,
            ),
          ),
        ),
      );
      await _settle(tester);
    }

    await showDomain(StorageDomainIdentifier.freezer);
    expect(find.text('Freezer'), findsOneWidget, reason: 'the title names the domain');
    expect(find.text('Minced meat'), findsOneWidget);
    expect(find.text('Garden peas'), findsNothing);
    expect(find.text('1 item in 3 drawers'), findsOneWidget);

    await showDomain(StorageDomainIdentifier.pantry);
    expect(find.text('Shelves'), findsOneWidget);
    expect(find.text('1 item in 2 shelves'), findsOneWidget);
    expect(find.text('Garden peas'), findsOneWidget);
    expect(find.text('Minced meat'), findsNothing);
    expect(find.text('Shelf 2'), findsOneWidget);
  });

  testWidgets('lists the batch under its drawer', (tester) async {
    await showOverviewWithMincedMeat(tester);

    expect(find.text('1 item in 3 drawers'), findsOneWidget);
    expect(find.text('Drawer 1'), findsOneWidget);
    expect(find.text('Minced meat'), findsOneWidget);
    expect(find.text('500 g'), findsOneWidget);
  });

  testWidgets('takes half of a bag and offers undo', (tester) async {
    await showOverviewWithMincedMeat(tester);

    await tester.tap(find.text('Minced meat'));
    await _settle(tester);
    expect(find.text('How much are you taking?'), findsOneWidget);

    await tester.tap(find.text('½'));
    await tester.pump();
    await tester.tap(find.text('Take 250 g'));
    await _settle(tester);

    expect(find.text('Took 250 g of Minced meat'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('250 g'), findsOneWidget);
  });

  testWidgets('marks a batch past its storage time as overdue', (tester) async {
    await tester.runAsync(() async {
      final drawers = await harness.setUpCatalogAndStoragePlace();
      await harness.addBatch(
        product: await harness.seededProduct('mincedMeat'),
        compartment: drawers.first,
        amountInBaseUnits: 500,
        // Meat keeps for about 9 months (270 days).
        storedOn: InventoryTestHarness.today.addDays(-300),
      );
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
          home: const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.freezer),
        ),
      ),
    );
    await _settle(tester);

    expect(find.text('✕ Overdue'), findsOneWidget);
    expect(find.textContaining('Use now'), findsNothing);
  });

  testWidgets('badges say by when to use food that is due soon', (tester) async {
    final today = InventoryTestHarness.today;
    await tester.runAsync(() async {
      final drawers = await harness.setUpCatalogAndStoragePlace();
      for (final (catalogKey, bestBeforeOn) in [
        ('leafSpinach', today),
        ('mincedMeat', today.addDays(1)),
        ('wholegrainBread', today.addDays(3)),
        ('gardenPeas', today.addDays(-1)),
      ]) {
        await harness.addBatch(
          product: await harness.seededProduct(catalogKey),
          compartment: drawers.first,
          amountInBaseUnits: 500,
          storedOn: today.addDays(-10),
          bestBeforeOn: bestBeforeOn,
        );
      }
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
          home: const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.freezer),
        ),
      ),
    );
    await _settle(tester);

    expect(find.text('▲ Use today'), findsOneWidget);
    expect(find.text('◐ Use by tomorrow'), findsOneWidget);
    // 2 October 2026 is a Friday.
    expect(find.text('◐ Use by Mon'), findsOneWidget);
    expect(find.text('✕ Past best before'), findsOneWidget);
  });

  testWidgets('"Use first" lists the least freshness time left first', (tester) async {
    await tester.runAsync(() async {
      final drawers = await harness.setUpCatalogAndStoragePlace();
      for (final (catalogKey, storedDays) in [
        ('leafSpinach', 200), // 365 days: 165 left
        ('mincedMeat', 30), // 270 days: 240 left
        ('wholegrainBread', 10), // 90 days: 80 left
      ]) {
        await harness.addBatch(
          product: await harness.seededProduct(catalogKey),
          compartment: drawers.first,
          amountInBaseUnits: 1,
          storedOn: InventoryTestHarness.today.addDays(-storedDays),
        );
      }
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
          home: const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.freezer),
        ),
      ),
    );
    await _settle(tester);
    expect(find.text('Oldest first'), findsNothing);

    await tester.tap(find.text('Use first'));
    await tester.pumpAndSettle();

    double topOf(String productName) => tester.getTopLeft(find.text(productName)).dy;
    expect(topOf('Wholegrain bread'), lessThan(topOf('Leaf spinach')));
    expect(topOf('Leaf spinach'), lessThan(topOf('Minced meat')));
  });

  group('drawer groups', () {
    Future<void> showTwoDrawers(WidgetTester tester) async {
      await tester.runAsync(() async {
        final drawers = await harness.setUpCatalogAndStoragePlace();
        for (final (catalogKey, drawerIndex, storedDays) in [
          ('leafSpinach', 0, 200), // 365 days: 165 left
          ('wholegrainBread', 0, 10), // 90 days: 80 left
          ('mincedMeat', 1, 30),
        ]) {
          await harness.addBatch(
            product: await harness.seededProduct(catalogKey),
            compartment: drawers[drawerIndex],
            amountInBaseUnits: 1,
            storedOn: InventoryTestHarness.today.addDays(-storedDays),
          );
        }
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
            home: const InventoryOverviewScreen(domainIdentifier: StorageDomainIdentifier.freezer),
          ),
        ),
      );
      await _settle(tester);
    }

    testWidgets('list the least freshness time left first', (tester) async {
      await showTwoDrawers(tester);

      expect(
        tester.getTopLeft(find.text('Wholegrain bread')).dy,
        lessThan(tester.getTopLeft(find.text('Leaf spinach')).dy),
      );
    });

    testWidgets('collapse with a tap and all expand again', (tester) async {
      await showTwoDrawers(tester);
      expect(find.text('Collapse all'), findsOneWidget);

      await tester.tap(find.text('Drawer 1'));
      await tester.pumpAndSettle();
      expect(find.text('Leaf spinach'), findsNothing);
      expect(find.text('Wholegrain bread'), findsNothing);
      expect(find.text('2 items'), findsOneWidget);
      expect(find.text('Minced meat'), findsOneWidget);

      await tester.tap(find.text('Drawer 2'));
      await tester.pumpAndSettle();
      expect(find.text('Minced meat'), findsNothing);

      await tester.tap(find.text('Expand all'));
      await tester.pumpAndSettle();
      expect(find.text('Leaf spinach'), findsOneWidget);
      expect(find.text('Minced meat'), findsOneWidget);

      await tester.tap(find.text('Collapse all'));
      await tester.pumpAndSettle();
      expect(find.text('Leaf spinach'), findsNothing);
      expect(find.text('Minced meat'), findsNothing);
      expect(find.text('Expand all'), findsOneWidget);
    });

    testWidgets('the two orders stay side by side on a narrow phone', (tester) async {
      // The test font is wider than a phone's, so 400 here is narrow.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await showTwoDrawers(tester);

      expect(
        tester.getCenter(find.text('Use first')).dy,
        tester.getCenter(find.text('By place')).dy,
      );
      expect(find.text('Collapse all'), findsOneWidget);
    });

    testWidgets('open while searching, so no match hides', (tester) async {
      await showTwoDrawers(tester);
      await tester.tap(find.text('Drawer 2'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(SearchBar), 'minced');
      await tester.pumpAndSettle();

      expect(find.text('Minced meat'), findsOneWidget);
    });
  });

  testWidgets('shows the note in brackets and finds the batch by it', (tester) async {
    await showOverviewWithMincedMeat(tester, note: 'for Sunday');
    expect(find.text('Minced meat (for Sunday)', findRichText: true), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'sunday');
    await tester.pump();
    expect(find.text('Minced meat (for Sunday)', findRichText: true), findsOneWidget);
  });

  testWidgets('says when the search finds nothing', (tester) async {
    await showOverviewWithMincedMeat(tester);

    await tester.enterText(find.byType(SearchBar), 'pizza');
    await tester.pump();

    expect(find.text('Nothing matches “pizza”.'), findsOneWidget);
    expect(find.text('Minced meat'), findsNothing);
  });
}

/// Lets the database work outside the fake clock, then settles the frames.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}
