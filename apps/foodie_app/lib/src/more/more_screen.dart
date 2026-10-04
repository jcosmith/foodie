import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/application_shell_localizations.dart';

/// The More tab (UI example phone 16): Statistics, Options and whatever
/// future modules add, opened inside the tab.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ApplicationShellLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final entries = [
      for (final module
          in ref.watch(enabledFeatureModulesProvider).value ?? const <FeatureModule>[])
        ...module.moreEntries,
    ]..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));

    return Scaffold(
      appBar: AppBar(title: Text(localizations.moreTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: FoodieSpacing.small),
        children: [
          for (final entry in entries)
            ListTile(
              key: ValueKey(entry.identifier),
              leading: ColourTabIcon(emoji: entry.iconEmoji, size: 28),
              title: Text(entry.titleBuilder(context)),
              subtitle: Text(entry.subtitleBuilder(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(entry.location),
            ),
          const Divider(height: FoodieSpacing.extraLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FoodieSpacing.screenGutter),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: FoodieSpacing.small),
                Expanded(child: Text(localizations.privacyPromise, style: textTheme.bodyMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
