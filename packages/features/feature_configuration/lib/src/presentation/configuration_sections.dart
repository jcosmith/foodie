import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/application_settings.dart';
import '../l10n/generated/configuration_localizations.dart';

/// System, light or dark colours.
class AppearanceConfigSection extends ConsumerWidget {
  const AppearanceConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ConfigurationLocalizations.of(context);
    final themeChoice = ref.watch(themeChoiceProvider).value ?? ThemeChoice.system;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ThemeChoice>(
          segments: [
            ButtonSegment(value: ThemeChoice.system, label: Text(localizations.themeSystem)),
            ButtonSegment(value: ThemeChoice.light, label: Text(localizations.themeLight)),
            ButtonSegment(value: ThemeChoice.dark, label: Text(localizations.themeDark)),
          ],
          selected: {themeChoice},
          onSelectionChanged: (selection) =>
              ref.read(applicationSettingsProvider).chooseTheme(selection.single),
        ),
        const SizedBox(height: FoodieSpacing.small),
        Text(localizations.textSizeHint, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// A switch for every optional module; switching one off removes its
/// contributions at once.
class OptionalFeaturesConfigSection extends ConsumerWidget {
  const OptionalFeaturesConfigSection({required this.optionalModules, super.key});

  final List<FeatureModule> optionalModules;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledModules = ref.watch(enabledFeatureModulesProvider).value ?? const [];
    return Column(
      children: [
        for (final module in optionalModules)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              module.optionalFeatureDescription?.titleBuilder(context) ?? module.moduleIdentifier,
            ),
            subtitle: switch (module.optionalFeatureDescription) {
              final description? => Text(description.detailBuilder(context)),
              null => null,
            },
            value: enabledModules.contains(module),
            onChanged: (isEnabled) => ref
                .read(applicationSettingsProvider)
                .switchOptionalFeature(module, isEnabled: isEnabled),
          ),
      ],
    );
  }
}

/// The privacy promise, the version and the open-source licences.
class AboutConfigSection extends ConsumerWidget {
  const AboutConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ConfigurationLocalizations.of(context);
    final applicationVersion = ref.watch(applicationVersionProvider);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: FoodieSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.privacyStatementTitle, style: textTheme.titleSmall),
                  const SizedBox(height: FoodieSpacing.extraSmall),
                  Text(localizations.privacyStatementMessage, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: FoodieSpacing.medium),
        Text(localizations.versionLabel(applicationVersion), style: textTheme.bodySmall),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () =>
              showLicensePage(context: context, applicationVersion: applicationVersion),
          child: Text(localizations.licencesButton),
        ),
      ],
    );
  }
}
