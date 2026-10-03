import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../home/home_dashboard_screen.dart';
import '../l10n/generated/application_shell_localizations.dart';
import 'application_navigation_scaffold.dart';

/// One tab of the bottom navigation, after sorting.
final class ResolvedNavigationDestination {
  const ResolvedNavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.labelBuilder,
  });

  final IconData icon;
  final IconData selectedIcon;
  final LocalizedTextBuilder labelBuilder;
}

/// Builds the single router of the app from module contributions (decision D8).
///
/// Tabs keep their own navigation stacks through a [StatefulShellRoute];
/// module routes outside the tabs open full screen on top.
GoRouter buildApplicationRouter({
  required List<FeatureModule> registeredModules,
  String? initialLocation,
}) {
  final destinationContributions =
      registeredModules.map((module) => module.navigationDestination).nonNulls.toList()
        ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));

  final resolvedDestinations = [
    ResolvedNavigationDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      labelBuilder: (context) => ApplicationShellLocalizations.of(context).navigationHome,
    ),
    for (final contribution in destinationContributions)
      ResolvedNavigationDestination(
        icon: contribution.icon,
        selectedIcon: contribution.selectedIcon,
        labelBuilder: contribution.labelBuilder,
      ),
  ];

  return GoRouter(
    initialLocation: initialLocation ?? ShellRoutePaths.home,
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
          for (final contribution in destinationContributions)
            StatefulShellBranch(
              initialLocation: contribution.initialLocation,
              routes: contribution.routes,
            ),
        ],
      ),
      for (final module in registeredModules) ...module.buildRoutes(),
    ],
  );
}
