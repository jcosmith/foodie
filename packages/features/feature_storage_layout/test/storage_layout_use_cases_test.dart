import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:feature_storage_layout/src/application/storage_layout_providers.dart';
import 'package:feature_storage_layout/src/domain/storage_layout_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/storage_layout_test_harness.dart';

const _defaultNames = EnglishLayoutDefaultNames();

void main() {
  late StorageLayoutTestHarness harness;
  late FakeCompartmentContents compartmentContents;

  setUp(() {
    compartmentContents = FakeCompartmentContents();
    harness = StorageLayoutTestHarness(compartmentContents: compartmentContents);
  });
  tearDown(() => harness.dispose());

  Future<StoragePlaceIdentifier> createStoragePlace(
    StorageTemplate template, {
    String enteredName = '',
  }) async {
    final result = await harness
        .read(createStoragePlaceFromTemplateUseCaseProvider)
        .execute(template: template, enteredName: enteredName, defaultNames: _defaultNames);
    return result.valueOrNull!;
  }

  Future<List<Compartment>> compartmentsOf(StoragePlaceIdentifier storagePlaceIdentifier) async =>
      (await harness.readLayout()).storagePlaceLayoutOf(storagePlaceIdentifier)!.compartments;

  group('creating a freezer from a template', () {
    test('creates numbered drawers with differing colour tags', () async {
      final storagePlaceIdentifier = await createStoragePlace(
        harness.template('freezer.upright_five'),
      );

      final compartments = await compartmentsOf(storagePlaceIdentifier);
      expect(compartments.map((compartment) => compartment.defaultNumber), [1, 2, 3, 4, 5]);
      expect(compartments.map((compartment) => compartment.colorTagIndex), [0, 1, 2, 3, 4]);
      expect(harness.publishedEvents.whereType<CompartmentCreated>(), hasLength(5));
    });

    test('appends further freezers and refuses a duplicate name', () async {
      final kitchen = await createStoragePlace(
        harness.template('freezer.upright_three'),
        enteredName: 'Kitchen',
      );
      final cellar = await createStoragePlace(harness.template('freezer.chest_baskets'));

      final duplicate = await harness
          .read(createStoragePlaceFromTemplateUseCaseProvider)
          .execute(
            template: harness.template('freezer.empty'),
            enteredName: 'KITCHEN',
            defaultNames: _defaultNames,
          );

      expect(duplicate.failureOrNull, isA<LayoutNameAlreadyTaken>());
      final layout = await harness.readLayout();
      expect(
        layout.storagePlaces.map(
          (storagePlaceLayout) => storagePlaceLayout.storagePlace.identifier,
        ),
        [kitchen, cellar],
      );
      expect(layout.storagePlaceOf(kitchen)!.customName, 'Kitchen');
    });
  });

  group('renaming a compartment', () {
    test('stores a custom name and goes back to the default when cleared', () async {
      final storagePlaceIdentifier = await createStoragePlace(
        harness.template('freezer.upright_three'),
      );
      final firstDrawer = (await compartmentsOf(storagePlaceIdentifier)).first;
      final renameCompartment = harness.read(renameCompartmentUseCaseProvider);

      await renameCompartment.execute(
        compartmentIdentifier: firstDrawer.identifier,
        enteredName: 'Vegetables',
        defaultNames: _defaultNames,
      );
      expect((await compartmentsOf(storagePlaceIdentifier)).first.customName, 'Vegetables');

      await renameCompartment.execute(
        compartmentIdentifier: firstDrawer.identifier,
        enteredName: '',
        defaultNames: _defaultNames,
      );
      expect((await compartmentsOf(storagePlaceIdentifier)).first.customName, isNull);
      expect(harness.publishedEvents.whereType<CompartmentRenamed>(), hasLength(2));
    });

    test('refuses the default name another drawer still shows', () async {
      final storagePlaceIdentifier = await createStoragePlace(
        harness.template('freezer.upright_three'),
      );
      final firstDrawer = (await compartmentsOf(storagePlaceIdentifier)).first;

      final result = await harness
          .read(renameCompartmentUseCaseProvider)
          .execute(
            compartmentIdentifier: firstDrawer.identifier,
            enteredName: 'drawer 2',
            defaultNames: _defaultNames,
          );

      expect(result.failureOrNull, isA<LayoutNameAlreadyTaken>());
    });

    test('allows the same name in different freezers', () async {
      final kitchen = await createStoragePlace(harness.template('freezer.upright_three'));
      final cellar = await createStoragePlace(
        harness.template('freezer.upright_three'),
        enteredName: 'Cellar',
      );
      final renameCompartment = harness.read(renameCompartmentUseCaseProvider);

      for (final storagePlaceIdentifier in [kitchen, cellar]) {
        final result = await renameCompartment.execute(
          compartmentIdentifier: (await compartmentsOf(storagePlaceIdentifier)).first.identifier,
          enteredName: 'Ice cream',
          defaultNames: _defaultNames,
        );
        expect(result.isSuccess, isTrue);
      }
    });
  });

  test('a new compartment never reuses the number of a removed one', () async {
    final storagePlaceIdentifier = await createStoragePlace(
      harness.template('freezer.upright_three'),
    );
    final lastDrawer = (await compartmentsOf(storagePlaceIdentifier)).last;
    await harness
        .read(moveContentsAndArchiveCompartmentUseCaseProvider)
        .execute(compartmentIdentifier: lastDrawer.identifier);

    await harness.read(addCompartmentUseCaseProvider).execute(storagePlaceIdentifier);

    final compartments = await compartmentsOf(storagePlaceIdentifier);
    expect(compartments.map((compartment) => compartment.defaultNumber), [1, 2, 4]);
    expect(compartments.last.colorTagIndex, 3);
  });

  test('reorders compartments and rejects an incomplete order', () async {
    final storagePlaceIdentifier = await createStoragePlace(
      harness.template('freezer.upright_three'),
    );
    final compartments = await compartmentsOf(storagePlaceIdentifier);
    final reorderCompartments = harness.read(reorderCompartmentsUseCaseProvider);

    final incomplete = await reorderCompartments.execute(
      storagePlaceIdentifier: storagePlaceIdentifier,
      orderedCompartmentIdentifiers: [compartments.first.identifier],
    );
    await reorderCompartments.execute(
      storagePlaceIdentifier: storagePlaceIdentifier,
      orderedCompartmentIdentifiers: [
        for (final compartment in compartments.reversed) compartment.identifier,
      ],
    );

    expect(incomplete.failureOrNull, isA<InvalidOrder>());
    expect(
      (await compartmentsOf(
        storagePlaceIdentifier,
      )).map((compartment) => compartment.defaultNumber),
      [3, 2, 1],
    );
  });

  group('removing a compartment', () {
    test('keeps the last compartment of a freezer', () async {
      final storagePlaceIdentifier = await createStoragePlace(harness.template('freezer.empty'));
      final onlyDrawer = (await compartmentsOf(storagePlaceIdentifier)).single;

      final result = await harness
          .read(moveContentsAndArchiveCompartmentUseCaseProvider)
          .execute(compartmentIdentifier: onlyDrawer.identifier);

      expect(result.failureOrNull, isA<LastCompartmentCannotBeRemoved>());
    });

    test('asks for a destination when the compartment holds items', () async {
      final storagePlaceIdentifier = await createStoragePlace(
        harness.template('freezer.upright_three'),
      );
      final [firstDrawer, secondDrawer, _] = await compartmentsOf(storagePlaceIdentifier);
      compartmentContents.setItemCount(firstDrawer.identifier, 4);
      final removeCompartment = harness.read(moveContentsAndArchiveCompartmentUseCaseProvider);

      final withoutDestination = await removeCompartment.execute(
        compartmentIdentifier: firstDrawer.identifier,
      );
      final intoItself = await removeCompartment.execute(
        compartmentIdentifier: firstDrawer.identifier,
        destinationCompartmentIdentifier: firstDrawer.identifier,
      );
      final moved = await removeCompartment.execute(
        compartmentIdentifier: firstDrawer.identifier,
        destinationCompartmentIdentifier: secondDrawer.identifier,
      );

      expect(withoutDestination.failureOrNull, const TypeMatcher<CompartmentNotEmpty>());
      expect(intoItself.failureOrNull, isA<InvalidMoveDestination>());
      expect(moved.isSuccess, isTrue);
      expect(compartmentContents.requestedMoves, [
        (firstDrawer.identifier, secondDrawer.identifier),
      ]);
      final layout = await harness.readLayout();
      expect(layout.compartmentOf(firstDrawer.identifier)!.isArchived, isTrue);
      expect(layout.archivedCompartmentsOf(storagePlaceIdentifier), hasLength(1));
      final archivedEvent = harness.publishedEvents.whereType<CompartmentArchived>().single;
      expect(archivedEvent.contentsMovedToCompartmentIdentifier, secondDrawer.identifier);
    });
  });

  group('removing a freezer', () {
    test('keeps the last freezer', () async {
      final storagePlaceIdentifier = await createStoragePlace(
        harness.template('freezer.upright_three'),
      );

      final result = await harness
          .read(archiveStoragePlaceUseCaseProvider)
          .execute(storagePlaceIdentifier);

      expect(result.failureOrNull, isA<LastStoragePlaceCannotBeRemoved>());
    });

    test('only removes an empty freezer, together with its compartments', () async {
      await createStoragePlace(harness.template('freezer.upright_three'));
      final cellar = await createStoragePlace(harness.template('freezer.chest_baskets'));
      final firstBasket = (await compartmentsOf(cellar)).first;
      compartmentContents.setItemCount(firstBasket.identifier, 2);
      final archiveStoragePlace = harness.read(archiveStoragePlaceUseCaseProvider);

      final whileFull = await archiveStoragePlace.execute(cellar);
      compartmentContents.removeAllItems();
      final whenEmpty = await archiveStoragePlace.execute(cellar);

      expect(whileFull.failureOrNull, isA<StoragePlaceNotEmpty>());
      expect(whenEmpty, const Result<Unit, StorageLayoutFailure>.success(unit));
      final layout = await harness.readLayout();
      expect(layout.storagePlaces, hasLength(1));
      expect(layout.compartmentOf(firstBasket.identifier)!.isArchived, isTrue);
    });
  });
}
