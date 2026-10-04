import 'storage_kind.dart';

/// The starting points offered when adding a storage place. Every template has at
/// least one compartment, because a storage place always keeps one.
enum StorageTemplate {
  uprightWithThreeDrawers(storageKind: StorageKind.upright, compartmentCount: 3),
  uprightWithFiveDrawers(storageKind: StorageKind.upright, compartmentCount: 5),
  uprightWithSevenDrawers(storageKind: StorageKind.upright, compartmentCount: 7),
  chestWithBaskets(storageKind: StorageKind.chest, compartmentCount: 3),
  fridgeFreezerCompartment(storageKind: StorageKind.fridgeFreezerCompartment, compartmentCount: 1),
  empty(storageKind: StorageKind.upright, compartmentCount: 1);

  const StorageTemplate({required this.storageKind, required this.compartmentCount});

  final StorageKind storageKind;
  final int compartmentCount;
}
