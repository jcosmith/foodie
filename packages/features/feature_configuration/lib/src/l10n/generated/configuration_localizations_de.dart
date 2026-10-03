// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'configuration_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ConfigurationLocalizationsDe extends ConfigurationLocalizations {
  ConfigurationLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navigationLabel => 'Konfig.';

  @override
  String get screenTitle => 'Konfiguration';

  @override
  String get languageSectionTitle => 'Sprache';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String systemLanguageDetail(String languageName) {
    return 'Wie das Telefon: $languageName';
  }

  @override
  String get appearanceSectionTitle => 'Darstellung';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get textSizeHint => 'Die Schriftgröße folgt den Einstellungen deines Telefons.';

  @override
  String get optionalFeaturesSectionTitle => 'Optionale Funktionen';

  @override
  String get aboutSectionTitle => 'Über und Datenschutz';

  @override
  String get privacyStatementTitle => 'Deine Daten verlassen nie dieses Telefon';

  @override
  String get privacyStatementMessage =>
      'Kein Konto, keine Cloud, kein Tracking. Die App hat überhaupt keinen Internetzugang. Sicherungen landen nur dort, wo du sie selbst speicherst.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get licencesButton => 'Open-Source-Lizenzen';
}
