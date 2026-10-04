import 'dart:async';

import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/restock_policy.dart';
import '../domain/restock_repository.dart';
import '../domain/restock_rule.dart';
import '../domain/shopping_list_entry.dart';
import '../domain/stock_run_out_forecast.dart';
import 'stock_totals.dart';
import 'use_cases/reconcile_shopping_list_use_case.dart';
import 'use_cases/restock_rule_use_cases.dart';
import 'use_cases/shopping_list_use_cases.dart';

/// Bound to the Drift repository by the module's provider overrides.
final restockRepositoryProvider = Provider<RestockRepository>(
  (ref) => throw UnimplementedError('restockRepositoryProvider must be overridden'),
);

final restockRulesProvider = StreamProvider<List<RestockRule>>(
  (ref) => ref.watch(restockRepositoryProvider).watchRules(),
);

/// The shopping list as shown: entries of products whose domain is switched
/// off are hidden, not deleted.
final shoppingListEntriesProvider = StreamProvider<List<ShoppingListEntry>>((ref) async* {
  final pausedDomains = ref.watch(pausedStorageDomainIdentifiersProvider);
  final entries = ref.watch(restockRepositoryProvider).watchShoppingList();
  if (pausedDomains.isEmpty) {
    yield* entries;
    return;
  }
  final pausedProducts = _productsIn(pausedDomains, await ref.watch(productCatalogProvider.future));
  yield* entries.map(
    (entries) => [
      for (final entry in entries)
        if (!pausedProducts.contains(entry.productIdentifier)) entry,
    ],
  );
});

Set<ProductIdentifier> _productsIn(Set<StorageDomainIdentifier> domains, ProductCatalog catalog) =>
    {
      for (final product in catalog.activeProducts)
        if (domains.contains(catalog.storageDomainOf(product))) product.identifier,
    };

/// Rules of products whose domain is switched on; `null` while loading.
final _activeRulesProvider = Provider<List<RestockRule>?>((ref) {
  final rules = ref.watch(restockRulesProvider).value;
  final pausedDomains = ref.watch(pausedStorageDomainIdentifiersProvider);
  if (rules == null || pausedDomains.isEmpty) return rules;
  final catalog = ref.watch(productCatalogProvider).value;
  if (catalog == null) return null;
  final pausedProducts = _productsIn(pausedDomains, catalog);
  return [
    for (final rule in rules)
      if (!pausedProducts.contains(rule.productIdentifier)) rule,
  ];
});

final stockByProductProvider = StreamProvider<Map<ProductIdentifier, Quantity>>(
  (ref) => ref.watch(inventoryQueryServiceProvider).watchActiveBatches().map(sumStockByProduct),
);

/// Products below their minimum, for the "Running low" card; `null` while loading.
final runningLowProductsProvider = Provider<List<Product>?>((ref) {
  final rules = ref.watch(_activeRulesProvider);
  final stockByProduct = ref.watch(stockByProductProvider).value;
  final catalog = ref.watch(productCatalogProvider).value;
  if (rules == null || stockByProduct == null || catalog == null) return null;
  return [
    for (final rule in rules)
      if (catalog.productOf(rule.productIdentifier) case final product? when !product.isArchived)
        if (RestockPolicy.isRunningLow(
          rule: rule,
          stock: stockByProduct[rule.productIdentifier] ?? Quantity.zero(product.canonicalUnit),
        ))
          product,
  ];
});

/// Movements of the forecast's look-back window, counted from when the
/// provider was first read.
final recentMovementsProvider = StreamProvider<List<InventoryMovement>>((ref) {
  final occurredFrom = ref
      .watch(clockProvider)
      .nowUtc()
      .subtract(const Duration(days: StockRunOutForecasting.lookBackInDays));
  return ref.watch(inventoryQueryServiceProvider).watchMovementsSince(occurredFrom);
});

/// When each product with a restock rule runs out, soonest first; `null`
/// while loading.
final stockRunOutForecastsProvider = Provider<List<StockRunOutForecast>?>((ref) {
  final rules = ref.watch(_activeRulesProvider);
  final stockByProduct = ref.watch(stockByProductProvider).value;
  final recentMovements = ref.watch(recentMovementsProvider).value;
  final catalog = ref.watch(productCatalogProvider).value;
  if (rules == null || stockByProduct == null || recentMovements == null || catalog == null) {
    return null;
  }
  return StockRunOutForecasting.forecast(
    rules: [
      for (final rule in rules)
        if (rule.isActive)
          if (catalog.productOf(rule.productIdentifier) case final product?
              when !product.isArchived)
            rule,
    ],
    stockByProduct: stockByProduct,
    recentMovements: recentMovements,
    canonicalUnitOf: (productIdentifier) => catalog.productOf(productIdentifier)!.canonicalUnit,
  );
});

final reconcileShoppingListUseCaseProvider = Provider<ReconcileShoppingListUseCase>(
  (ref) => ReconcileShoppingListUseCase(
    repository: ref.watch(restockRepositoryProvider),
    inventory: ref.watch(inventoryQueryServiceProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    readPausedDomains: () => ref.read(pausedStorageDomainIdentifiersProvider),
    transactionRunner: ref.watch(transactionRunnerProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
  ),
);

final saveRestockRuleUseCaseProvider = Provider<SaveRestockRuleUseCase>(
  (ref) => SaveRestockRuleUseCase(
    repository: ref.watch(restockRepositoryProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    reconcileShoppingList: ref.watch(reconcileShoppingListUseCaseProvider),
  ),
);

final removeRestockRuleUseCaseProvider = Provider<RemoveRestockRuleUseCase>(
  (ref) => RemoveRestockRuleUseCase(
    repository: ref.watch(restockRepositoryProvider),
    reconcileShoppingList: ref.watch(reconcileShoppingListUseCaseProvider),
  ),
);

final addProductToShoppingListUseCaseProvider = Provider<AddProductToShoppingListUseCase>(
  (ref) => AddProductToShoppingListUseCase(
    repository: ref.watch(restockRepositoryProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
  ),
);

final tickShoppingListEntryUseCaseProvider = Provider<TickShoppingListEntryUseCase>(
  (ref) => TickShoppingListEntryUseCase(
    repository: ref.watch(restockRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final removeShoppingListEntryUseCaseProvider = Provider<RemoveShoppingListEntryUseCase>(
  (ref) => RemoveShoppingListEntryUseCase(repository: ref.watch(restockRepositoryProvider)),
);

final putTickedItemsAwayUseCaseProvider = Provider<PutTickedItemsAwayUseCase>(
  (ref) => PutTickedItemsAwayUseCase(
    repository: ref.watch(restockRepositoryProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    inventory: ref.watch(inventoryQueryServiceProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
    addStockBatch: ref.watch(addStockBatchUseCaseProvider),
    reconcileShoppingList: ref.watch(reconcileShoppingListUseCaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Reconciles the shopping list after every stock change, when products
/// change (package size, archiving) and at start.
final shoppingListReconciliationCoordinatorProvider = Provider<RecomputationCoordinator>((ref) {
  final domainEventBus = ref.watch(domainEventBusProvider);
  final coordinator = RecomputationCoordinator(
    description: 'the shopping list',
    subscribeToEvents: (requestRecomputation) => [
      domainEventBus.subscribe<StockBatchEvent>((_) => requestRecomputation()),
      domainEventBus.subscribe<ProductUpdated>((_) => requestRecomputation()),
      domainEventBus.subscribe<ProductArchived>((_) => requestRecomputation()),
    ],
    settingChanges: const [],
    recompute: ref.watch(reconcileShoppingListUseCaseProvider).execute,
    logger: ref.watch(localLoggerProvider),
  );
  // Switching a domain on again lets its minimums catch up; listening keeps
  // the switches loaded for the use case.
  ref.listen(pausedStorageDomainIdentifiersProvider, (previous, next) {
    if (previous != null && !(previous.length == next.length && previous.containsAll(next))) {
      unawaited(coordinator.requestRecomputation());
    }
  });
  ref.onDispose(coordinator.stop);
  return coordinator;
});
