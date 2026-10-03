import 'package:flutter/widgets.dart';

/// The languages the app ships with. English is the fallback.
///
/// Adding a language means adding ARB files in every package and one entry
/// here; the Config tab lists languages from [languageNamesInOwnLanguage].
abstract final class SupportedLocales {
  static const Locale english = Locale('en');
  static const Locale german = Locale('de');

  static const Locale fallback = english;

  static const List<Locale> all = [english, german];

  /// Each language written in itself, so it can be found even when the app
  /// is set to a language the user cannot read (decision D14).
  static const Map<String, String> languageNamesInOwnLanguage = {'en': 'English', 'de': 'Deutsch'};

  /// The supported locale for a language code chosen in the app, or `null`
  /// for an empty or unsupported code (the app then follows the phone).
  static Locale? forLanguageCode(String languageCode) {
    for (final supportedLocale in all) {
      if (supportedLocale.languageCode == languageCode) return supportedLocale;
    }
    return null;
  }

  /// Picks the best supported locale for the device's preferred locales.
  static Locale resolve(List<Locale>? preferredLocales) {
    for (final preferredLocale in preferredLocales ?? const <Locale>[]) {
      for (final supportedLocale in all) {
        if (supportedLocale.languageCode == preferredLocale.languageCode) {
          return supportedLocale;
        }
      }
    }
    return fallback;
  }
}
