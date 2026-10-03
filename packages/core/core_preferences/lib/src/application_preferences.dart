import 'package:riverpod/riverpod.dart';

import 'preference_key.dart';
import 'preferences_providers.dart';

/// Light or dark colours, or whatever the phone uses.
enum ThemeChoice { system, light, dark }

/// App-wide settings that the shell applies and that both onboarding and the
/// Config tab change, so there is one source of truth (architecture
/// document, section 10.5).
abstract final class ApplicationPreferenceKeys {
  static const String namespace = 'application';

  /// A supported language code such as `de`, or empty to follow the phone.
  static final PreferenceKey<String> languageCode = PreferenceKey.text(
    moduleNamespace: namespace,
    name: 'language_code',
    defaultValue: '',
  );

  static final PreferenceKey<ThemeChoice> themeChoice = PreferenceKey.enumeration(
    moduleNamespace: namespace,
    name: 'theme_choice',
    defaultValue: ThemeChoice.system,
    values: ThemeChoice.values,
  );
}

/// The chosen language code, empty when the app follows the phone.
final languageCodeChoiceProvider = StreamProvider<String>(
  (ref) => ref.watch(preferencesStoreProvider).watch(ApplicationPreferenceKeys.languageCode),
);

final themeChoiceProvider = StreamProvider<ThemeChoice>(
  (ref) => ref.watch(preferencesStoreProvider).watch(ApplicationPreferenceKeys.themeChoice),
);
