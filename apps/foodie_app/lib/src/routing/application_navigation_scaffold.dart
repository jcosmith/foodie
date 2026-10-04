import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'application_router.dart';

/// The bottom navigation bar: Home, the domain tabs that are switched on,
/// Lists and More, each with a colour icon and a one-word label.
class ApplicationNavigationScaffold extends ConsumerWidget {
  const ApplicationNavigationScaffold({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// One per branch of [navigationShell], in branch order.
  final List<ResolvedNavigationDestination> destinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledIdentifiers = {
      for (final module
          in ref.watch(enabledFeatureModulesProvider).value ?? const <FeatureModule>[])
        module.moduleIdentifier,
    };
    final visibleBranches = [
      for (final (branchIndex, destination) in destinations.indexed)
        if (destination.moduleIdentifier == null ||
            enabledIdentifiers.contains(destination.moduleIdentifier))
          branchIndex,
    ];
    final selectedIndex = visibleBranches.indexOf(navigationShell.currentIndex);
    if (selectedIndex < 0) {
      // The open tab was just switched off elsewhere: go Home.
      WidgetsBinding.instance.addPostFrameCallback((_) => navigationShell.goBranch(0));
    }
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (selectedIndex) {
          final branchIndex = visibleBranches[selectedIndex];
          navigationShell.goBranch(
            branchIndex,
            // Tapping the current tab again returns to its first screen.
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final branchIndex in visibleBranches)
            NavigationDestination(
              icon: ColourTabIcon(emoji: destinations[branchIndex].iconEmoji),
              label: destinations[branchIndex].labelBuilder(context),
            ),
        ],
      ),
    );
  }
}
