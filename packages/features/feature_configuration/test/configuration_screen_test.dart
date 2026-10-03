import 'dart:async';

import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_configuration/feature_configuration.dart';
import 'package:feature_configuration/src/presentation/configuration_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _OptionalScanningModule extends FeatureModuleBase {
  const _OptionalScanningModule();

  @override
  String get moduleIdentifier => 'barcode_scanning';

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: false);

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => 'Barcode scanning',
    detailBuilder: (context) => 'Uses the camera, on this phone only',
  );
}

final class _InMemoryModuleEnablementStore implements ModuleEnablementStore {
  final Set<String> _enabledIdentifiers = {};
  final StreamController<Set<String>> _changes = StreamController.broadcast();

  @override
  Stream<Set<String>> watchEnabledOptionalModuleIdentifiers(List<FeatureModule> optionalModules) =>
      Stream.multi((controller) {
        controller.add(Set.of(_enabledIdentifiers));
        final subscription = _changes.stream.listen(controller.add);
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<void> setModuleEnabled(FeatureModule module, {required bool isEnabled}) async {
    isEnabled
        ? _enabledIdentifiers.add(module.moduleIdentifier)
        : _enabledIdentifiers.remove(module.moduleIdentifier);
    _changes.add(Set.of(_enabledIdentifiers));
  }
}

void main() {
  late ApplicationDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = createInMemoryApplicationDatabase();
    container = ProviderContainer(
      overrides: [
        applicationDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(FixedClock(DateTime.utc(2026, 10, 2))),
        registeredFeatureModulesProvider.overrideWithValue(const [
          ConfigurationFeatureModule(),
          _OptionalScanningModule(),
        ]),
        moduleEnablementStoreProvider.overrideWithValue(_InMemoryModuleEnablementStore()),
        applicationVersionProvider.overrideWithValue('1.2.3'),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<void> showConfiguration(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: buildLocalizedTestApplication(
          featureLocalizationDelegates: const ConfigurationFeatureModule().localizationDelegates,
          home: const ConfigurationScreen(),
        ),
      ),
    );
    await _settle(tester);
  }

  testWidgets('lists the sections in the documented order', (tester) async {
    await showConfiguration(tester);

    final sectionTitles = ['Language', 'Appearance', 'Optional features', 'About and privacy'];
    final positions = [
      for (final title in sectionTitles)
        tester.getTopLeft(find.text(title, skipOffstage: false)).dy,
    ];
    expect(positions, [...positions]..sort());
  });

  testWidgets('stores the language and theme choices', (tester) async {
    await showConfiguration(tester);

    await tester.tap(find.text('Deutsch'));
    await _settle(tester);
    await tester.tap(find.text('Dark'));
    await _settle(tester);

    final preferencesStore = container.read(preferencesStoreProvider);
    expect(
      await tester.runAsync(() => preferencesStore.read(ApplicationPreferenceKeys.languageCode)),
      'de',
    );
    expect(
      await tester.runAsync(() => preferencesStore.read(ApplicationPreferenceKeys.themeChoice)),
      ThemeChoice.dark,
    );
  });

  testWidgets('switches an optional feature on', (tester) async {
    await showConfiguration(tester);
    await tester.scrollUntilVisible(find.text('Barcode scanning'), 200);

    await tester.tap(find.text('Barcode scanning'));
    await _settle(tester);

    final enabledModules = container.read(enabledFeatureModulesProvider).value!;
    expect(enabledModules.map((module) => module.moduleIdentifier), contains('barcode_scanning'));
    expect(find.text('Version 1.2.3', skipOffstage: false), findsOneWidget);
  });
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
}
