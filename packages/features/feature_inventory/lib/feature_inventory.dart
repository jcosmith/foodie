/// Public API of the inventory feature.
library;

export 'domain.dart';
export 'src/application/inventory_overview.dart';
export 'src/application/inventory_providers.dart'
    show
        addStockBatchUseCaseProvider,
        allInventoryOverviewProvider,
        consumeStockUseCaseProvider,
        discardStockUseCaseProvider,
        inventoryOverviewProvider,
        inventoryQueryServiceProvider;
export 'src/application/inventory_query_service.dart';
export 'src/application/use_cases/add_stock_batch_use_case.dart';
export 'src/application/use_cases/remove_stock_use_cases.dart'
    show ConsumeStockUseCase, DiscardStockUseCase, RecordedStockRemoval;
export 'src/inventory_feature_module.dart';
export 'src/l10n/generated/inventory_localizations.dart';
export 'src/presentation/inventory_overview_screen.dart' show InventoryOverviewScreen;
export 'src/presentation/inventory_routes.dart' show InventoryRoutes;
export 'src/presentation/inventory_texts.dart' show InventoryTexts;
export 'src/presentation/stock_batch_sheets.dart' show showTakeStockSheet;
export 'src/presentation/stock_item_tile.dart' show StockItemTile;
