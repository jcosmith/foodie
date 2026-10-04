import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../home/home_dashboard_screen.dart';
import '../l10n/generated/application_shell_localizations.dart';
import '../lists/lists_screen.dart';
import '../more/more_screen.dart';
import 'application_navigation_scaffold.dart';

/// One tab of the bottom navigation, after sorting.
final class ResolvedNavigationDestination {
  const ResolvedNavigationDestination({
    required this.iconEmoji,
    required this.labelBuilder,
    this.moduleIdentifier,
  });

  final String iconEmoji;
  final LocalizedTextBuilder labelBuilder;

  /// The module whose switch shows or hides the tab; `null` for the shell's
  /// own tabs, which are always there.
  final String? moduleIdentifier;
}

/// Builds the single router of the app from module contributions (decision D8).
///
/// Tabs keep their own navigation stacks through a [StatefulShellRoute]:
/// Home, one tab per storage domain, Lists and More (architecture 10.7).
/// Every registered domain gets a branch; the navigation bar hides those
/// switched off, so a switch takes effect without rebuilding the router.
/// Module routes outside the tabs open full screen on top.
GoRouter buildApplicationRouter({
  required List<FeatureModule> registeredModules,
  String? initialLocation,
}) {
  final domainTabModules =
      registeredModules.where((module) => module.navigationDestination != null).toList()..sort(
        (first, second) => first.navigationDestination!.sortOrder.compareTo(
          second.navigationDestination!.sortOrder,
        ),
      );

  final resolvedDestinations = [
    ResolvedNavigationDestination(
      iconEmoji: '🏠',
      labelBuilder: (context) => ApplicationShellLocalizations.of(context).navigationHome,
    ),
    for (final module in domainTabModules)
      ResolvedNavigationDestination(
        iconEmoji: module.navigationDestination!.iconEmoji,
        labelBuilder: module.navigationDestination!.labelBuilder,
        moduleIdentifier: module.moduleIdentifier,
      ),
    ResolvedNavigationDestination(
      iconEmoji: '📝',
      labelBuilder: (context) => ApplicationShellLocalizations.of(context).navigationLists,
    ),
    ResolvedNavigationDestination(
      iconEmoji: '🗂️',
      labelBuilder: (context) => ApplicationShellLocalizations.of(context).navigationMore,
    ),
  ];

  /// A link into a switched-off domain tab opens Home instead.
  String? redirectFromSwitchedOffTabs(BuildContext context, GoRouterState state) {
    final enabledModules = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(enabledFeatureModulesProvider).value;
    if (enabledModules == null) return null;
    final path = state.uri.path;
    for (final module in domainTabModules) {
      final tabPath = module.navigationDestination!.initialLocation;
      final isInTab = path == tabPath || path.startsWith('$tabPath/');
      if (isInTab && !enabledModules.contains(module)) return ShellRoutePaths.home;
    }
    return null;
  }

  return GoRouter(
    initialLocation: initialLocation ?? ShellRoutePaths.home,
    redirect: redirectFromSwitchedOffTabs,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ApplicationNavigationScaffold(
          navigationShell: navigationShell,
          destinations: resolvedDestinations,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ShellRoutePaths.home,
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          for (final module in domainTabModules)
            StatefulShellBranch(
              initialLocation: module.navigationDestination!.initialLocation,
              routes: module.navigationDestination!.routes,
            ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ShellRoutePaths.lists,
                builder: (context, state) =>
                    ListsScreen(initialSegmentIdentifier: state.uri.queryParameters['segment']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: ShellRoutePaths.more, builder: (context, state) => const MoreScreen()),
              for (final module in registeredModules)
                for (final entry in module.moreEntries) ...entry.routes,
            ],
          ),
        ],
      ),
      for (final module in registeredModules) ...module.buildRoutes(),
    ],
  );
}
