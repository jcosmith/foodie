import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/configuration_localizations.dart';
import 'configuration_sections.dart';

/// Sort order of the "Optional features" section (architecture document,
/// section 10.5).
const int optionalFeaturesSectionSortOrder = 60;

/// The Config tab (UI example phone 10): the sections of every enabled
/// module in the documented order, language first.
class ConfigurationScreen extends ConsumerWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ConfigurationLocalizations.of(context);
    final enabledModules = ref.watch(enabledFeatureModulesProvider).value ?? const [];
    final optionalModules = [
      for (final module in ref.watch(registeredFeatureModulesProvider))
        if (module.availability.isOptional) module,
    ];
    final configSections = [
      for (final module in enabledModules) ...module.configSections,
      if (optionalModules.isNotEmpty)
        ConfigSectionContribution(
          identifier: 'configuration.optional_features',
          sortOrder: optionalFeaturesSectionSortOrder,
          titleBuilder: (context) =>
              ConfigurationLocalizations.of(context).optionalFeaturesSectionTitle,
          builder: (context) => OptionalFeaturesConfigSection(optionalModules: optionalModules),
        ),
    ]..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));

    return Scaffold(
      appBar: AppBar(title: Text(localizations.screenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(FreezerSpacing.screenGutter),
        children: [
          for (final configSection in configSections)
            Padding(
              key: ValueKey(configSection.identifier),
              padding: const EdgeInsets.only(bottom: FreezerSpacing.medium),
              child: SectionCard(
                title: configSection.titleBuilder(context),
                child: configSection.builder(context),
              ),
            ),
        ],
      ),
    );
  }
}
