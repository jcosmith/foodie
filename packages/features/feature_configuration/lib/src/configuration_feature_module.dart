import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'l10n/generated/configuration_localizations.dart';
import 'presentation/configuration_screen.dart';
import 'presentation/configuration_sections.dart';
import 'presentation/language_choice_list.dart';

/// Options in the More tab (decision D14, architecture sections 10.5 and
/// 10.7). Holds the tab switches, language, appearance, optional features
/// and about; every other module adds its own sections.
final class ConfigurationFeatureModule extends FeatureModuleBase {
  const ConfigurationFeatureModule();

  static const String identifier = 'configuration';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    ConfigurationLocalizations.delegate,
  ];

  @override
  List<MoreEntryContribution> get moreEntries => [
    MoreEntryContribution(
      identifier: '$identifier.options',
      sortOrder: 20,
      iconEmoji: '⚙️',
      titleBuilder: (context) => ConfigurationLocalizations.of(context).screenTitle,
      subtitleBuilder: (context) => ConfigurationLocalizations.of(context).moreEntrySubtitle,
      location: '/$identifier',
      routes: [
        GoRoute(path: '/$identifier', builder: (context, state) => const ConfigurationScreen()),
      ],
    ),
  ];

  @override
  List<ConfigSectionContribution> get configSections => [
    ConfigSectionContribution(
      identifier: '$identifier.language',
      sortOrder: 10,
      titleBuilder: (context) => ConfigurationLocalizations.of(context).languageSectionTitle,
      builder: (context) => const LanguageChoiceList(),
    ),
    ConfigSectionContribution(
      identifier: '$identifier.appearance',
      sortOrder: 30,
      titleBuilder: (context) => ConfigurationLocalizations.of(context).appearanceSectionTitle,
      builder: (context) => const AppearanceConfigSection(),
    ),
    ConfigSectionContribution(
      identifier: '$identifier.about',
      sortOrder: 80,
      titleBuilder: (context) => ConfigurationLocalizations.of(context).aboutSectionTitle,
      builder: (context) => const AboutConfigSection(),
    ),
  ];
}
