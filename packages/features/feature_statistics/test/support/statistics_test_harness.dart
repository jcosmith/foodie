import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_statistics/feature_statistics.dart';
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

/// A provider container over an in-memory database with the catalog seeded,
/// one freezer, the inventory to record history with, and the statistics
/// module. Today is 2 October 2026, 09:00 UTC.
final class StatisticsTestHarness {
  StatisticsTestHarness({List<FeatureModule> registeredModules = const []}) {
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
        localLoggerProvider.overrideWithValue(logger),
        registeredFeatureModulesProvider.overrideWithValue([
          const StatisticsFeatureModule(),
          ...registeredModules,
        ]),
        for (final module in const [
          StorageLayoutFeatureModule(),
          ProductCatalogFeatureModule(),
          InventoryFeatureModule(),
          StatisticsFeatureModule(),
        ])
          ...module.buildProviderOverrides(dependencies),
      ],
    );
  }

  static final DateTime now = DateTime.utc(2026, 10, 2, 9);

  final FixedClock clock = FixedClock(now);
  final ApplicationDatabase database = createInMemoryApplicationDatabase();
  final RecordingLogger logger = RecordingLogger();
  late final ProviderContainer container;

  ModuleInitializationContext get initializationContext => _HarnessInitializationContext(this);

  TValue read<TValue>(ProviderListenable<TValue> provider) => container.read(provider);

  Future<void> seedCatalogAndStoragePlace() async {
    await const ProductCatalogFeatureModule().initializeModule(initializationContext);
    await container
        .read(createStoragePlaceFromTemplateUseCaseProvider)
        .execute(
          template: StorageTemplate.uprightWithThreeDrawers,
          defaultNames: const _EnglishLayoutDefaultNames(),
        );
  }

  Future<Product> productWithKey(String catalogKey) async {
    final catalog = await container.read(productCatalogQueryServiceProvider).readCatalog();
    return catalog.activeProducts.singleWhere((product) => product.catalogKey == catalogKey);
  }

  /// Runs [action] as if it happened [daysAgo] days before today, at the same time of day.
  Future<TResult> _daysAgo<TResult>(int daysAgo, Future<TResult> Function() action) async {
    clock.setTo(now.subtract(Duration(days: daysAgo)));
    try {
      return await action();
    } finally {
      clock.setTo(now);
    }
  }

  Future<StockBatchIdentifier> addBatch(
    Product product,
    num displayAmount, {
    required int daysAgo,
    int compartmentIndex = 0,
  }) => _daysAgo(daysAgo, () async {
    final layout = await container.read(storageLayoutQueryServiceProvider).readStorageLayout();
    final result = await container
        .read(addStockBatchUseCaseProvider)
        .execute(
          AddStockBatchCommand(
            productIdentifier: product.identifier,
            compartmentIdentifier: layout.activeCompartments[compartmentIndex].identifier,
            quantity: Quantity.fromDisplayAmount(displayAmount, product.canonicalUnit),
            storedOn: clock.todayLocal(),
          ),
        );
    return result.valueOrNull!;
  });

  Future<void> consume(
    StockBatchIdentifier batch,
    Product product,
    num displayAmount, {
    required int daysAgo,
  }) => _daysAgo(
    daysAgo,
    () => container
        .read(consumeStockUseCaseProvider)
        .execute(
          stockBatchIdentifier: batch,
          quantity: Quantity.fromDisplayAmount(displayAmount, product.canonicalUnit),
        ),
  );

  Future<void> discard(
    StockBatchIdentifier batch,
    Product product,
    num displayAmount, {
    required int daysAgo,
    DiscardReason reason = DiscardReason.freezerBurn,
  }) => _daysAgo(
    daysAgo,
    () => container
        .read(discardStockUseCaseProvider)
        .execute(
          stockBatchIdentifier: batch,
          quantity: Quantity.fromDisplayAmount(displayAmount, product.canonicalUnit),
          discardReason: reason,
        ),
  );

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

final class _HarnessInitializationContext implements ModuleInitializationContext {
  _HarnessInitializationContext(this._harness);

  final StatisticsTestHarness _harness;

  @override
  Clock get clock => _harness.clock;

  @override
  DomainEventBus get domainEventBus => _harness.read(domainEventBusProvider);

  @override
  LocalLogger get logger => _harness.logger;

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _harness.read(provider);
}
