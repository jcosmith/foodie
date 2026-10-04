import 'dart:typed_data';

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
import 'package:feature_item_pictures/feature_item_pictures.dart';
import 'package:feature_item_pictures/src/application/item_picture_providers.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
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

/// Hands out a test photo instead of opening the camera or the photo picker.
final class FakePictureSource implements PictureSource {
  Uint8List? nextPicture = createTestPhotoBytes();
  final List<PictureSourceKind> requestedKinds = [];

  @override
  Future<Uint8List?> obtainPicture(PictureSourceKind kind) async {
    requestedKinds.add(kind);
    return nextPicture;
  }
}

/// The catalog, a freezer, the inventory and item pictures on an in-memory
/// database and an in-memory picture store. 2 October 2026, 09:00 UTC.
final class ItemPicturesTestHarness {
  ItemPicturesTestHarness() {
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: SequentialIdentifierGenerator(),
      domainEventBus: InProcessDomainEventBus(logger: RecordingLogger()),
      logger: RecordingLogger(),
    );
    dependencies.domainEventBus.subscribe<DomainEvent>(publishedEvents.add);
    pictureModule = ItemPicturesFeatureModule(pictureSourceOverride: pictureSource);
    container = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        mediaFileStoreProvider.overrideWithValue(mediaFileStore),
        clockProvider.overrideWithValue(clock),
        identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
        domainEventBusProvider.overrideWithValue(dependencies.domainEventBus),
        localLoggerProvider.overrideWithValue(logger),
        registeredFeatureModulesProvider.overrideWithValue(modules),
        enabledFeatureModulesProvider.overrideWith(
          (ref) => Stream.value(
            isPictureModuleEnabled ? modules : modules.sublist(0, modules.length - 1),
          ),
        ),
        for (final module in modules) ...module.buildProviderOverrides(dependencies),
      ],
    );
  }

  final FixedClock clock = FixedClock(DateTime.utc(2026, 10, 2, 9));
  final ApplicationDatabase database = createInMemoryApplicationDatabase();
  final InMemoryMediaFileStore mediaFileStore = InMemoryMediaFileStore();
  final FakePictureSource pictureSource = FakePictureSource();
  final RecordingLogger logger = RecordingLogger();
  final List<DomainEvent> publishedEvents = [];
  late final ItemPicturesFeatureModule pictureModule;
  late final ProviderContainer container;

  /// Set before the first read to see the app with item pictures switched off.
  bool isPictureModuleEnabled = true;

  List<FeatureModule> get modules => [
    const StorageLayoutFeatureModule(),
    const ProductCatalogFeatureModule(),
    const InventoryFeatureModule(),
    const FreezerFeatureModule(),
    pictureModule,
  ];

  ModuleInitializationContext get initializationContext => _HarnessInitializationContext(this);

  TValue read<TValue>(ProviderListenable<TValue> provider) => container.read(provider);

  Future<void> seedCatalogAndStoragePlace() async {
    await const ProductCatalogFeatureModule().initializeModule(initializationContext);
    await container
        .read(createStoragePlaceFromTemplateUseCaseProvider)
        .execute(
          template: FreezerStorageTemplates.uprightWithThreeDrawers,
          defaultNames: const _EnglishLayoutDefaultNames(),
        );
  }

  Future<void> startPictureModule() => pictureModule.initializeModule(initializationContext);

  Future<Product> productWithKey(String catalogKey) async {
    final catalog = await container.read(productCatalogQueryServiceProvider).readCatalog();
    return catalog.activeProducts.singleWhere((product) => product.catalogKey == catalogKey);
  }

  Future<StockBatchIdentifier> addBatch(Product product, {int? amountInBaseUnits}) async {
    final layout = await container.read(storageLayoutQueryServiceProvider).readStorageLayout();
    final result = await container
        .read(addStockBatchUseCaseProvider)
        .execute(
          AddStockBatchCommand(
            productIdentifier: product.identifier,
            compartmentIdentifier: layout.activeCompartments.first.identifier,
            quantity: Quantity(
              amountInBaseUnits: amountInBaseUnits ?? 500,
              unit: product.canonicalUnit,
            ),
            storedOn: clock.todayLocal(),
          ),
        );
    return result.valueOrNull!;
  }

  Future<List<ItemPicture>> readPictures() =>
      container.read(itemPictureRepositoryProvider).readPictures();

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

final class _HarnessInitializationContext implements ModuleInitializationContext {
  _HarnessInitializationContext(this._harness);

  final ItemPicturesTestHarness _harness;

  @override
  Clock get clock => _harness.clock;

  @override
  DomainEventBus get domainEventBus => _harness.read(domainEventBusProvider);

  @override
  LocalLogger get logger => _harness.logger;

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _harness.read(provider);
}
