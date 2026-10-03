import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'contributions.dart';
import 'module_availability.dart';
import 'module_dependencies.dart';

/// The contract every feature package implements to plug into the app.
///
/// Adding a feature means creating a package, implementing this interface
/// (usually by extending [FeatureModuleBase]) and adding one line to the
/// module registry in the app shell.
abstract interface class FeatureModule {
  /// Stable identifier, also used as route prefix and preference namespace.
  String get moduleIdentifier;

  /// Localized strings this module brings.
  List<LocalizationsDelegate<Object>> get localizationDelegates;

  /// Riverpod overrides binding domain interfaces to implementations.
  List<Override> buildProviderOverrides(ModuleDependencies dependencies);

  /// Screens reachable by path outside the bottom navigation, including
  /// notification deep links. Paths start with `/<moduleIdentifier>`.
  List<RouteBase> buildRoutes();

  /// Optional tab in the bottom navigation bar.
  NavigationDestinationContribution? get navigationDestination;

  /// Whether users may switch this module off (barcode scanning is optional).
  ModuleAvailability get availability;

  /// Name and explanation of an optional module for its switch in the
  /// Config tab; `null` for modules that are always on.
  OptionalFeatureDescription? get optionalFeatureDescription;

  /// Entries in the floating "add" menu, e.g. "Scan to add".
  List<QuickActionContribution> get quickActions;

  /// Optional picture for an item in lists and detail screens.
  ItemVisualProvider? get itemVisualProvider;

  /// Cards for the home dashboard ("Eat soon", "Running low").
  List<DashboardCardContribution> get dashboardCards;

  /// Sections shown in the Config tab.
  List<ConfigSectionContribution> get configSections;

  /// Extra charts for the Insights tab, filtered by the shared statistics filter.
  List<InsightChartContribution> get insightCharts;

  /// Subscribe to events and run start-up reconciliation.
  Future<void> initializeModule(ModuleInitializationContext context);

  /// Where the app should open instead of Home, for example onboarding on
  /// the first start; `null` when this module has no opinion. Asked after
  /// every module has been initialised, in registry order; the first
  /// answer wins.
  Future<String?> resolveLaunchRoutePath(ModuleInitializationContext context);

  /// Release subscriptions.
  Future<void> disposeModule();
}

/// A [FeatureModule] that contributes nothing by default, so each module
/// only overrides what it actually provides.
abstract base class FeatureModuleBase implements FeatureModule {
  const FeatureModuleBase();

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => const [];

  @override
  List<RouteBase> buildRoutes() => const [];

  @override
  NavigationDestinationContribution? get navigationDestination => null;

  @override
  ModuleAvailability get availability => const ModuleAvailability.alwaysEnabled();

  @override
  OptionalFeatureDescription? get optionalFeatureDescription => null;

  @override
  List<QuickActionContribution> get quickActions => const [];

  @override
  ItemVisualProvider? get itemVisualProvider => null;

  @override
  List<DashboardCardContribution> get dashboardCards => const [];

  @override
  List<ConfigSectionContribution> get configSections => const [];

  @override
  List<InsightChartContribution> get insightCharts => const [];

  @override
  Future<void> initializeModule(ModuleInitializationContext context) async {}

  @override
  Future<String?> resolveLaunchRoutePath(ModuleInitializationContext context) async => null;

  @override
  Future<void> disposeModule() async {}
}
