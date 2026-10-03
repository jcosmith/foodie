import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/application_shell_localizations.dart';

/// The Home tab: answers "what should I eat first?" with cards contributed by
/// the enabled modules (reminders, restock, statistics).
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ApplicationShellLocalizations.of(context);
    final enabledModules = ref.watch(enabledFeatureModulesProvider).value ?? const [];
    final dashboardCards = [
      for (final module in enabledModules)
        for (final card in module.dashboardCards)
          if (card.isVisible == null || ref.watch(card.isVisible!)) card,
    ]..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
    final quickActions = [for (final module in enabledModules) ...module.quickActions]
      ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
    final currentHour = ref.watch(clockProvider).nowLocal().hour;

    return Scaffold(
      appBar: AppBar(title: Text(_greeting(localizations, currentHour))),
      floatingActionButton: quickActions.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => quickActions.length == 1
                  ? quickActions.single.onSelected(context)
                  : _showQuickActionMenu(context, quickActions),
              icon: const Icon(Icons.add),
              label: Text(
                quickActions.length == 1
                    ? quickActions.single.labelBuilder(context)
                    : localizations.quickActionsMenuTitle,
              ),
            ),
      body: dashboardCards.isEmpty
          ? EmptyStateView(
              icon: Icons.kitchen_outlined,
              title: localizations.homeDashboardEmptyTitle,
              message: localizations.homeDashboardEmptyMessage,
            )
          : ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                FreezerSpacing.screenGutter,
                0,
                FreezerSpacing.screenGutter,
                96,
              ),
              children: [
                for (final card in dashboardCards)
                  Padding(
                    key: ValueKey(card.identifier),
                    padding: const EdgeInsets.only(bottom: FreezerSpacing.medium),
                    child: card.builder(context),
                  ),
              ],
            ),
    );
  }

  static String _greeting(ApplicationShellLocalizations localizations, int hour) => switch (hour) {
    < 12 => localizations.homeGreetingMorning,
    < 18 => localizations.homeGreetingAfternoon,
    _ => localizations.homeGreetingEvening,
  };

  static Future<void> _showQuickActionMenu(
    BuildContext context,
    List<QuickActionContribution> quickActions,
  ) => showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final quickAction in quickActions)
            ListTile(
              leading: Icon(quickAction.icon),
              title: Text(quickAction.labelBuilder(sheetContext)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                quickAction.onSelected(context);
              },
            ),
        ],
      ),
    ),
  );
}
