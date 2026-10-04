import 'package:core_database/core_database.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'application/product_catalog_providers.dart';
import 'data/drift_product_catalog_repository.dart';
import 'data/system_dialog_product_icon_image_file_picker.dart';
import 'l10n/generated/product_catalog_localizations.dart';
import 'presentation/product_catalog_routes.dart';
import 'presentation/product_list_screen.dart';

/// Products and categories with the translated seeded catalog.
final class ProductCatalogFeatureModule extends FeatureModuleBase {
  const ProductCatalogFeatureModule();

  static const String identifier = 'product_catalog';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    ProductCatalogLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    productCatalogRepositoryProvider.overrideWith(
      (ref) => DriftProductCatalogRepository(ref.watch(productCatalogDaoProvider)),
    ),
    productIconImageFilePickerProvider.overrideWithValue(
      const SystemDialogProductIconImageFilePicker(),
    ),
  ];

  @override
  List<RouteBase> buildRoutes() => buildProductCatalogRoutes();

  /// Placed right after the storage layout; the Options table of the
  /// architecture document has no row for products yet.
  @override
  List<ConfigSectionContribution> get configSections => [
    ConfigSectionContribution(
      identifier: '$identifier.products',
      sortOrder: 25,
      titleBuilder: (context) => ProductCatalogLocalizations.of(context).configSectionTitle,
      builder: (context) => const ProductsConfigSection(),
    ),
  ];

  /// Seeds catalog entries that are missing, so new seeded products reach
  /// existing users after an update.
  @override
  Future<void> initializeModule(ModuleInitializationContext context) async {
    await context.read(seedCatalogUseCaseProvider).execute();
  }
}
