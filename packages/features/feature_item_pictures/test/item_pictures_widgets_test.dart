import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_media_storage/testing.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_item_pictures/feature_item_pictures.dart';
import 'package:feature_item_pictures/src/application/item_picture_providers.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/item_pictures_test_harness.dart';

void main() {
  late ItemPicturesTestHarness harness;
  late Product spinach;

  setUp(() => harness = ItemPicturesTestHarness());
  tearDown(() => harness.dispose());

  Future<void> prepare(WidgetTester tester) => tester.runAsync(() async {
    await harness.seedCatalogAndFreezer();
    await harness.startPictureModule();
    spinach = await harness.productWithKey('leafSpinach');
  });

  /// The modules' screens behind a router, opened at [location] above a
  /// blank page, so screens can close themselves.
  Future<void> showAt(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1200, 3000);
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
          theme: FreezerTheme.light(),
          supportedLocales: SupportedLocales.all,
          localizationsDelegates: [
            ...GlobalMaterialLocalizations.delegates,
            CommonLocalizations.delegate,
            for (final module in harness.modules) ...module.localizationDelegates,
          ],
        ),
      ),
    );
    unawaited(router.push(location));
    await _settle(tester);
  }

  testWidgets('the add form takes a photo and attaches it to the new batch', (tester) async {
    await prepare(tester);
    await showAt(tester, InventoryRoutes.addStockBatch(productIdentifier: spinach.identifier));

    expect(find.text('Optional. Location data is removed from photos.'), findsOneWidget);
    await tester.tap(find.text('📷 Take or choose a photo'));
    await _settle(tester);
    await tester.tap(find.text('Choose from your photos'));
    await _settle(tester);

    expect(find.text('Photo added · location data removed'), findsOneWidget);
    expect(harness.pictureSource.requestedKinds, [PictureSourceKind.gallery]);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);

    final pictures = (await tester.runAsync(harness.readPictures))!;
    expect(pictures.single.owner, isA<StockBatchPictureOwner>());
    final batches = (await tester.runAsync(
      () => harness.read(inventoryQueryServiceProvider).readActiveBatches(),
    ))!;
    expect(
      (pictures.single.owner as StockBatchPictureOwner).stockBatchIdentifier,
      batches.single.identifier,
    );
  });

  testWidgets('leaving the add form deletes the photo taken in it', (tester) async {
    await prepare(tester);
    await showAt(tester, InventoryRoutes.addStockBatch(productIdentifier: spinach.identifier));
    await tester.tap(find.text('📷 Take or choose a photo'));
    await _settle(tester);
    await tester.tap(find.text('Take a photo'));
    await _settle(tester);
    expect(harness.mediaFileStore.filesByName, hasLength(2));

    await tester.pageBack();
    await _settle(tester);

    expect(harness.mediaFileStore.filesByName, isEmpty);
    expect(await tester.runAsync(harness.readPictures), isEmpty);
  });

  testWidgets('lists show the product photo', (tester) async {
    await prepare(tester);
    await tester.runAsync(() async {
      await harness.addBatch(spinach);
      final stagedPicture =
          (await harness.read(stageItemPictureUseCaseProvider).execute(createTestPhotoBytes()))
              .valueOrNull!;
      await harness
          .read(attachItemPictureUseCaseProvider)
          .execute(owner: ProductPictureOwner(spinach.identifier), stagedPicture: stagedPicture);
    });
    await showAt(tester, InventoryRoutes.overview);

    expect(find.bySemanticsLabel('Photo'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('without the module, the add form has no photo slot', (tester) async {
    harness.isPictureModuleEnabled = false;
    await prepare(tester);
    await showAt(tester, InventoryRoutes.addStockBatch(productIdentifier: spinach.identifier));

    expect(find.text('📷 Take or choose a photo'), findsNothing);
    expect(find.text('Leaf spinach'), findsOneWidget);
  });

  testWidgets('the product editor adds, shows and removes the catalog photo', (tester) async {
    await prepare(tester);
    await showAt(tester, ProductCatalogRoutes.productEditor(spinach.identifier));

    await tester.tap(find.text('📷 Take or choose a photo'));
    await _settle(tester);
    await tester.tap(find.text('Take a photo'));
    await _settle(tester);
    expect(find.text('Replace'), findsOneWidget);
    expect(
      (await tester.runAsync(harness.readPictures))!.single.owner,
      ProductPictureOwner(spinach.identifier),
    );

    await tester.tap(find.text('View'));
    await _settle(tester);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await _settle(tester);

    await tester.tap(find.text('Remove'));
    await _settle(tester);
    expect(find.text('Remove this photo?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await _settle(tester);

    expect(await tester.runAsync(harness.readPictures), isEmpty);
    expect(harness.mediaFileStore.filesByName, isEmpty);
    expect(find.text('📷 Take or choose a photo'), findsOneWidget);
  });

  testWidgets('explains a file that is no picture', (tester) async {
    await prepare(tester);
    harness.pictureSource.nextPicture = createTestPhotoBytes().sublist(0, 20);
    await showAt(tester, InventoryRoutes.addStockBatch(productIdentifier: spinach.identifier));

    await tester.tap(find.text('📷 Take or choose a photo'));
    await _settle(tester);
    await tester.tap(find.text('Choose from your photos'));
    await _settle(tester);

    expect(find.text('This photo cannot be read. Try another one.'), findsOneWidget);
    expect(find.text('📷 Take or choose a photo'), findsOneWidget);
  });
}

/// Pictures are processed in a background isolate and the database works in
/// real time, outside the fake clock; a progress indicator shows meanwhile.
Future<void> _settle(WidgetTester tester) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
    if (attempt >= 3 && find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}
