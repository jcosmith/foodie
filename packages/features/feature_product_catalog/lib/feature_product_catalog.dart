/// Public API of the product catalog feature.
library;

export 'domain.dart';
export 'src/application/product_catalog_providers.dart'
    show
        changeCategoryStorageLimitUseCaseProvider,
        productCatalogProvider,
        productCatalogQueryServiceProvider;
export 'src/application/product_catalog_query_service.dart';
export 'src/application/use_cases/change_category_storage_limit_use_case.dart';
export 'src/domain/product_catalog_failure.dart';
export 'src/l10n/generated/product_catalog_localizations.dart';
export 'src/presentation/catalog_localization.dart'
    show ContributedCatalogNames, ProductCatalogLocalizationContext;
export 'src/presentation/product_catalog_routes.dart' show ProductCatalogRoutes;
export 'src/presentation/product_picker_sheet.dart' show showProductPickerSheet;
export 'src/presentation/product_tile.dart' show ProductIcon, ProductVisual;
export 'src/product_catalog_feature_module.dart';
