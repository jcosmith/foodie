import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_barcode_scanning/feature_barcode_scanning.dart';
import 'package:feature_barcode_scanning/src/application/barcode_scanning_providers.dart';
import 'package:feature_barcode_scanning/src/application/barcode_use_cases.dart';
import 'package:feature_barcode_scanning/src/domain/barcode_scanning_failure.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/barcode_scanning_test_harness.dart';

void main() {
  late BarcodeScanningTestHarness harness;
  late Product spinach;
  late Product mincedMeat;

  setUp(() async {
    harness = BarcodeScanningTestHarness();
    await harness.seedCatalogAndStoragePlace();
    spinach = await harness.productWithKey('leafSpinach');
    mincedMeat = await harness.productWithKey('mincedMeat');
  });
  tearDown(() => harness.dispose());

  Future<BarcodeResolution> scan(String value) => harness
      .read(resolveBarcodeUseCaseProvider)
      .execute(ScannedBarcode(value: value, symbology: BarcodeSymbology.ean13));

  Future<RecognizedBarcode> learn(String value, Product product) async {
    final resolution = await scan(value);
    final result = await harness
        .read(learnBarcodeUseCaseProvider)
        .execute(barcode: resolution.barcode, productIdentifier: product.identifier);
    return result.valueOrNull!;
  }

  test('an unknown code is learned once and recognised from then on', () async {
    expect(await scan('4001234567891'), isA<UnrecognizedBarcode>());

    await learn('4001234567891', spinach);

    final resolution = await scan('4001234567891');
    expect(resolution, isA<RecognizedBarcode>());
    expect((resolution as RecognizedBarcode).product.identifier, spinach.identifier);
  });

  test('learning a code again moves it to the right product', () async {
    await learn('4001234567891', spinach);
    await learn('4001234567891', mincedMeat);

    final resolution = await scan('4001234567891') as RecognizedBarcode;
    expect(resolution.product.identifier, mincedMeat.identifier);
  });

  test('codes follow a product replaced by one in another unit', () async {
    await learn('4001234567891', spinach);
    harness.read(barcodesFollowReplacedProductsProvider);

    // Stands in for the catalog's unit change, which publishes this.
    await harness
        .read(domainEventBusProvider)
        .publish(
          ProductUnitChanged(
            previousProductIdentifier: spinach.identifier,
            productIdentifier: mincedMeat.identifier,
            occurredAt: DateTime.utc(2026, 10, 4),
          ),
        );

    final resolution = await scan('4001234567891') as RecognizedBarcode;
    expect(resolution.product.identifier, mincedMeat.identifier);
  });

  test('a code of an archived product counts as unknown', () async {
    await learn('4001234567891', spinach);
    await harness.archiveProduct(spinach);

    expect(await scan('4001234567891'), isA<UnrecognizedBarcode>());
    final relearning = await harness
        .read(learnBarcodeUseCaseProvider)
        .execute(
          barcode: (await scan('4001234567891')).barcode,
          productIdentifier: spinach.identifier,
        );
    expect(relearning.failureOrNull, isA<BarcodeProductUnavailable>());
  });

  test('every package of weighed goods finds the product learned from one', () async {
    await learn('2412345003505', mincedMeat);

    final otherPackage = await scan('2412345004205');

    expect(otherPackage, isA<RecognizedBarcode>());
    expect(
      otherPackage.barcode.embeddedWeightFor(QuantityUnit.gram),
      const Quantity(amountInBaseUnits: 420, unit: QuantityUnit.gram),
    );
  });

  test('scan to add suggests the package size and the drawer used last time', () async {
    final compartments = await harness.compartments();
    await harness.addBatch(
      spinach,
      amountInBaseUnits: 400,
      storedOn: CalendarDate(2026, 9, 1),
      compartmentIndex: 2,
    );
    final recognized = await learn('4001234567891', spinach);
    final scanToAdd = harness.read(scanToAddUseCaseProvider);

    final suggestion = await scanToAdd.suggest(recognized);
    expect(suggestion.quantity, spinach.defaultPackageQuantity);
    expect(suggestion.compartment?.identifier, compartments[2].identifier);
    expect(suggestion.canAddWithOneTap, isTrue);

    final added = await scanToAdd.add(suggestion);

    final batch = (await harness.activeBatches()).singleWhere(
      (batch) => batch.identifier == added.valueOrNull,
    );
    expect(batch.quantityRemaining, spinach.defaultPackageQuantity);
    expect(batch.compartmentIdentifier, compartments[2].identifier);
    expect(batch.storedOn, CalendarDate(2026, 10, 3));
    expect(harness.publishedEvents.whereType<StockBatchAdded>(), hasLength(2));
  });

  test('scan to add takes the weight from a weighed-goods code', () async {
    await learn('2412345003505', mincedMeat);
    final recognized = await scan('2412345004205') as RecognizedBarcode;

    final suggestion = await harness.read(scanToAddUseCaseProvider).suggest(recognized);

    expect(suggestion.quantity, const Quantity(amountInBaseUnits: 420, unit: QuantityUnit.gram));
    expect(suggestion.compartment?.identifier, (await harness.compartments()).first.identifier);
  });
}
