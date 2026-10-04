import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:core_design_system/testing.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_product_catalog/src/application/product_catalog_providers.dart';
import 'package:feature_product_catalog/src/application/product_icon_image_file_picker.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/product_catalog_test_harness.dart';

/// A red PNG of 1 × 1 pixels, as a user might pick from Downloads.
final Uint8List _tinyRedPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
);

/// Hands back [pickedBytes] as if the user picked that file.
final class _FakeFilePicker implements ProductIconImageFilePicker {
  Uint8List? pickedBytes;

  @override
  Future<Uint8List?> pickImageFile() async => pickedBytes;
}

void main() {
  late _FakeFilePicker filePicker;
  late ProductCatalogTestHarness harness;

  setUp(() {
    filePicker = _FakeFilePicker();
    harness = ProductCatalogTestHarness(iconImageFilePicker: filePicker);
  });
  tearDown(() => harness.dispose());

  group('choosing an icon picture', () {
    test('turns the picked file into a square PNG of the icon size', () async {
      filePicker.pickedBytes = _tinyRedPng;

      final result = await harness.read(chooseProductIconImageUseCaseProvider).execute();

      final iconImage = result.valueOrNull!;
      expect(
        ImageProcessingService.processIconSynchronously(iconImage.pngBytes),
        isNotNull,
        reason: 'the icon is a readable picture',
      );
      expect(iconImage.pngBytes.sublist(1, 4), 'PNG'.codeUnits);
      // Width and height in the PNG header.
      final header = ByteData.sublistView(iconImage.pngBytes, 16, 24);
      expect((header.getUint32(0), header.getUint32(4)), (192, 192));
    });

    test('changes nothing when the dialog is cancelled', () async {
      final result = await harness.read(chooseProductIconImageUseCaseProvider).execute();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('refuses a file that is no picture', () async {
      filePicker.pickedBytes = Uint8List.fromList(utf8.encode('my shopping list'));

      final result = await harness.read(chooseProductIconImageUseCaseProvider).execute();

      expect(result.failureOrNull, isA<UnreadableIconImage>());
    });
  });

  testWidgets('the product editor saves a chosen picture as the icon', (tester) async {
    await tester.runAsync(() => harness.read(seedCatalogUseCaseProvider).execute());
    final spinach = (await tester.runAsync(
      harness.readCatalog,
    ))!.activeProducts.singleWhere((product) => product.catalogKey == 'leafSpinach');
    filePicker.pickedBytes = _tinyRedPng;
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) => const Scaffold(body: Text('start')),
        ),
        ...const ProductCatalogFeatureModule().buildRoutes(),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: buildLocalizedTestRouterApplication(
          featureLocalizationDelegates: [
            ...const ProductCatalogFeatureModule().localizationDelegates,
            ...const StorageLayoutFeatureModule().localizationDelegates,
          ],
          routerConfig: router,
        ),
      ),
    );
    unawaited(router.push(ProductCatalogRoutes.productEditor(spinach.identifier)));
    await _settle(tester);

    expect(find.byType(Image), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Choose a picture'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Choose a picture'));
    await _settleUntil(tester, find.byType(Image));
    expect(find.text('Remove picture'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settleUntil(tester, find.text('start'));

    final savedSpinach = (await tester.runAsync(
      harness.readCatalog,
    ))!.productOf(spinach.identifier)!;
    expect(savedSpinach.iconImage, isNotNull);
    expect(savedSpinach.iconImage!.pngBytes.sublist(1, 4), 'PNG'.codeUnits);
  });
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}

/// Picture processing runs in a background isolate, which needs real time.
Future<void> _settleUntil(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 60 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}
