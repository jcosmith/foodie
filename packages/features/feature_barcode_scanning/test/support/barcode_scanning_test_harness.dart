import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_barcode_scanning/feature_barcode_scanning.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

final class _EnglishLayoutDefaultNames implements LayoutDefaultNames {
  const _EnglishLayoutDefaultNames();

  @override
  String storagePlaceName(StorageKind storageKind) => 'Freezer';

  @override
  String compartmentName(StorageKind storageKind, int number) => 'Drawer $number';

  @override
  String removedName(String name) => '$name (removed)';
}

/// Stands in for the camera: a grey box, and [showCode] plays the part of
/// holding a package in front of it.
final class FakeBarcodeDecoder implements BarcodeDecoder {
  ValueChanged<ScannedBarcode>? _onBarcodeDetected;

  void showCode(String value, {BarcodeSymbology symbology = BarcodeSymbology.ean13}) =>
      _onBarcodeDetected!(ScannedBarcode(value: value, symbology: symbology));

  @override
  Widget buildCameraView(
    BuildContext context, {
    required ValueChanged<ScannedBarcode> onBarcodeDetected,
    required Widget Function(BuildContext context, CameraProblem problem) problemBuilder,
  }) {
    _onBarcodeDetected = onBarcodeDetected;
    return const ColoredBox(key: Key('fake_camera'), color: Colors.grey);
  }
}

/// The catalog, a freezer with three drawers, the inventory and barcode
/// scanning on an in-memory database. 3 October 2026, 09:00 UTC.
final class BarcodeScanningTestHarness {
  BarcodeScanningTestHarness() {
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: SequentialIdentifierGenerator(),
      domainEventBus: InProcessDomainEventBus(logger: RecordingLogger()),
      logger: RecordingLogger(),
    );
    dependencies.domainEventBus.subscribe<DomainEvent>(publishedEvents.add);
    scanningModule = BarcodeScanningFeatureModule(barcodeDecoderOverride: decoder);
    container = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(clock),
        identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
        domainEventBusProvider.overrideWithValue(dependencies.domainEventBus),
        localLoggerProvider.overrideWithValue(RecordingLogger()),
        registeredFeatureModulesProvider.overrideWithValue(modules),
        enabledFeatureModulesProvider.overrideWith((ref) => Stream.value(modules)),
        for (final module in modules) ...module.buildProviderOverrides(dependencies),
      ],
    );
  }

  final FixedClock clock = FixedClock(DateTime.utc(2026, 10, 3, 9));
  final ApplicationDatabase database = createInMemoryApplicationDatabase();
  final FakeBarcodeDecoder decoder = FakeBarcodeDecoder();
  final List<DomainEvent> publishedEvents = [];
  late final BarcodeScanningFeatureModule scanningModule;
  late final ProviderContainer container;

  List<FeatureModule> get modules => [
    const StorageLayoutFeatureModule(),
    const ProductCatalogFeatureModule(),
    const InventoryFeatureModule(),
    const FreezerFeatureModule(),
    scanningModule,
  ];

  TValue read<TValue>(ProviderListenable<TValue> provider) => container.read(provider);

  Future<void> seedCatalogAndStoragePlace() async {
    await const ProductCatalogFeatureModule().initializeModule(_HarnessInitializationContext(this));
    await container
        .read(createStoragePlaceFromTemplateUseCaseProvider)
        .execute(
          template: FreezerStorageTemplates.uprightWithThreeDrawers,
          defaultNames: const _EnglishLayoutDefaultNames(),
        );
  }

  Future<Product> productWithKey(String catalogKey) async {
    final catalog = await container.read(productCatalogQueryServiceProvider).readCatalog();
    return catalog.activeProducts.singleWhere((product) => product.catalogKey == catalogKey);
  }

  Future<List<Compartment>> compartments() async =>
      (await container.read(storageLayoutQueryServiceProvider).readStorageLayout())
          .activeCompartments;

  Future<StockBatchIdentifier> addBatch(
    Product product, {
    required int amountInBaseUnits,
    required CalendarDate storedOn,
    int compartmentIndex = 0,
  }) async {
    final result = await container
        .read(addStockBatchUseCaseProvider)
        .execute(
          AddStockBatchCommand(
            productIdentifier: product.identifier,
            compartmentIdentifier: (await compartments())[compartmentIndex].identifier,
            quantity: Quantity(amountInBaseUnits: amountInBaseUnits, unit: product.canonicalUnit),
            storedOn: storedOn,
          ),
        );
    return result.valueOrNull!;
  }

  /// Archived directly in the database; archiving is the catalog's business.
  Future<void> archiveProduct(Product product) async {
    final productCatalogDao = database.productCatalogDao;
    final row = await productCatalogDao.readProduct(product.identifier.value);
    await productCatalogDao.replaceProduct(row!.copyWith(isArchived: true));
  }

  Future<List<StockBatch>> activeBatches() =>
      container.read(inventoryQueryServiceProvider).readActiveBatches();

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

final class _HarnessInitializationContext implements ModuleInitializationContext {
  _HarnessInitializationContext(this._harness);

  final BarcodeScanningTestHarness _harness;

  @override
  Clock get clock => _harness.clock;

  @override
  DomainEventBus get domainEventBus => _harness.read(domainEventBusProvider);

  @override
  LocalLogger get logger => RecordingLogger();

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _harness.read(provider);
}
