import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'application_router.dart';

/// The bottom navigation bar around the five tabs.
class ApplicationNavigationScaffold extends StatelessWidget {
  const ApplicationNavigationScaffold({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<ResolvedNavigationDestination> destinations;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (selectedIndex) => navigationShell.goBranch(
        selectedIndex,
        // Tapping the current tab again returns to its first screen.
        initialLocation: selectedIndex == navigationShell.currentIndex,
      ),
      destinations: [
        for (final destination in destinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: destination.labelBuilder(context),
          ),
      ],
    ),
  );
}
