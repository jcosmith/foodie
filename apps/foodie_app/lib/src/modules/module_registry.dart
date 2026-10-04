import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_barcode_scanning/feature_barcode_scanning.dart';
import 'package:feature_configuration/feature_configuration.dart';
import 'package:feature_data_portability/feature_data_portability.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_fridge/feature_fridge.dart';
import 'package:feature_household_supplies/feature_household_supplies.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_item_pictures/feature_item_pictures.dart';
import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:feature_pantry/feature_pantry.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_receipt_scanning/feature_receipt_scanning.dart';
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
  const FreezerFeatureModule(),
  const FridgeFeatureModule(),
  const PantryFeatureModule(),
  const HouseholdSuppliesFeatureModule(),
  const ProductCatalogFeatureModule(),
  const InventoryFeatureModule(),
  const StorageRemindersFeatureModule(),
  const RestockFeatureModule(),
  const StatisticsFeatureModule(),
  const ItemPicturesFeatureModule(),
  const BarcodeScanningFeatureModule(),
  const ReceiptScanningFeatureModule(),
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

/// Verifies that module identifiers are unique, that every route a module
/// contributes starts with `/<moduleIdentifier>` (decision D8), and that
/// storage domains, kinds, templates and seeded catalog keys are unique and
/// refer to each other correctly.
void verifyModuleRegistry(List<FeatureModule> modules) {
  _verifyRoutes(modules);
  _verifyStorageContributions(modules);
}

void _requireUnique(Set<String> seen, String value, String what) {
  if (!seen.add(value)) throw ModuleRegistryException('Duplicate $what $value');
}

void _verifyStorageContributions(List<FeatureModule> modules) {
  final domains = <String>{};
  for (final module in modules) {
    final domain = module.storageDomain;
    if (domain == null) continue;
    _requireUnique(domains, domain.identifier.value, 'storage domain');
    if (!module.availability.isOptional) {
      throw ModuleRegistryException(
        'Storage domain ${domain.identifier.value} must be optional, as its switch',
      );
    }
  }
  final kinds = <String>{};
  final templates = <String>{};
  final categories = <String>{};
  final products = <String>{};
  for (final module in modules) {
    for (final kind in module.storageKinds) {
      _requireUnique(kinds, kind.storageName, 'storage kind');
      if (!domains.contains(kind.domainIdentifier.value)) {
        throw ModuleRegistryException(
          'Storage kind ${kind.storageName} belongs to the unknown domain '
          '${kind.domainIdentifier.value}',
        );
      }
      if (kind.templates.isEmpty) {
        throw ModuleRegistryException('Storage kind ${kind.storageName} has no template');
      }
      for (final template in kind.templates) {
        _requireUnique(templates, template.identifier, 'storage template');
        if (template.compartmentCount < 1) {
          throw ModuleRegistryException('Template ${template.identifier} has no compartment');
        }
      }
    }
    for (final category in module.catalog?.categories ?? const <SeededCategoryContribution>[]) {
      _requireUnique(categories, category.catalogKey, 'seeded category');
    }
  }
  for (final module in modules) {
    for (final product in module.catalog?.products ?? const <SeededProductContribution>[]) {
      _requireUnique(products, product.catalogKey, 'seeded product');
      if (!categories.contains(product.categoryCatalogKey)) {
        throw ModuleRegistryException(
          'Seeded product ${product.catalogKey} is in the unknown category '
          '${product.categoryCatalogKey}',
        );
      }
    }
  }
}

void _verifyRoutes(List<FeatureModule> modules) {
  final seenIdentifiers = <String>{};
  for (final module in modules) {
    if (!seenIdentifiers.add(module.moduleIdentifier)) {
      throw ModuleRegistryException('Duplicate module identifier ${module.moduleIdentifier}');
    }
    final routePrefix = '/${module.moduleIdentifier}';
    final topLevelPaths = [
      ...module.buildRoutes().whereType<GoRoute>().map((route) => route.path),
      ...?module.navigationDestination?.routes.whereType<GoRoute>().map((route) => route.path),
      for (final entry in module.moreEntries)
        ...entry.routes.whereType<GoRoute>().map((route) => route.path),
    ];
    if (module.navigationDestination != null && module.storageDomain == null) {
      throw ModuleRegistryException(
        'Only storage domains have tabs; ${module.moduleIdentifier} adds a Lists segment, '
        'a More entry or an Options section instead',
      );
    }
    for (final path in topLevelPaths) {
      if (path != routePrefix && !path.startsWith('$routePrefix/')) {
        throw ModuleRegistryException(
          'Route $path of ${module.moduleIdentifier} must start with $routePrefix',
        );
      }
    }
  }
}
