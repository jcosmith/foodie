import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_media_storage/testing.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_receipt_scanning/feature_receipt_scanning.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/widgets.dart';
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

/// Recognised text as the camera would deliver it: one line per row, the
/// description on the left and the price, if any, on the right.
RecognizedReceiptPage receiptPage(List<List<String>> rows) => RecognizedReceiptPage(
  lines: [
    for (final (index, row) in rows.indexed) ...[
      RecognizedTextLine(
        text: row.first,
        left: 10,
        top: index * 40.0,
        right: 300,
        bottom: index * 40.0 + 30,
      ),
      if (row.length > 1)
        RecognizedTextLine(
          text: row[1],
          left: 400,
          top: index * 40.0 + 2,
          right: 480,
          bottom: index * 40.0 + 32,
        ),
    ],
  ],
);

/// Stands in for the camera: every photo is a small JPEG, and [queuedPages]
/// says what recognition will read on the next ones.
final class FakeReceiptCamera implements ReceiptPhotoSource, ReceiptTextRecognizer {
  final List<RecognizedReceiptPage> queuedPages = [];
  final List<String> discardedPaths = [];
  var _photoCount = 0;

  @override
  Future<ReceiptPhoto?> takePhoto() async {
    _photoCount++;
    return ReceiptPhoto(path: 'camera/$_photoCount.jpg', bytes: createTestPhotoBytes());
  }

  @override
  Future<ReceiptPhoto?> pickFromGallery() => takePhoto();

  @override
  Future<void> discard(ReceiptPhoto photo) async => discardedPaths.add(photo.path);

  @override
  Future<List<RecognizedTextLine>> recognize(ReceiptPhoto photo) async =>
      queuedPages.isEmpty ? const [] : queuedPages.removeAt(0).lines;
}

/// The catalog, a freezer with three drawers, the inventory and receipt
/// scanning on an in-memory database. 3 October 2026, 09:00 UTC.
final class ReceiptScanningTestHarness {
  ReceiptScanningTestHarness() {
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: SequentialIdentifierGenerator(),
      domainEventBus: InProcessDomainEventBus(logger: RecordingLogger()),
      logger: RecordingLogger(),
    );
    container = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(clock),
        identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
        domainEventBusProvider.overrideWithValue(dependencies.domainEventBus),
        localLoggerProvider.overrideWithValue(RecordingLogger()),
        receiptMediaFileStoreProvider.overrideWithValue(receiptImages),
        registeredFeatureModulesProvider.overrideWithValue(modules),
        enabledFeatureModulesProvider.overrideWith((ref) => Stream.value(modules)),
        for (final module in modules) ...module.buildProviderOverrides(dependencies),
      ],
    );
  }

  final FixedClock clock = FixedClock(DateTime.utc(2026, 10, 3, 9));
  final ApplicationDatabase database = createInMemoryApplicationDatabase();
  final FakeReceiptCamera camera = FakeReceiptCamera();
  final InMemoryMediaFileStore receiptImages = InMemoryMediaFileStore();
  late final ProviderContainer container;
  late final ReceiptScanningFeatureModule receiptModule = ReceiptScanningFeatureModule(
    photoSourceOverride: camera,
    textRecognizerOverride: camera,
  );

  List<FeatureModule> get modules => [
    const StorageLayoutFeatureModule(),
    const ProductCatalogFeatureModule(),
    const InventoryFeatureModule(),
    const FreezerFeatureModule(),
    receiptModule,
  ];

  TValue read<TValue>(ProviderListenable<TValue> provider) => container.read(provider);

  ModuleInitializationContext get initializationContext => _HarnessInitializationContext(this);

  /// Product names in English, as the review screen would pass them.
  ProductDisplayNameResolver get names => ProductDisplayNameResolver(
    ContributedCatalogNames(read(registeredCatalogContributionsProvider), const Locale('en')),
  );

  Future<void> seedCatalogAndStoragePlace() async {
    container.listen(enabledFeatureModulesProvider, (_, _) {});
    await container.read(enabledFeatureModulesProvider.future);
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

  Future<ReceiptReview> review(List<List<String>> rows) =>
      read(prepareReceiptReviewUseCaseProvider).execute(pages: [receiptPage(rows)], names: names);

  Future<List<StockBatch>> activeBatches() =>
      container.read(inventoryQueryServiceProvider).readActiveBatches();

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

final class _HarnessInitializationContext implements ModuleInitializationContext {
  _HarnessInitializationContext(this._harness);

  final ReceiptScanningTestHarness _harness;

  @override
  Clock get clock => _harness.clock;

  @override
  DomainEventBus get domainEventBus => _harness.read(domainEventBusProvider);

  @override
  LocalLogger get logger => RecordingLogger();

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _harness.read(provider);
}
