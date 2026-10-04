import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_inventory/feature_inventory.dart';
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

/// A provider container over an in-memory database with the catalog seeded,
/// one freezer and fake notifications. 2 October 2026, 09:00 UTC.
final class StorageRemindersTestHarness {
  StorageRemindersTestHarness() {
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: SequentialIdentifierGenerator(),
      domainEventBus: InProcessDomainEventBus(logger: RecordingLogger()),
      logger: RecordingLogger(),
    );
    container = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        registeredFeatureModulesProvider.overrideWithValue(const [FreezerFeatureModule()]),
        clockProvider.overrideWithValue(clock),
        identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
        domainEventBusProvider.overrideWithValue(dependencies.domainEventBus),
        localLoggerProvider.overrideWithValue(logger),
        notificationSchedulerProvider.overrideWithValue(notificationServices),
        notificationPermissionServiceProvider.overrideWithValue(notificationServices),
        for (final module in const [
          StorageLayoutFeatureModule(),
          ProductCatalogFeatureModule(),
          InventoryFeatureModule(),
        ])
          ...module.buildProviderOverrides(dependencies),
      ],
    );
  }

  final FixedClock clock = FixedClock(DateTime.utc(2026, 10, 2, 9));
  final ApplicationDatabase database = createInMemoryApplicationDatabase();
  final FakeNotificationServices notificationServices = FakeNotificationServices();
  final RecordingLogger logger = RecordingLogger();
  late final ProviderContainer container;

  CalendarDate get today => clock.todayLocal();

  /// What the app shell hands modules at start-up.
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

  Future<Product> productWithKey(String catalogKey) async {
    final catalog = await container.read(productCatalogQueryServiceProvider).readCatalog();
    return catalog.activeProducts.singleWhere((product) => product.catalogKey == catalogKey);
  }

  Future<int> storageDaysOf(Product product) async {
    final catalog = await container.read(productCatalogQueryServiceProvider).readCatalog();
    return catalog.recommendedMaximumStorageDaysOf(product)!;
  }

  Future<StockBatchIdentifier> addBatch(Product product, {required CalendarDate storedOn}) async {
    final layout = await container.read(storageLayoutQueryServiceProvider).readStorageLayout();
    final result = await container
        .read(addStockBatchUseCaseProvider)
        .execute(
          AddStockBatchCommand(
            productIdentifier: product.identifier,
            compartmentIdentifier: layout.activeCompartments.first.identifier,
            quantity:
                product.defaultPackageQuantity ??
                Quantity(amountInBaseUnits: 1, unit: product.canonicalUnit),
            storedOn: storedOn,
          ),
        );
    return result.valueOrNull!;
  }

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

final class _HarnessInitializationContext implements ModuleInitializationContext {
  _HarnessInitializationContext(this._harness);

  final StorageRemindersTestHarness _harness;

  @override
  Clock get clock => _harness.clock;

  @override
  DomainEventBus get domainEventBus => _harness.read(domainEventBusProvider);

  @override
  LocalLogger get logger => _harness.logger;

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _harness.read(provider);
}
