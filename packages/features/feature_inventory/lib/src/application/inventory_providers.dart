import 'package:core_database/core_database.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/inventory_repository.dart';
import 'inventory_overview.dart';
import 'inventory_query_service.dart';
import 'use_cases/add_stock_batch_use_case.dart';
import 'use_cases/correct_remaining_quantity_use_case.dart';
import 'use_cases/inventory_use_case_dependencies.dart';
import 'use_cases/move_stock_batch_use_case.dart';
import 'use_cases/remove_stock_use_cases.dart';
import 'use_cases/undo_stock_removal_use_case.dart';

/// Bound to the Drift implementation by the module's provider overrides.
final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => throw UnimplementedError('inventoryRepositoryProvider must be overridden'),
);

final inventoryQueryServiceProvider = Provider<InventoryQueryService>(
  (ref) => InventoryQueryService(ref.watch(inventoryRepositoryProvider)),
);

/// Everything in the freezer, joined with products and drawers, live.
final inventoryOverviewProvider = StreamProvider<InventoryOverview>((ref) {
  final clock = ref.watch(clockProvider);
  final catalogAndLayout = combineLatestOfTwo(
    ref.watch(productCatalogQueryServiceProvider).watchCatalog(),
    ref.watch(storageLayoutQueryServiceProvider).watchStorageLayout(),
    (catalog, layout) => (catalog, layout),
  );
  return combineLatestOfTwo(
    ref.watch(inventoryQueryServiceProvider).watchActiveBatches(),
    catalogAndLayout,
    (activeBatches, catalogAndLayout) => InventoryOverview.combine(
      activeBatches: activeBatches,
      catalog: catalogAndLayout.$1,
      layout: catalogAndLayout.$2,
      today: clock.todayLocal(),
    ),
  );
});

final inventoryUseCaseDependenciesProvider = Provider<InventoryUseCaseDependencies>(
  (ref) => InventoryUseCaseDependencies(
    repository: ref.watch(inventoryRepositoryProvider),
    transactionRunner: ref.watch(transactionRunnerProvider),
    domainEventBus: ref.watch(domainEventBusProvider),
    clock: ref.watch(clockProvider),
    identifierGenerator: ref.watch(identifierGeneratorProvider),
  ),
);

final addStockBatchUseCaseProvider = Provider<AddStockBatchUseCase>(
  (ref) => AddStockBatchUseCase(
    dependencies: ref.watch(inventoryUseCaseDependenciesProvider),
    productCatalog: ref.watch(productCatalogQueryServiceProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
  ),
);

final consumeStockUseCaseProvider = Provider<ConsumeStockUseCase>(
  (ref) => ConsumeStockUseCase(dependencies: ref.watch(inventoryUseCaseDependenciesProvider)),
);

final discardStockUseCaseProvider = Provider<DiscardStockUseCase>(
  (ref) => DiscardStockUseCase(dependencies: ref.watch(inventoryUseCaseDependenciesProvider)),
);

final undoStockRemovalUseCaseProvider = Provider<UndoStockRemovalUseCase>(
  (ref) => UndoStockRemovalUseCase(dependencies: ref.watch(inventoryUseCaseDependenciesProvider)),
);

final moveStockBatchUseCaseProvider = Provider<MoveStockBatchUseCase>(
  (ref) => MoveStockBatchUseCase(
    dependencies: ref.watch(inventoryUseCaseDependenciesProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
  ),
);

/// Moves without checking the destination, for emptying a compartment.
final stockBatchMoverProvider = Provider<StockBatchMover>(
  (ref) => StockBatchMover(ref.watch(inventoryUseCaseDependenciesProvider)),
);

final correctRemainingQuantityUseCaseProvider = Provider<CorrectRemainingQuantityUseCase>(
  (ref) => CorrectRemainingQuantityUseCase(
    dependencies: ref.watch(inventoryUseCaseDependenciesProvider),
  ),
);
