import 'dart:async';

import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:feature_configuration/feature_configuration.dart';
import 'package:feature_configuration/src/presentation/configuration_screen.dart';
import 'package:flutter/material.dart';
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

/// A storage domain whose module is the switch of its tab.
final class _DomainModule extends FeatureModuleBase {
  const _DomainModule(this.moduleIdentifier, this.label, this.emoji, this.sortOrder);

  @override
  final String moduleIdentifier;
  final String label;
  final String emoji;
  final int sortOrder;

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: true);

  @override
  OptionalFeatureDescription get optionalFeatureDescription => OptionalFeatureDescription(
    titleBuilder: (context) => label,
    detailBuilder: (context) => '$label things',
  );

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: StorageDomainIdentifier(moduleIdentifier),
    sortOrder: sortOrder,
    iconEmoji: emoji,
    labelBuilder: (context) => label,
    descriptionBuilder: (context) => '$label things',
    storedOnLabelBuilder: (context) => 'Stored on',
    countsDiscardsAsWaste: true,
  );
}

final class _InMemoryModuleEnablementStore implements ModuleEnablementStore {
  final Set<String> _enabledIdentifiers = {'cold', 'shelf'};
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
          _DomainModule('shelf', 'Shelf', '🥫', 30),
          _DomainModule('cold', 'Cold', '❄️', 10),
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

    expect(find.text('Options'), findsOneWidget);
    final sectionTitles = [
      'Tabs',
      'Language',
      'Appearance',
      'Optional features',
      'About and privacy',
    ];
    final positions = [
      for (final title in sectionTitles)
        tester.getTopLeft(find.text(title, skipOffstage: false)).dy,
    ];
    expect(positions, [...positions]..sort());
  });

  testWidgets('stores the language and theme choices', (tester) async {
    await showConfiguration(tester);

    await tester.scrollUntilVisible(find.text('Deutsch'), 200);
    await tester.tap(find.text('Deutsch'));
    await _settle(tester);
    await tester.scrollUntilVisible(find.text('Dark'), 200);
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

  testWidgets('every storage domain has a tab switch, in tab order, outside the features', (
    tester,
  ) async {
    await showConfiguration(tester);

    final coldSwitch = find.widgetWithText(SwitchListTile, 'Cold');
    final shelfSwitch = find.widgetWithText(SwitchListTile, 'Shelf');
    expect(tester.getTopLeft(coldSwitch).dy, lessThan(tester.getTopLeft(shelfSwitch).dy));
    expect(find.text('Shelf things'), findsOneWidget);
    expect(shelfSwitch, findsOneWidget, reason: 'a tab, not also an optional feature');
    expect(find.descendant(of: coldSwitch, matching: find.byType(ColourTabIcon)), findsOneWidget);

    await tester.tap(shelfSwitch);
    await _settle(tester);
    final enabledModules = container.read(enabledFeatureModulesProvider).value!;
    expect(enabledModules.map((module) => module.moduleIdentifier), isNot(contains('shelf')));
  });

  testWidgets('the last tab that is on cannot be switched off', (tester) async {
    await showConfiguration(tester);
    expect(find.text('At least one tab stays on.'), findsNothing);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Shelf'));
    await _settle(tester);

    final coldSwitch = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Cold'));
    expect(coldSwitch.value, isTrue);
    expect(coldSwitch.onChanged, isNull);
    expect(find.text('At least one tab stays on.'), findsOneWidget);
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
