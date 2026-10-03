import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/generated/application_shell_localizations.dart';

/// Localization delegates every screen needs, before module delegates.
const List<LocalizationsDelegate<Object>> shellLocalizationDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  CommonLocalizations.delegate,
  ApplicationShellLocalizations.delegate,
];

/// The running app: themes, languages and the module-built router.
class FreezerApplication extends ConsumerWidget {
  const FreezerApplication({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registeredModules = ref.watch(registeredFeatureModulesProvider);
    final chosenLanguageCode = ref.watch(languageCodeChoiceProvider).value ?? '';
    final themeChoice = ref.watch(themeChoiceProvider).value ?? ThemeChoice.system;
    return MaterialApp.router(
      onGenerateTitle: (context) => ApplicationShellLocalizations.of(context).applicationTitle,
      routerConfig: router,
      theme: FreezerTheme.light(),
      darkTheme: FreezerTheme.dark(),
      themeMode: switch (themeChoice) {
        ThemeChoice.system => ThemeMode.system,
        ThemeChoice.light => ThemeMode.light,
        ThemeChoice.dark => ThemeMode.dark,
      },
      // `null` follows the phone through localeListResolutionCallback.
      locale: SupportedLocales.forLanguageCode(chosenLanguageCode),
      supportedLocales: SupportedLocales.all,
      localeListResolutionCallback: (preferredLocales, supportedLocales) =>
          SupportedLocales.resolve(preferredLocales),
      localizationsDelegates: [
        ...shellLocalizationDelegates,
        for (final module in registeredModules) ...module.localizationDelegates,
      ],
    );
  }
}
