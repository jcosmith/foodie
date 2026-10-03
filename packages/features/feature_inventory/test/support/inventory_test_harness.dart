import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_inventory/src/application/inventory_providers.dart';
import 'package:feature_inventory/src/domain/inventory_repository.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// English default names without Flutter localizations.
final class _EnglishLayoutDefaultNames implements LayoutDefaultNames {
  const _EnglishLayoutDefaultNames();

  @override
  String freezerName(StorageKind storageKind) => 'Freezer';

  @override
  String compartmentName(StorageKind storageKind, int number) => 'Drawer $number';

  @override
  String removedName(String name) => '$name (removed)';
}

/// The catalog, the layout and the inventory on an in-memory database, wired
/// as the app wires them.
final class InventoryTestHarness {
  InventoryTestHarness() : database = createInMemoryApplicationDatabase(clock: clock) {
    final eventBus = InProcessDomainEventBus(logger: RecordingLogger());
    eventBus.subscribe<DomainEvent>(publishedEvents.add);
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: SequentialIdentifierGenerator(),
      domainEventBus: eventBus,
      logger: RecordingLogger(),
    );
    container = ProviderContainer(overrides: buildOverrides(dependencies));
  }

  static final FixedClock clock = FixedClock(DateTime.utc(2026, 10, 2, 12));
  static final CalendarDate today = CalendarDate(2026, 10, 2);

  final ApplicationDatabase database;
  final List<DomainEvent> publishedEvents = [];
  late final ProviderContainer container;

  List<Override> buildOverrides(ModuleDependencies dependencies) => [
    applicationDatabaseProvider.overrideWithValue(database),
    clockProvider.overrideWithValue(dependencies.clock),
    identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
    domainEventBusProvider.overrideWithValue(dependencies.domainEventBus),
    ...const ProductCatalogFeatureModule().buildProviderOverrides(dependencies),
    ...const StorageLayoutFeatureModule().buildProviderOverrides(dependencies),
    ...const InventoryFeatureModule().buildProviderOverrides(dependencies),
    enabledFeatureModulesProvider.overrideWith((ref) => Stream.value(const [])),
  ];

  TValue read<TValue>(ProviderListenable<TValue> provider) => container.read(provider);

  InventoryRepository get repository => read(inventoryRepositoryProvider);

  /// Seeds the catalog and creates a freezer with three drawers.
  Future<List<Compartment>> setUpCatalogAndFreezer() async {
    await const ProductCatalogFeatureModule().initializeModule(_ModuleInitializationContext(this));
    await read(createFreezerFromTemplateUseCaseProvider).execute(
      template: FreezerTemplate.uprightWithThreeDrawers,
      enteredName: '',
      defaultNames: const _EnglishLayoutDefaultNames(),
    );
    return (await read(storageLayoutQueryServiceProvider).readStorageLayout()).activeCompartments;
  }

  Future<Product> seededProduct(String catalogKey) async {
    final catalog = await read(productCatalogQueryServiceProvider).readCatalog();
    return catalog.activeProducts.firstWhere((product) => product.catalogKey == catalogKey);
  }

  Future<StockBatchIdentifier> addBatch({
    required Product product,
    required Compartment compartment,
    required int amountInBaseUnits,
    CalendarDate? frozenOn,
  }) async {
    final result = await read(addStockBatchUseCaseProvider).execute(
      AddStockBatchCommand(
        productIdentifier: product.identifier,
        compartmentIdentifier: compartment.identifier,
        quantity: Quantity(amountInBaseUnits: amountInBaseUnits, unit: product.canonicalUnit),
        frozenOn: frozenOn ?? today,
      ),
    );
    return result.valueOrNull!;
  }

  Future<StockBatch> readBatch(StockBatchIdentifier stockBatchIdentifier) async =>
      (await repository.readBatch(stockBatchIdentifier))!;

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

final class _ModuleInitializationContext implements ModuleInitializationContext {
  _ModuleInitializationContext(this._harness);

  final InventoryTestHarness _harness;

  @override
  DomainEventBus get domainEventBus => _harness.read(domainEventBusProvider);

  @override
  Clock get clock => InventoryTestHarness.clock;

  @override
  LocalLogger get logger => RecordingLogger();

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _harness.read(provider);
}
