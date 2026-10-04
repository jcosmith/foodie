import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_barcode_scanning/feature_barcode_scanning.dart';
import 'package:feature_barcode_scanning/src/application/barcode_scanning_providers.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/barcode_scanning_test_harness.dart';

void main() {
  late BarcodeScanningTestHarness harness;
  late Product spinach;

  setUp(() => harness = BarcodeScanningTestHarness());
  tearDown(() => harness.dispose());

  Future<void> prepare(WidgetTester tester) => tester.runAsync(() async {
    await harness.seedCatalogAndStoragePlace();
    spinach = await harness.productWithKey('leafSpinach');
  });

  /// The modules' screens behind a router, with the scanner opened above a
  /// blank page.
  Future<void> showScanner(WidgetTester tester, ScanMode mode) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold()),
        for (final module in harness.modules) ...[
          ...module.buildRoutes(),
          ...?module.navigationDestination?.routes,
        ],
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: FoodieTheme.light(),
          supportedLocales: SupportedLocales.all,
          localizationsDelegates: [
            ...GlobalMaterialLocalizations.delegates,
            CommonLocalizations.delegate,
            for (final module in harness.modules) ...module.localizationDelegates,
          ],
        ),
      ),
    );
    unawaited(router.push(BarcodeScanningRoutes.scanner(mode)));
    await _settle(tester);
  }

  testWidgets('learns an unknown code and then adds the product with one tap', (tester) async {
    await prepare(tester);
    await showScanner(tester, ScanMode.add);
    expect(find.text('Scanned on this phone. Nothing is sent anywhere.'), findsOneWidget);

    harness.decoder.showCode('4001234567891');
    await _settle(tester);
    expect(find.text('New code 4001234567891. Which product is this?'), findsOneWidget);

    await tester.tap(find.text('Choose product'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).last, 'spinach');
    await _settle(tester);
    await tester.tap(find.text('Leaf spinach').last);
    await _settle(tester);

    expect(find.text('Learned. Next time this code is recognised instantly.'), findsOneWidget);
    expect(find.text('Recognised'), findsOneWidget);
    await tester.tap(find.text('Add 1 kg to Drawer 1'));
    await _settle(tester);

    expect(find.text('Added 1 kg of Leaf spinach to Drawer 1'), findsOneWidget);
    final batches = await tester.runAsync(harness.activeBatches);
    expect(batches!.single.productIdentifier, spinach.identifier);
    // Back to scanning: the next code shows up.
    harness.decoder.showCode('4001234567891');
    await _settle(tester);
    expect(find.text('1 kg at home'), findsOneWidget);
  });

  testWidgets('scan to remove suggests the oldest bag and opens the take sheet', (tester) async {
    await prepare(tester);
    await tester.runAsync(() async {
      await harness.addBatch(spinach, amountInBaseUnits: 300, storedOn: CalendarDate(2026, 9, 20));
      await harness.addBatch(spinach, amountInBaseUnits: 700, storedOn: CalendarDate(2026, 6, 1));
      final resolution = await harness
          .read(resolveBarcodeUseCaseProvider)
          .execute(const ScannedBarcode(value: '4001234567891', symbology: BarcodeSymbology.ean13));
      await harness
          .read(learnBarcodeUseCaseProvider)
          .execute(barcode: resolution.barcode, productIdentifier: spinach.identifier);
    });
    await showScanner(tester, ScanMode.remove);

    harness.decoder.showCode('4001234567891');
    await _settle(tester);

    expect(find.text('2 packs at home. Take from the oldest?'), findsOneWidget);
    expect(find.text('Or another bag'), findsOneWidget);
    await tester.tap(find.text('Choose amount'));
    await _settle(tester);
    expect(find.text('How much are you taking?'), findsOneWidget);
  });

  testWidgets('weighed goods open the add form with the weight from the code', (tester) async {
    await prepare(tester);
    final mincedMeat = (await tester.runAsync(() => harness.productWithKey('mincedMeat')))!;
    await tester.runAsync(() async {
      final resolution = await harness
          .read(resolveBarcodeUseCaseProvider)
          .execute(const ScannedBarcode(value: '2412345003505', symbology: BarcodeSymbology.ean13));
      await harness
          .read(learnBarcodeUseCaseProvider)
          .execute(barcode: resolution.barcode, productIdentifier: mincedMeat.identifier);
    });
    await showScanner(tester, ScanMode.add);

    harness.decoder.showCode('2412345004205');
    await _settle(tester);
    expect(find.text('Weight in the code: 420 g'), findsOneWidget);
    expect(find.text('Add 420 g to Drawer 1'), findsOneWidget);

    await tester.tap(find.text('Change details'));
    await _settle(tester);

    expect(find.text('Add'), findsOneWidget);
    expect(find.widgetWithText(TextField, '420'), findsOneWidget);
  });

  Future<void> learnCode(WidgetTester tester, String code, Product product) =>
      tester.runAsync(() async {
        final resolution = await harness
            .read(resolveBarcodeUseCaseProvider)
            .execute(ScannedBarcode(value: code, symbology: BarcodeSymbology.ean13));
        await harness
            .read(learnBarcodeUseCaseProvider)
            .execute(barcode: resolution.barcode, productIdentifier: product.identifier);
      });

  testWidgets('scanning several in a row collects a list and adds it at once', (tester) async {
    await prepare(tester);
    final mincedMeat = (await tester.runAsync(() => harness.productWithKey('mincedMeat')))!;
    await learnCode(tester, '4001234567891', spinach);
    await learnCode(tester, '2412345003505', mincedMeat);
    await showScanner(tester, ScanMode.add);
    await tester.tap(find.text('Several in a row'));
    await _settle(tester);
    expect(find.text('Scan your groceries one after another'), findsOneWidget);

    harness.decoder.showCode('4001234567891');
    await _settle(tester);
    // Still in front of the camera: counted once.
    harness.decoder.showCode('4001234567891');
    await _settle(tester);
    expect(find.text('1 item to put away'), findsOneWidget);
    expect(find.text('1 kg · Drawer 1'), findsOneWidget);

    // Shown again a moment later: the next bag.
    harness.clock.setTo(harness.clock.nowUtc().add(const Duration(seconds: 3)));
    harness.decoder.showCode('4001234567891');
    await _settle(tester);
    harness.decoder.showCode('2412345004205');
    await _settle(tester);
    expect(find.text('3 items to put away'), findsOneWidget);
    expect(find.text('420 g · Drawer 1'), findsOneWidget);

    // An unknown code asks once, then joins the list.
    harness.decoder.showCode('4006040012342');
    await _settle(tester);
    await tester.tap(find.text('Choose product'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).last, 'minced');
    await _settle(tester);
    await tester.tap(find.text('Minced meat').last);
    await _settle(tester);
    expect(find.text('4 items to put away'), findsOneWidget);

    await tester.tap(find.text('420 g · Drawer 1'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).last, '450');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);
    expect(find.text('450 g · Drawer 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove from the list').first);
    await _settle(tester);

    await tester.tap(find.text('Put 3 items away'));
    await _settle(tester);

    expect(find.text('3 items put away'), findsOneWidget);
    expect(find.text('Scan your groceries one after another'), findsOneWidget);
    final batches = (await tester.runAsync(harness.activeBatches))!;
    expect(
      batches.map((batch) => batch.quantityRemaining.amountInBaseUnits),
      unorderedEquals([1000, 450, 500]),
    );
  });

  testWidgets('leaving with scanned items asks before discarding them', (tester) async {
    await prepare(tester);
    await learnCode(tester, '4001234567891', spinach);
    await showScanner(tester, ScanMode.add);
    await tester.tap(find.text('Several in a row'));
    await _settle(tester);
    harness.decoder.showCode('4001234567891');
    await _settle(tester);

    await tester.pageBack();
    await _settle(tester);
    expect(find.text('Discard the scanned items?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await _settle(tester);

    expect(find.text('Scan'), findsNothing);
    expect(await tester.runAsync(harness.activeBatches), isEmpty);
  });

  testWidgets('switching to Add shows the same product with its add button', (tester) async {
    await prepare(tester);
    await showScanner(tester, ScanMode.remove);

    harness.decoder.showCode('4001234567891');
    await _settle(tester);
    await tester.tap(find.text('Choose product'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).last, 'spinach');
    await _settle(tester);
    await tester.tap(find.text('Leaf spinach').last);
    await _settle(tester);
    expect(find.text('None of this product is at home.'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await _settle(tester);

    expect(find.text('Add 1 kg to Drawer 1'), findsOneWidget);
  });
}

/// The database works in real time, outside the fake clock.
Future<void> _settle(WidgetTester tester) async {
  for (var attempt = 0; attempt < 60; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
    if (attempt >= 3 && find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}
