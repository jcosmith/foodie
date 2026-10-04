/// Public API of the storage layout feature: storage places and their compartments.
library;

export 'domain.dart';
export 'src/application/storage_layout_providers.dart'
    show
        compartmentContentsPortProvider,
        compartmentItemCountsProvider,
        createStoragePlaceFromTemplateUseCaseProvider,
        storageLayoutProvider,
        storageLayoutQueryServiceProvider;
export 'src/application/storage_layout_query_service.dart';
export 'src/application/use_cases/create_storage_place_from_template_use_case.dart';
export 'src/l10n/generated/storage_layout_localizations.dart';
export 'src/presentation/layout_localization.dart' show StorageLayoutLocalizationContext;
export 'src/presentation/storage_layout_routes.dart' show StorageLayoutRoutes;
export 'src/presentation/storage_template_choice_list.dart';
export 'src/storage_layout_feature_module.dart';
