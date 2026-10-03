/// Helpers for widget tests of feature packages.
library;

import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core_design_system.dart';

/// A [MaterialApp] with the app's theme, both supported languages and the
/// given feature localization delegates, showing [home] in [locale].
Widget buildLocalizedTestApplication({
  required Widget home,
  required List<LocalizationsDelegate<Object>> featureLocalizationDelegates,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  locale: locale,
  theme: FreezerTheme.light(),
  supportedLocales: SupportedLocales.all,
  localizationsDelegates: _localizationDelegates(featureLocalizationDelegates),
  home: home,
);

/// Like [buildLocalizedTestApplication], with a router instead of a home
/// screen, for tests that need the app's nested navigators.
Widget buildLocalizedTestRouterApplication({
  required RouterConfig<Object> routerConfig,
  required List<LocalizationsDelegate<Object>> featureLocalizationDelegates,
  Locale locale = const Locale('en'),
}) => MaterialApp.router(
  locale: locale,
  theme: FreezerTheme.light(),
  supportedLocales: SupportedLocales.all,
  localizationsDelegates: _localizationDelegates(featureLocalizationDelegates),
  routerConfig: routerConfig,
);

List<LocalizationsDelegate<dynamic>> _localizationDelegates(
  List<LocalizationsDelegate<Object>> featureLocalizationDelegates,
) => [
  ...GlobalMaterialLocalizations.delegates,
  CommonLocalizations.delegate,
  ...featureLocalizationDelegates,
];
