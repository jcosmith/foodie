import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/domain.dart';

/// The kinds of fridge, as stored with every storage place. Never rename one
/// that has shipped.
abstract final class FridgeStorageKinds {
  static const StorageKind fridge = StorageKind('fridge');
  static const StorageKind drinksFridge = StorageKind('drinksFridge');
  static const StorageKind wineFridge = StorageKind('wineFridge');
}

/// The fridge templates, for onboarding defaults and tests.
abstract final class FridgeStorageTemplates {
  static const StorageTemplate threeShelves = StorageTemplate(
    identifier: 'fridge.three_shelves',
    storageKind: FridgeStorageKinds.fridge,
    domainIdentifier: StorageDomainIdentifier.fridge,
    compartmentCount: 3,
    sortOrder: 10,
  );
  static const StorageTemplate fiveShelves = StorageTemplate(
    identifier: 'fridge.five_shelves',
    storageKind: FridgeStorageKinds.fridge,
    domainIdentifier: StorageDomainIdentifier.fridge,
    compartmentCount: 5,
    sortOrder: 20,
  );
  static const StorageTemplate drinks = StorageTemplate(
    identifier: 'fridge.drinks',
    storageKind: FridgeStorageKinds.drinksFridge,
    domainIdentifier: StorageDomainIdentifier.fridge,
    compartmentCount: 3,
    sortOrder: 30,
  );
  static const StorageTemplate wine = StorageTemplate(
    identifier: 'fridge.wine',
    storageKind: FridgeStorageKinds.wineFridge,
    domainIdentifier: StorageDomainIdentifier.fridge,
    compartmentCount: 4,
    sortOrder: 40,
  );
}
