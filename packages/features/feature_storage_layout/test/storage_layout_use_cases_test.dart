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

  Future<FreezerIdentifier> createFreezer(
    FreezerTemplate template, {
    String enteredName = '',
  }) async {
    final result = await harness
        .read(createFreezerFromTemplateUseCaseProvider)
        .execute(template: template, enteredName: enteredName, defaultNames: _defaultNames);
    return result.valueOrNull!;
  }

  Future<List<Compartment>> compartmentsOf(FreezerIdentifier freezerIdentifier) async =>
      (await harness.readLayout()).freezerLayoutOf(freezerIdentifier)!.compartments;

  group('creating a freezer from a template', () {
    test('creates numbered drawers with differing colour tags', () async {
      final freezerIdentifier = await createFreezer(FreezerTemplate.uprightWithFiveDrawers);

      final compartments = await compartmentsOf(freezerIdentifier);
      expect(compartments.map((compartment) => compartment.defaultNumber), [1, 2, 3, 4, 5]);
      expect(compartments.map((compartment) => compartment.colorTagIndex), [0, 1, 2, 3, 4]);
      expect(harness.publishedEvents.whereType<CompartmentCreated>(), hasLength(5));
    });

    test('appends further freezers and refuses a duplicate name', () async {
      final kitchen = await createFreezer(
        FreezerTemplate.uprightWithThreeDrawers,
        enteredName: 'Kitchen',
      );
      final cellar = await createFreezer(FreezerTemplate.chestWithBaskets);

      final duplicate = await harness
          .read(createFreezerFromTemplateUseCaseProvider)
          .execute(
            template: FreezerTemplate.empty,
            enteredName: 'KITCHEN',
            defaultNames: _defaultNames,
          );

      expect(duplicate.failureOrNull, isA<LayoutNameAlreadyTaken>());
      final layout = await harness.readLayout();
      expect(layout.freezers.map((freezerLayout) => freezerLayout.freezer.identifier), [
        kitchen,
        cellar,
      ]);
      expect(layout.freezerOf(kitchen)!.customName, 'Kitchen');
    });
  });

  group('renaming a compartment', () {
    test('stores a custom name and goes back to the default when cleared', () async {
      final freezerIdentifier = await createFreezer(FreezerTemplate.uprightWithThreeDrawers);
      final firstDrawer = (await compartmentsOf(freezerIdentifier)).first;
      final renameCompartment = harness.read(renameCompartmentUseCaseProvider);

      await renameCompartment.execute(
        compartmentIdentifier: firstDrawer.identifier,
        enteredName: 'Vegetables',
        defaultNames: _defaultNames,
      );
      expect((await compartmentsOf(freezerIdentifier)).first.customName, 'Vegetables');

      await renameCompartment.execute(
        compartmentIdentifier: firstDrawer.identifier,
        enteredName: '',
        defaultNames: _defaultNames,
      );
      expect((await compartmentsOf(freezerIdentifier)).first.customName, isNull);
      expect(harness.publishedEvents.whereType<CompartmentRenamed>(), hasLength(2));
    });

    test('refuses the default name another drawer still shows', () async {
      final freezerIdentifier = await createFreezer(FreezerTemplate.uprightWithThreeDrawers);
      final firstDrawer = (await compartmentsOf(freezerIdentifier)).first;

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
      final kitchen = await createFreezer(FreezerTemplate.uprightWithThreeDrawers);
      final cellar = await createFreezer(
        FreezerTemplate.uprightWithThreeDrawers,
        enteredName: 'Cellar',
      );
      final renameCompartment = harness.read(renameCompartmentUseCaseProvider);

      for (final freezerIdentifier in [kitchen, cellar]) {
        final result = await renameCompartment.execute(
          compartmentIdentifier: (await compartmentsOf(freezerIdentifier)).first.identifier,
          enteredName: 'Ice cream',
          defaultNames: _defaultNames,
        );
        expect(result.isSuccess, isTrue);
      }
    });
  });

  test('a new compartment never reuses the number of a removed one', () async {
    final freezerIdentifier = await createFreezer(FreezerTemplate.uprightWithThreeDrawers);
    final lastDrawer = (await compartmentsOf(freezerIdentifier)).last;
    await harness
        .read(moveContentsAndArchiveCompartmentUseCaseProvider)
        .execute(compartmentIdentifier: lastDrawer.identifier);

    await harness.read(addCompartmentUseCaseProvider).execute(freezerIdentifier);

    final compartments = await compartmentsOf(freezerIdentifier);
    expect(compartments.map((compartment) => compartment.defaultNumber), [1, 2, 4]);
    expect(compartments.last.colorTagIndex, 3);
  });

  test('reorders compartments and rejects an incomplete order', () async {
    final freezerIdentifier = await createFreezer(FreezerTemplate.uprightWithThreeDrawers);
    final compartments = await compartmentsOf(freezerIdentifier);
    final reorderCompartments = harness.read(reorderCompartmentsUseCaseProvider);

    final incomplete = await reorderCompartments.execute(
      freezerIdentifier: freezerIdentifier,
      orderedCompartmentIdentifiers: [compartments.first.identifier],
    );
    await reorderCompartments.execute(
      freezerIdentifier: freezerIdentifier,
      orderedCompartmentIdentifiers: [
        for (final compartment in compartments.reversed) compartment.identifier,
      ],
    );

    expect(incomplete.failureOrNull, isA<InvalidOrder>());
    expect(
      (await compartmentsOf(freezerIdentifier)).map((compartment) => compartment.defaultNumber),
      [3, 2, 1],
    );
  });

  group('removing a compartment', () {
    test('keeps the last compartment of a freezer', () async {
      final freezerIdentifier = await createFreezer(FreezerTemplate.empty);
      final onlyDrawer = (await compartmentsOf(freezerIdentifier)).single;

      final result = await harness
          .read(moveContentsAndArchiveCompartmentUseCaseProvider)
          .execute(compartmentIdentifier: onlyDrawer.identifier);

      expect(result.failureOrNull, isA<LastCompartmentCannotBeRemoved>());
    });

    test('asks for a destination when the compartment holds items', () async {
      final freezerIdentifier = await createFreezer(FreezerTemplate.uprightWithThreeDrawers);
      final [firstDrawer, secondDrawer, _] = await compartmentsOf(freezerIdentifier);
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
      expect(layout.archivedCompartmentsOf(freezerIdentifier), hasLength(1));
      final archivedEvent = harness.publishedEvents.whereType<CompartmentArchived>().single;
      expect(archivedEvent.contentsMovedToCompartmentIdentifier, secondDrawer.identifier);
    });
  });

  group('removing a freezer', () {
    test('keeps the last freezer', () async {
      final freezerIdentifier = await createFreezer(FreezerTemplate.uprightWithThreeDrawers);

      final result = await harness.read(archiveFreezerUseCaseProvider).execute(freezerIdentifier);

      expect(result.failureOrNull, isA<LastFreezerCannotBeRemoved>());
    });

    test('only removes an empty freezer, together with its compartments', () async {
      await createFreezer(FreezerTemplate.uprightWithThreeDrawers);
      final cellar = await createFreezer(FreezerTemplate.chestWithBaskets);
      final firstBasket = (await compartmentsOf(cellar)).first;
      compartmentContents.setItemCount(firstBasket.identifier, 2);
      final archiveFreezer = harness.read(archiveFreezerUseCaseProvider);

      final whileFull = await archiveFreezer.execute(cellar);
      compartmentContents.removeAllItems();
      final whenEmpty = await archiveFreezer.execute(cellar);

      expect(whileFull.failureOrNull, isA<FreezerNotEmpty>());
      expect(whenEmpty, const Result<Unit, StorageLayoutFailure>.success(unit));
      final layout = await harness.readLayout();
      expect(layout.freezers, hasLength(1));
      expect(layout.compartmentOf(firstBasket.identifier)!.isArchived, isTrue);
    });
  });
}
