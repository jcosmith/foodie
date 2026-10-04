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
    final labels = [
      for (final branchIndex in visibleBranches) destinations[branchIndex].labelBuilder(context),
    ];
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: _labelTextScaler(context, labels, constraints.maxWidth)),
          child: NavigationBar(
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
              for (final (index, branchIndex) in visibleBranches.indexed)
                NavigationDestination(
                  icon: ColourTabIcon(emoji: destinations[branchIndex].iconEmoji),
                  label: labels[index],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// The navigation bar wraps a label that is wider than its tab, which
  /// happens with seven tabs on a narrow phone. The labels shrink just
  /// enough to stay on one line instead; tab icons do not scale.
  static TextScaler _labelTextScaler(BuildContext context, List<String> labels, double width) {
    // The navigation bar never scales its labels beyond this.
    const maximumLabelScale = 1.3;
    final systemScaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: maximumLabelScale);
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium!.merge(
      theme.navigationBarTheme.labelTextStyle?.resolve({WidgetState.selected}),
    );
    final fontSize = style.fontSize ?? 12;
    final availableWidth = width / labels.length - 4;
    var widestLabel = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        textScaler: systemScaler,
        maxLines: 1,
      )..layout();
      if (painter.width > widestLabel) widestLabel = painter.width;
      painter.dispose();
    }
    if (widestLabel <= availableWidth || availableWidth <= 0) return systemScaler;
    final scale = systemScaler.scale(fontSize) / fontSize * availableWidth / widestLabel;
    return TextScaler.linear(scale);
  }
}
