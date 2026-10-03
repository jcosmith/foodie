/// Public API of the restock feature.
library;

export 'domain.dart';
export 'src/application/restock_providers.dart'
    show runningLowProductsProvider, shoppingListEntriesProvider;
export 'src/l10n/generated/restock_localizations.dart';
export 'src/presentation/restock_routes.dart';
export 'src/restock_feature_module.dart';
