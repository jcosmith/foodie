import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Changes the app-wide settings of the Config tab. The shell applies them
/// as soon as they are stored, without a restart.
final class ApplicationSettings {
  const ApplicationSettings({
    required PreferencesStore preferencesStore,
    required ModuleEnablementStore moduleEnablementStore,
  }) : _preferencesStore = preferencesStore,
       _moduleEnablementStore = moduleEnablementStore;

  final PreferencesStore _preferencesStore;
  final ModuleEnablementStore _moduleEnablementStore;

  /// A supported language code, or empty to follow the phone.
  Future<void> chooseLanguage(String languageCode) =>
      _preferencesStore.write(ApplicationPreferenceKeys.languageCode, languageCode);

  Future<void> chooseTheme(ThemeChoice themeChoice) =>
      _preferencesStore.write(ApplicationPreferenceKeys.themeChoice, themeChoice);

  Future<void> switchOptionalFeature(FeatureModule module, {required bool isEnabled}) {
    assert(module.availability.isOptional, '${module.moduleIdentifier} cannot be switched off');
    return _moduleEnablementStore.setModuleEnabled(module, isEnabled: isEnabled);
  }
}

final applicationSettingsProvider = Provider<ApplicationSettings>(
  (ref) => ApplicationSettings(
    preferencesStore: ref.watch(preferencesStoreProvider),
    moduleEnablementStore: ref.watch(moduleEnablementStoreProvider),
  ),
);
