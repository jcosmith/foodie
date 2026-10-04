import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_freezer/feature_freezer.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/storage_layout_test_harness.dart';

String _shelfName(BuildContext context, int number) => 'Shelf $number';

/// A pantry-like domain module for tests, so storage kinds of two domains
/// can be told apart without depending on the real pantry module.
final class _ShelvesModule extends FeatureModuleBase {
  const _ShelvesModule();

  @override
  String get moduleIdentifier => 'shelves';

  @override
  List<StorageKindContribution> get storageKinds => [
    StorageKindContribution(
      storageName: 'testCupboard',
      domainIdentifier: StorageDomainIdentifier.pantry,
      sortOrder: 300,
      iconEmoji: '🗄️',
      placeNameBuilder: (context) => 'Cupboard',
      kindDescriptionBuilder: (context) => 'cupboard',
      compartmentNameBuilder: _shelfName,
      compartmentCountBuilder: (context, count) => '$count shelves',
      addCompartmentLabelBuilder: (context) => 'Add shelf',
      templates: [
        StorageTemplateContribution(
          identifier: 'shelves.cupboard',
          sortOrder: 10,
          compartmentCount: 4,
          labelBuilder: (context) => 'Cupboard with 4 shelves',
        ),
      ],
    ),
  ];
}

void main() {
  test('a storage kind is a value named by its stored name', () {
    expect(const StorageKind('chest'), const StorageKind('chest'));
    expect(const StorageKind('chest').hashCode, const StorageKind('chest').hashCode);
    expect(const StorageKind('chest'), isNot(const StorageKind('upright')));
    expect(const StorageKind('chest').toString(), 'chest');
  });

  group('the layout knows the domain of every storage place', () {
    final createdAt = DateTime.utc(2026);
    StoragePlace place(String identifier, String storageName, int sortOrder) => StoragePlace(
      identifier: StoragePlaceIdentifier(identifier),
      storageKind: StorageKind(storageName),
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
    Compartment compartmentOf(StoragePlace storagePlace, int number) => Compartment(
      identifier: CompartmentIdentifier('${storagePlace.identifier.value}-$number'),
      storagePlaceIdentifier: storagePlace.identifier,
      defaultNumber: number,
      colorTagIndex: 0,
      sortOrder: number,
      createdAt: createdAt,
    );
    final freezer = place('freezer', 'upright', 0);
    final cupboard = place('cupboard', 'testCupboard', 1);
    final unknown = place('unknown', 'removedKind', 2);
    final layout = StorageLayout.fromEntities(
      storagePlacesIncludingArchived: [freezer, cupboard, unknown],
      compartmentsIncludingArchived: [
        compartmentOf(freezer, 1),
        compartmentOf(cupboard, 1),
        compartmentOf(cupboard, 2),
        compartmentOf(unknown, 1),
      ],
      domainOfStorageKind: const {
        StorageKind('upright'): StorageDomainIdentifier.freezer,
        StorageKind('testCupboard'): StorageDomainIdentifier.pantry,
      },
    );

    test('places are grouped by domain in the user order', () {
      expect(
        layout.storagePlacesIn(StorageDomainIdentifier.pantry).map((entry) => entry.storagePlace),
        [cupboard],
      );
      expect(
        layout.storagePlacesIn(StorageDomainIdentifier.freezer).map((entry) => entry.storagePlace),
        [freezer],
      );
      expect(layout.storagePlacesIn(StorageDomainIdentifier.household), isEmpty);
      expect(
        layout.storagePlaceLayoutOf(cupboard.identifier)!.domainIdentifier,
        StorageDomainIdentifier.pantry,
      );
    });

    test('compartments and places tell their domain; unknown kinds have none', () {
      expect(
        layout.domainOfCompartment(const CompartmentIdentifier('cupboard-2')),
        StorageDomainIdentifier.pantry,
      );
      expect(layout.domainOfStoragePlace(freezer.identifier), StorageDomainIdentifier.freezer);
      expect(layout.domainOfStoragePlace(unknown.identifier), isNull);
      expect(layout.domainOfCompartment(const CompartmentIdentifier('missing')), isNull);
      expect(
        layout.activeCompartmentsIn(StorageDomainIdentifier.pantry).map((c) => c.defaultNumber),
        [1, 2],
      );
    });
  });

  group('storage kinds and templates come from the registered modules', () {
    late StorageLayoutTestHarness harness;

    setUp(
      () => harness = StorageLayoutTestHarness(
        registeredModules: const [
          StorageLayoutFeatureModule(),
          FreezerFeatureModule(),
          _ShelvesModule(),
        ],
      ),
    );
    tearDown(() => harness.dispose());

    test('every template knows its kind, domain and compartment count', () {
      final cupboard = harness.template('shelves.cupboard');
      expect(cupboard.storageKind, const StorageKind('testCupboard'));
      expect(cupboard.domainIdentifier, StorageDomainIdentifier.pantry);
      expect(cupboard.compartmentCount, 4);
      expect(harness.template('freezer.chest_baskets').storageKind, const StorageKind('chest'));
    });

    test('templates can be listed for one domain', () {
      final pantryTemplates = harness.read(
        storageTemplatesOfDomainProvider(StorageDomainIdentifier.pantry),
      );
      expect(pantryTemplates.map((template) => template.identifier), ['shelves.cupboard']);
      expect(
        harness
            .read(storageTemplatesOfDomainProvider(StorageDomainIdentifier.freezer))
            .map((template) => template.identifier),
        [
          'freezer.upright_three',
          'freezer.upright_five',
          'freezer.upright_seven',
          'freezer.chest_baskets',
          'freezer.fridge_compartment',
          'freezer.empty',
        ],
      );
    });

    test('a place created from a template belongs to its domain in the live layout', () async {
      await harness
          .read(createStoragePlaceFromTemplateUseCaseProvider)
          .execute(
            template: harness.template('shelves.cupboard'),
            defaultNames: const EnglishLayoutDefaultNames(),
          );
      final layout = await harness.readLayout();
      final cupboard = layout.storagePlacesIn(StorageDomainIdentifier.pantry).single;
      expect(cupboard.compartments, hasLength(4));
      expect(cupboard.storagePlace.storageKind, const StorageKind('testCupboard'));
    });

    testWidgets('default names come from the kind, with neutral names for unknown kinds', (
      tester,
    ) async {
      late LayoutDefaultNames defaultNames;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: harness.container,
          child: buildLocalizedTestApplication(
            featureLocalizationDelegates: const StorageLayoutFeatureModule().localizationDelegates,
            home: Builder(
              builder: (context) {
                defaultNames = context.layoutDefaultNames;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(defaultNames.compartmentName(const StorageKind('testCupboard'), 2), 'Shelf 2');
      expect(defaultNames.storagePlaceName(const StorageKind('testCupboard')), 'Cupboard');
      expect(defaultNames.compartmentName(const StorageKind('chest'), 3), 'Basket 3');
      expect(defaultNames.storagePlaceName(const StorageKind('removedKind')), 'Storage place');
      expect(defaultNames.compartmentName(const StorageKind('removedKind'), 1), 'Compartment 1');
    });

    testWidgets('adding a storage place offers the templates of its domain only', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: harness.container,
          child: buildLocalizedTestApplication(
            featureLocalizationDelegates: const StorageLayoutFeatureModule().localizationDelegates,
            home: const StorageTemplatePickerScreen(
              domainIdentifier: StorageDomainIdentifier.pantry,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Cupboard with 4 shelves'), findsOneWidget);
      expect(find.text('Upright freezer with 3 drawers'), findsNothing);
    });
  });
}
