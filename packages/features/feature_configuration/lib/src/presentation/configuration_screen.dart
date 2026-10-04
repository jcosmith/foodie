import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/configuration_localizations.dart';
import 'configuration_sections.dart';

/// Sort order of the "Tabs" section, first (UI example phone 17).
const int tabsSectionSortOrder = 5;

/// Sort order of the "Optional features" section (architecture document,
/// section 10.5).
const int optionalFeaturesSectionSortOrder = 60;

/// Options in the More tab (UI example phones 10 and 17): the tab switches,
/// then the sections of every enabled module in the documented order.
class ConfigurationScreen extends ConsumerWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ConfigurationLocalizations.of(context);
    final enabledModules = ref.watch(enabledFeatureModulesProvider).value ?? const [];
    final registeredModules = ref.watch(registeredFeatureModulesProvider);
    final domainModules =
        [
          for (final module in registeredModules)
            if (module.storageDomain != null && module.availability.isOptional) module,
        ]..sort(
          (first, second) =>
              first.storageDomain!.sortOrder.compareTo(second.storageDomain!.sortOrder),
        );
    final optionalModules = [
      for (final module in registeredModules)
        if (module.availability.isOptional && module.storageDomain == null) module,
    ];
    final configSections = [
      for (final module in enabledModules) ...module.configSections,
      if (domainModules.isNotEmpty)
        ConfigSectionContribution(
          identifier: 'configuration.tabs',
          sortOrder: tabsSectionSortOrder,
          titleBuilder: (context) => ConfigurationLocalizations.of(context).tabsSectionTitle,
          builder: (context) => TabsConfigSection(domainModules: domainModules),
        ),
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
        padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
        children: [
          for (final configSection in configSections)
            Padding(
              key: ValueKey(configSection.identifier),
              padding: const EdgeInsets.only(bottom: FoodieSpacing.medium),
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
