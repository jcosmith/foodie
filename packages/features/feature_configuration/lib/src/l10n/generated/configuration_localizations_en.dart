// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'configuration_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ConfigurationLocalizationsEn extends ConfigurationLocalizations {
  ConfigurationLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationLabel => 'Config';

  @override
  String get screenTitle => 'Config';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get systemLanguage => 'System language';

  @override
  String systemLanguageDetail(String languageName) {
    return 'Follows your phone: $languageName';
  }

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get textSizeHint => 'Text size follows your phone\'s settings.';

  @override
  String get optionalFeaturesSectionTitle => 'Optional features';

  @override
  String get aboutSectionTitle => 'About and privacy';

  @override
  String get privacyStatementTitle => 'Your data never leaves this phone';

  @override
  String get privacyStatementMessage =>
      'No account, no cloud, no tracking. The app has no internet access at all. Backups go only where you save them yourself.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get licencesButton => 'Open-source licences';
}
