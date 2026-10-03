import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_barcode_scanning/feature_barcode_scanning.dart';
import 'package:feature_configuration/feature_configuration.dart';
import 'package:feature_data_portability/feature_data_portability.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_item_pictures/feature_item_pictures.dart';
import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_restock/feature_restock.dart';
import 'package:feature_statistics/feature_statistics.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:feature_storage_reminders/feature_storage_reminders.dart';
import 'package:go_router/go_router.dart';

/// The complete list of modules the app is built with.
///
/// This is the only place that knows every module. Adding a feature means
/// adding one line here.
List<FeatureModule> createRegisteredFeatureModules() => [
  const StorageLayoutFeatureModule(),
  const ProductCatalogFeatureModule(),
  const InventoryFeatureModule(),
  const StorageRemindersFeatureModule(),
  const RestockFeatureModule(),
  const StatisticsFeatureModule(),
  const ItemPicturesFeatureModule(),
  const BarcodeScanningFeatureModule(),
  const ConfigurationFeatureModule(),
  const DataPortabilityFeatureModule(),
  const OnboardingFeatureModule(),
];

/// Thrown when two modules clash. Checked at start-up in debug builds and in tests.
final class ModuleRegistryException implements Exception {
  const ModuleRegistryException(this.message);

  final String message;

  @override
  String toString() => 'ModuleRegistryException: $message';
}

/// Verifies that module identifiers are unique and that every route a module
/// contributes starts with `/<moduleIdentifier>` (decision D8).
void verifyModuleRegistry(List<FeatureModule> modules) {
  final seenIdentifiers = <String>{};
  for (final module in modules) {
    if (!seenIdentifiers.add(module.moduleIdentifier)) {
      throw ModuleRegistryException('Duplicate module identifier ${module.moduleIdentifier}');
    }
    final routePrefix = '/${module.moduleIdentifier}';
    final topLevelPaths = [
      ...module.buildRoutes().whereType<GoRoute>().map((route) => route.path),
      ...?module.navigationDestination?.routes.whereType<GoRoute>().map((route) => route.path),
    ];
    for (final path in topLevelPaths) {
      if (path != routePrefix && !path.startsWith('$routePrefix/')) {
        throw ModuleRegistryException(
          'Route $path of ${module.moduleIdentifier} must start with $routePrefix',
        );
      }
    }
  }
}
