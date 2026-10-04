import 'dart:async';
import 'dart:typed_data';

import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:feature_receipt_scanning/feature_receipt_scanning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/receipt_scanning_test_harness.dart';

const _shopping = [
  ['Fresh Market'],
  ['Garden peas', '1.99'],
  ['MINCED BEEF 500G', '4.49'],
  ['Chicken breast 2 x 3.50', '7.00'],
  ['Magazine', '3.20'],
  ['Deposit', '0.25'],
  ['TOTAL', '16.93'],
  ['03.10.2026'],
];

void main() {
  late ReceiptScanningTestHarness harness;

  setUp(() => harness = ReceiptScanningTestHarness());
  tearDown(() => harness.dispose());

  Future<void> prepare(WidgetTester tester) =>
      tester.runAsync(harness.seedCatalogAndStoragePlace);

  /// The modules' screens behind a router; [home] is the page below.
  Future<GoRouter> showApp(WidgetTester tester, {WidgetBuilder? home, String? push}) async {
    tester.view.physicalSize = const Size(1200, 4200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => home?.call(context) ?? const Scaffold(),
        ),
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
    if (push != null) unawaited(router.push(push));
    await _settle(tester);
    return router;
  }

  /// The flagged card that shows [lineText].
  Finder cardOf(String lineText) =>
      find.ancestor(of: find.text(lineText), matching: find.byType(Card)).first;

  Future<void> scanShopping(WidgetTester tester) async {
    harness.camera.queuedPages.add(receiptPage(_shopping));
    await showApp(tester, push: ReceiptScanningRoutes.scan);
    expect(find.text('Read on this phone. Nothing is sent anywhere.'), findsOneWidget);
    await tester.tap(find.text('Take photo'));
    await _settle(tester);
    expect(find.text('1 page'), findsOneWidget);
    await tester.tap(find.text('Read receipt'));
    await _settle(tester);
  }

  group('scanning a receipt', () {
    testWidgets('flags what it does not know and adds the rest in one step', (tester) async {
      await prepare(tester);
      await scanShopping(tester);

      expect(find.textContaining('Fresh Market'), findsWidgets);
      expect(find.text('Needs you · 2'), findsOneWidget);
      expect(find.text("We don't know this line yet."), findsNWidgets(2));
      expect(find.text('Recognised · 2'), findsOneWidget);

      await tester.tap(
        find.descendant(of: cardOf('Magazine'), matching: find.text('Ignore at this store')),
      );
      await _settle(tester);
      expect(find.text('Needs you · 1'), findsOneWidget);

      await tester.tap(find.text('Add 2 items'));
      await _settle(tester);

      expect(find.text('Added 2 items'), findsOneWidget);
      final batches = await tester.runAsync(harness.activeBatches);
      expect(batches, hasLength(2));
      final receipts = await tester.runAsync(
        () => harness.read(receiptQueryServiceProvider).watchReceipts().first,
      );
      expect(receipts!.single.openLineCount, 1, reason: 'the minced beef was left open');
      expect(harness.receiptImages.filesByName, hasLength(1), reason: 'the page is kept');
      expect(harness.camera.discardedPaths, ['camera/1.jpg']);
      expect(find.text('1 line still open'), findsOneWidget, reason: 'the archived receipt');
    });

    testWidgets('a likely match needs one tap', (tester) async {
      await prepare(tester);
      harness.camera.queuedPages.add(
        receiptPage([
          ['Fresh Market'],
          ['GARDEN PEA', '1.99'],
        ]),
      );
      await showApp(tester, push: ReceiptScanningRoutes.scan);
      await tester.tap(find.text('Take photo'));
      await _settle(tester);
      await tester.tap(find.text('Read receipt'));
      await _settle(tester);

      expect(find.text('Garden peas?'), findsOneWidget);
      expect(find.text('Add 0 items'), findsNothing);
      await tester.tap(find.descendant(of: cardOf('GARDEN PEA'), matching: find.text('Yes')));
      await _settle(tester);

      expect(find.text('Needs you · 0'), findsNothing);
      await tester.tap(find.text('Add 1 item'));
      await _settle(tester);
      expect(await tester.runAsync(harness.activeBatches), hasLength(1));
    });

    testWidgets('an unknown line can be given a product', (tester) async {
      await prepare(tester);
      harness.camera.queuedPages.add(
        receiptPage([
          ['Fresh Market'],
          ['MINCED BEEF 500G', '4.49'],
        ]),
      );
      await showApp(tester, push: ReceiptScanningRoutes.scan);
      await tester.tap(find.text('Take photo'));
      await _settle(tester);
      await tester.tap(find.text('Read receipt'));
      await _settle(tester);

      await tester.tap(find.text('Pick product'));
      await _settle(tester);
      await tester.enterText(find.byType(TextField).last, 'minced');
      await _settle(tester);
      await tester.tap(find.text('Minced meat').last);
      await _settle(tester);

      expect(find.text('Recognised · 1'), findsOneWidget);
      expect(find.textContaining('Minced meat'), findsWidgets);
      await tester.tap(find.text('Add 1 item'));
      await _settle(tester);
      final batch = (await tester.runAsync(harness.activeBatches))!.single;
      expect(batch.initialQuantity.amountInBaseUnits, 500);
    });

    testWidgets('a photo without text says so and keeps nothing', (tester) async {
      await prepare(tester);
      await showApp(tester, push: ReceiptScanningRoutes.scan);

      await tester.tap(find.text('Take photo'));
      await _settle(tester);

      expect(find.text('No text found on this photo. Try again with more light.'), findsOneWidget);
      expect(find.text('Read receipt'), findsNothing);
      expect(harness.receiptImages.filesByName, isEmpty);
    });

    testWidgets('leaving a scan deletes its photos', (tester) async {
      await prepare(tester);
      harness.camera.queuedPages.add(receiptPage(_shopping));
      await showApp(tester, push: ReceiptScanningRoutes.scan);
      await tester.tap(find.text('Take photo'));
      await _settle(tester);
      expect(harness.receiptImages.filesByName, hasLength(1));

      await tester.pageBack();
      await _settle(tester);

      expect(harness.receiptImages.filesByName, isEmpty);
    });
  });

  group('the receipts segment', () {
    Future<ReceiptIdentifier> archiveWithOpenLines(WidgetTester tester) async =>
        (await tester.runAsync(() async {
          final review = await harness.review(_shopping);
          return (await harness
                  .read(confirmReceiptUseCaseProvider)
                  .execute(review, decisions: const {}))
              .valueOrNull!;
        }))!;

    Widget segment(BuildContext context) =>
        Scaffold(body: harness.receiptModule.listsSegments.single.builder(context));

    testWidgets('lists receipts, searches their lines and opens one', (tester) async {
      await prepare(tester);
      await archiveWithOpenLines(tester);
      await showApp(tester, home: segment);

      expect(find.textContaining('Fresh Market'), findsOneWidget);
      expect(find.text('3 open'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'peas');
      await _settle(tester);
      expect(find.text('Garden peas · 1.99'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'olive');
      await _settle(tester);
      expect(find.text('No receipt mentions this.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'peas');
      await _settle(tester);
      await tester.tap(find.text('Garden peas · 1.99'));
      await _settle(tester);

      expect(find.text('3 lines still open'), findsOneWidget);
      expect(find.text('Magazine'), findsOneWidget);
    });

    testWidgets('open lines can be resolved later', (tester) async {
      await prepare(tester);
      final receiptIdentifier = await archiveWithOpenLines(tester);
      await showApp(tester, push: ReceiptScanningRoutes.receipt(receiptIdentifier));

      await tester.tap(
        find.descendant(of: cardOf('Magazine'), matching: find.text('Ignore')),
      );
      await _settle(tester);
      expect(find.text('2 lines still open'), findsOneWidget);

      await tester.tap(find.descendant(of: cardOf('Garden peas'), matching: find.text('Add')));
      await _settle(tester);
      expect(find.text('1 line still open'), findsOneWidget);
      expect(await tester.runAsync(harness.activeBatches), hasLength(1));
    });

    testWidgets('deleting a receipt removes it and its page images', (tester) async {
      await prepare(tester);
      harness.camera.queuedPages.add(receiptPage(_shopping));
      await showApp(tester, home: segment, push: ReceiptScanningRoutes.scan);
      await tester.tap(find.text('Take photo'));
      await _settle(tester);
      await tester.tap(find.text('Read receipt'));
      await _settle(tester);
      await tester.tap(find.text('Add 2 items'));
      await _settle(tester);
      expect(harness.receiptImages.filesByName, hasLength(1));

      await tester.tap(find.byTooltip('Delete receipt'));
      await _settle(tester);
      await tester.tap(find.text('Delete'));
      await _settle(tester);

      expect(harness.receiptImages.filesByName, isEmpty);
      expect(find.text('No receipts yet. Scan one from the add button.'), findsOneWidget);
      expect(await tester.runAsync(harness.activeBatches), hasLength(2), reason: 'items stay');
    });
  });

  group('the module', () {
    test('is off until switched on, and offers its segment and quick action', () {
      final module = harness.receiptModule;

      expect(module.availability.isOptional, isTrue);
      expect(module.availability.isEnabledByDefault, isFalse);
      expect(module.optionalFeatureDescription, isNotNull);
      expect(module.listsSegments.single.sortOrder, 20);
      expect(module.quickActions.single.identifier, 'receipts.scan');
      expect(
        module.buildRoutes().whereType<GoRoute>().map((route) => route.path),
        everyElement(startsWith('/receipts')),
      );
    });

    test('sweeps page images no receipt refers to at start', () async {
      await harness.seedCatalogAndStoragePlace();
      final stray = await harness.receiptImages.storePicture(_tinyPicture());

      await harness.receiptModule.initializeModule(harness.initializationContext);

      expect(harness.receiptImages.filesByName.keys, isNot(contains(stray.fileName)));
    });
  });
}

ProcessedPicture _tinyPicture() => ProcessedPicture(
  pictureBytes: Uint8List.fromList([1]),
  thumbnailBytes: Uint8List.fromList([2]),
  widthPixels: 1,
  heightPixels: 1,
);

/// The database works in real time, outside the fake clock.
Future<void> _settle(WidgetTester tester) async {
  for (var attempt = 0; attempt < 60; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
    if (attempt >= 3 && find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}
