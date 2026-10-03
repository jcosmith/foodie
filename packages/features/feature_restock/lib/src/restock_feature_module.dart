import 'package:core_database/core_database.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'application/restock_providers.dart';
import 'data/drift_restock_repository.dart';
import 'l10n/generated/restock_localizations.dart';
import 'presentation/restock_routes.dart';
import 'presentation/restock_rules_screen.dart';
import 'presentation/running_low_card.dart';
import 'presentation/runs_out_in_chart_card.dart';
import 'presentation/shopping_list_screen.dart';

/// Restock (build order phase 4): minimum quantities per product, low-stock
/// detection, the shopping list tab and putting bought items into the
/// freezer. The inventory never knows about it; it reacts to stock events.
final class RestockFeatureModule extends FeatureModuleBase {
  const RestockFeatureModule();

  static const String identifier = 'restock';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    RestockLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    restockRepositoryProvider.overrideWith(
      (ref) => DriftRestockRepository(
        restockDao: ref.watch(applicationDatabaseProvider).restockDao,
        clock: dependencies.clock,
      ),
    ),
  ];

  @override
  NavigationDestinationContribution get navigationDestination => NavigationDestinationContribution(
    sortOrder: 20,
    icon: Icons.checklist_outlined,
    selectedIcon: Icons.checklist,
    labelBuilder: (context) => RestockLocalizations.of(context).navigationLabel,
    initialLocation: RestockRoutes.shoppingList,
    routes: [
      GoRoute(
        path: RestockRoutes.shoppingList,
        builder: (context, state) => const ShoppingListScreen(),
      ),
    ],
  );

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(path: RestockRoutes.rules, builder: (context, state) => const RestockRulesScreen()),
  ];

  @override
  List<DashboardCardContribution> get dashboardCards => [
    DashboardCardContribution(
      identifier: '$identifier.running_low',
      sortOrder: 20,
      builder: (context) => const RunningLowCard(),
    ),
  ];

  @override
  List<ConfigSectionContribution> get configSections => [
    ConfigSectionContribution(
      identifier: '$identifier.rules',
      sortOrder: 50,
      titleBuilder: (context) => RestockLocalizations.of(context).configSectionTitle,
      builder: (context) => const RestockConfigSection(),
    ),
  ];

  @override
  List<InsightChartContribution> get insightCharts => [
    InsightChartContribution(
      identifier: '$identifier.runs_out_in',
      sortOrder: 50,
      builder: (context, filter) => RunsOutInChartCard(filter: filter),
    ),
  ];

  /// Brings the shopping list up to date with the stock at every start.
  @override
  Future<void> initializeModule(ModuleInitializationContext context) =>
      context.read(shoppingListReconciliationCoordinatorProvider).start();
}
