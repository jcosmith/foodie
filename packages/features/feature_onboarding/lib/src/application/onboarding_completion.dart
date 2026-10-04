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

/// Finishes onboarding: creates the storage place the user picked (if they had
/// none yet) and remembers that onboarding is done.
final class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase({
    required PreferencesStore preferencesStore,
    required CreateStoragePlaceFromTemplateUseCase createStoragePlaceFromTemplate,
    required StorageLayoutQueryService storageLayout,
  }) : _preferencesStore = preferencesStore,
       _createStoragePlaceFromTemplate = createStoragePlaceFromTemplate,
       _storageLayout = storageLayout;

  final PreferencesStore _preferencesStore;
  final CreateStoragePlaceFromTemplateUseCase _createStoragePlaceFromTemplate;
  final StorageLayoutQueryService _storageLayout;

  Future<void> execute({
    required StorageTemplate? storageTemplate,
    required LayoutDefaultNames defaultNames,
  }) async {
    final layout = await _storageLayout.readStorageLayout();
    if (storageTemplate != null && !layout.hasStoragePlace) {
      // A template with the default name cannot fail validation.
      await _createStoragePlaceFromTemplate.execute(
        template: storageTemplate,
        defaultNames: defaultNames,
      );
    }
    await _preferencesStore.write(OnboardingPreferenceKeys.isCompleted, true);
  }
}

final completeOnboardingUseCaseProvider = Provider<CompleteOnboardingUseCase>(
  (ref) => CompleteOnboardingUseCase(
    preferencesStore: ref.watch(preferencesStoreProvider),
    createStoragePlaceFromTemplate: ref.watch(createStoragePlaceFromTemplateUseCaseProvider),
    storageLayout: ref.watch(storageLayoutQueryServiceProvider),
  ),
);
