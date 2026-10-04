import 'package:core_database/core_database.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'application/inventory_compartment_contents.dart';
import 'application/inventory_providers.dart';
import 'data/drift_inventory_repository.dart';
import 'l10n/generated/inventory_localizations.dart';
import 'presentation/inventory_routes.dart';

/// What is in the freezer: the "Freezer" tab, the add form and the sheets for
/// taking, throwing away, moving and correcting. Also tells the storage
/// layout which drawers hold something.
final class InventoryFeatureModule extends FeatureModuleBase {
  const InventoryFeatureModule();

  static const String identifier = 'inventory';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    InventoryLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    inventoryRepositoryProvider.overrideWith(
      (ref) => DriftInventoryRepository(ref.watch(inventoryDaoProvider)),
    ),
    compartmentContentsPortProvider.overrideWith(
      (ref) => InventoryCompartmentContents(
        repository: ref.watch(inventoryRepositoryProvider),
        stockBatchMover: ref.watch(stockBatchMoverProvider),
      ),
    ),
  ];

  @override
  List<RouteBase> buildRoutes() => buildInventoryRoutes();

  @override
  List<QuickActionContribution> get quickActions => [
    QuickActionContribution(
      identifier: '$identifier.add',
      sortOrder: 10,
      icon: Icons.add,
      labelBuilder: (context) => InventoryLocalizations.of(context).quickActionAdd,
      onSelected: (context) => context.push(InventoryRoutes.addStockBatch()),
    ),
  ];
}
