import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_events/core_events.dart';
import 'package:core_events/event_bus_provider.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:feature_onboarding/src/application/onboarding_completion.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

final class _EnglishLayoutDefaultNames implements LayoutDefaultNames {
  const _EnglishLayoutDefaultNames();

  @override
  String storagePlaceName(StorageKind storageKind) => 'Freezer';

  @override
  String compartmentName(StorageKind storageKind, int number) => 'Drawer $number';

  @override
  String removedName(String name) => '$name (removed)';
}

final class _ContainerInitializationContext implements ModuleInitializationContext {
  _ContainerInitializationContext(this._container);

  final ProviderContainer _container;

  @override
  Clock get clock => _container.read(clockProvider);

  @override
  DomainEventBus get domainEventBus => _container.read(domainEventBusProvider);

  @override
  LocalLogger get logger => RecordingLogger();

  @override
  TValue read<TValue>(ProviderListenable<TValue> provider) => _container.read(provider);
}

void main() {
  late ApplicationDatabase database;
  late ProviderContainer container;

  setUp(() {
    final clock = FixedClock(DateTime.utc(2026, 10, 2));
    database = createInMemoryApplicationDatabase(clock: clock);
    final dependencies = ModuleDependencies(
      clock: clock,
      identifierGenerator: SequentialIdentifierGenerator(),
      domainEventBus: InProcessDomainEventBus(logger: RecordingLogger()),
      logger: RecordingLogger(),
    );
    container = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(clock),
        identifierGeneratorProvider.overrideWithValue(dependencies.identifierGenerator),
        domainEventBusProvider.overrideWithValue(dependencies.domainEventBus),
        ...const StorageLayoutFeatureModule().buildProviderOverrides(dependencies),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<String?> launchRoutePath() => const OnboardingFeatureModule().resolveLaunchRoutePath(
    _ContainerInitializationContext(container),
  );

  test('opens onboarding until it is completed', () async {
    expect(await launchRoutePath(), '/onboarding');

    await container
        .read(completeOnboardingUseCaseProvider)
        .execute(
          storageTemplate: StorageTemplate.uprightWithFiveDrawers,
          defaultNames: const _EnglishLayoutDefaultNames(),
        );

    expect(await launchRoutePath(), isNull);
    expect(
      await container.read(preferencesStoreProvider).read(OnboardingPreferenceKeys.isCompleted),
      isTrue,
    );
    final layout = await container.read(storageLayoutQueryServiceProvider).readStorageLayout();
    expect(layout.storagePlaces.single.compartments, hasLength(5));
  });

  test('never adds a second freezer', () async {
    final completeOnboarding = container.read(completeOnboardingUseCaseProvider);
    for (final template in [
      StorageTemplate.chestWithBaskets,
      StorageTemplate.uprightWithThreeDrawers,
    ]) {
      await completeOnboarding.execute(
        storageTemplate: template,
        defaultNames: const _EnglishLayoutDefaultNames(),
      );
    }

    final layout = await container.read(storageLayoutQueryServiceProvider).readStorageLayout();
    expect(layout.storagePlaces, hasLength(1));
    expect(layout.storagePlaces.single.storagePlace.storageKind, StorageKind.chest);
  });
}
