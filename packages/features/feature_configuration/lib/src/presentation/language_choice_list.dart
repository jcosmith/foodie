import 'package:core_localization/core_localization.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/application_settings.dart';
import '../l10n/generated/configuration_localizations.dart';

/// "System language" plus every supported language, each written in its own
/// language (decision D14). Choosing one applies it at once. Also shown on
/// the first onboarding screen.
class LanguageChoiceList extends ConsumerWidget {
  const LanguageChoiceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ConfigurationLocalizations.of(context);
    final chosenLanguageCode = ref.watch(languageCodeChoiceProvider).value ?? '';
    final phoneLocale = SupportedLocales.resolve(
      WidgetsBinding.instance.platformDispatcher.locales,
    );
    final phoneLanguageName =
        SupportedLocales.languageNamesInOwnLanguage[phoneLocale.languageCode] ??
        phoneLocale.languageCode;
    return RadioGroup<String>(
      groupValue: chosenLanguageCode,
      onChanged: (languageCode) {
        if (languageCode != null) {
          ref.read(applicationSettingsProvider).chooseLanguage(languageCode);
        }
      },
      child: Column(
        children: [
          RadioListTile<String>(
            value: '',
            title: Text(localizations.systemLanguage),
            subtitle: Text(localizations.systemLanguageDetail(phoneLanguageName)),
          ),
          for (final MapEntry(key: languageCode, value: languageName)
              in SupportedLocales.languageNamesInOwnLanguage.entries)
            RadioListTile<String>(
              value: languageCode,
              // Spoken by screen readers in that language.
              title: Text(languageName, locale: Locale(languageCode)),
            ),
        ],
      ),
    );
  }
}
