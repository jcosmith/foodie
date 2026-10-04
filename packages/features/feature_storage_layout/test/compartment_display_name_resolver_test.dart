import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/storage_layout_test_harness.dart';

void main() {
  final createdAt = DateTime.utc(2026);
  final kitchenFreezer = StoragePlace(
    identifier: const StoragePlaceIdentifier('kitchen'),
    storageKind: const StorageKind('upright'),
    sortOrder: 0,
    createdAt: createdAt,
  );
  final cellarFreezer = StoragePlace(
    identifier: const StoragePlaceIdentifier('cellar'),
    storageKind: const StorageKind('chest'),
    customName: 'Cellar',
    sortOrder: 1,
    createdAt: createdAt,
  );
  Compartment compartment(
    String identifier,
    StoragePlace storagePlace,
    int defaultNumber, {
    String? customName,
    bool isArchived = false,
  }) => Compartment(
    identifier: CompartmentIdentifier(identifier),
    storagePlaceIdentifier: storagePlace.identifier,
    defaultNumber: defaultNumber,
    customName: customName,
    colorTagIndex: 0,
    sortOrder: defaultNumber,
    isArchived: isArchived,
    createdAt: createdAt,
  );

  test('shows translated defaults, custom names and removed compartments', () {
    final firstDrawer = compartment('d1', kitchenFreezer, 1);
    final renamedDrawer = compartment('d2', kitchenFreezer, 2, customName: 'Bread & sweets');
    final removedDrawer = compartment('d3', kitchenFreezer, 3, isArchived: true);
    final resolver = CompartmentDisplayNameResolver(
      layout: StorageLayout.fromEntities(
        storagePlacesIncludingArchived: [kitchenFreezer],
        compartmentsIncludingArchived: [firstDrawer, renamedDrawer, removedDrawer],
      ),
      defaultNames: const EnglishLayoutDefaultNames(),
    );

    expect(resolver.storagePlaceName(kitchenFreezer), 'Freezer');
    expect(resolver.compartmentName(firstDrawer), 'Drawer 1');
    expect(resolver.compartmentName(renamedDrawer), 'Bread & sweets');
    expect(resolver.compartmentName(removedDrawer), 'Drawer 3 (removed)');
    expect(resolver.plainCompartmentName(removedDrawer), 'Drawer 3');
    expect(resolver.compartmentNameWithStoragePlace(firstDrawer), 'Drawer 1');
  });

  test('names the freezer as well once there are several, using its storage kind', () {
    final basket = compartment('b1', cellarFreezer, 1);
    final resolver = CompartmentDisplayNameResolver(
      layout: StorageLayout.fromEntities(
        storagePlacesIncludingArchived: [cellarFreezer, kitchenFreezer],
        compartmentsIncludingArchived: [basket, compartment('d1', kitchenFreezer, 1)],
      ),
      defaultNames: const EnglishLayoutDefaultNames(),
    );

    expect(resolver.compartmentNameWithStoragePlace(basket), 'Cellar · Basket 1');
    expect(
      resolver.layout.storagePlaces.map(
        (storagePlaceLayout) => storagePlaceLayout.storagePlace.identifier.value,
      ),
      ['kitchen', 'cellar'],
    );
  });
}
