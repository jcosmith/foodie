import 'package:core_preferences/core_preferences.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class OnboardingPreferenceKeys {
  /// Set once the user finished onboarding; restored with a backup.
  static final PreferenceKey<bool> isCompleted = PreferenceKey.boolean(
    moduleNamespace: 'onboarding',
    name: 'is_completed',
    defaultValue: false,
  );
}

/// Finishes onboarding: creates the freezer the user picked (if they had
/// none yet) and remembers that onboarding is done.
final class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase({
    required PreferencesStore preferencesStore,
    required CreateFreezerFromTemplateUseCase createFreezerFromTemplate,
    required StorageLayoutQueryService storageLayout,
  }) : _preferencesStore = preferencesStore,
       _createFreezerFromTemplate = createFreezerFromTemplate,
       _storageLayout = storageLayout;

  final PreferencesStore _preferencesStore;
  final CreateFreezerFromTemplateUseCase _createFreezerFromTemplate;
  final StorageLayoutQueryService _storageLayout;

  Future<void> execute({
    required FreezerTemplate? freezerTemplate,
    required LayoutDefaultNames defaultNames,
  }) async {
    final layout = await _storageLayout.readStorageLayout();
    if (freezerTemplate != null && !layout.hasFreezer) {
      // A template with the default name cannot fail validation.
      await _createFreezerFromTemplate.execute(
        template: freezerTemplate,
        defaultNames: defaultNames,
      );
    }
    await _preferencesStore.write(OnboardingPreferenceKeys.isCompleted, true);
  }
}

final completeOnboardingUseCaseProvider = Provider<CompleteOnboardingUseCase>(
  (ref) => CompleteOnboardingUseCase(
    preferencesStore: ref.watch(preferencesStoreProvider),
    createFreezerFromTemplate: ref.watch(createFreezerFromTemplateUseCaseProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
  ),
);
