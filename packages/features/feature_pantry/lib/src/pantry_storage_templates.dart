import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/domain.dart';

/// The kinds of pantry storage, as stored with every storage place. Never rename
/// one that has shipped.
abstract final class PantryStorageKinds {
  static const StorageKind pantry = StorageKind('pantry');
  static const StorageKind kitchenCupboard = StorageKind('kitchenCupboard');
  static const StorageKind cellar = StorageKind('cellar');
  static const StorageKind drinksCrate = StorageKind('drinksCrate');
}

/// The pantry templates, for onboarding defaults and tests.
abstract final class PantryStorageTemplates {
  static const StorageTemplate pantryShelves = StorageTemplate(
    identifier: 'pantry.shelves',
    storageKind: PantryStorageKinds.pantry,
    domainIdentifier: StorageDomainIdentifier.pantry,
    compartmentCount: 4,
    sortOrder: 10,
  );
  static const StorageTemplate kitchenCupboard = StorageTemplate(
    identifier: 'pantry.cupboard',
    storageKind: PantryStorageKinds.kitchenCupboard,
    domainIdentifier: StorageDomainIdentifier.pantry,
    compartmentCount: 2,
    sortOrder: 20,
  );
  static const StorageTemplate cellar = StorageTemplate(
    identifier: 'pantry.cellar',
    storageKind: PantryStorageKinds.cellar,
    domainIdentifier: StorageDomainIdentifier.pantry,
    compartmentCount: 3,
    sortOrder: 30,
  );
  static const StorageTemplate drinksCrate = StorageTemplate(
    identifier: 'pantry.drinks_crate',
    storageKind: PantryStorageKinds.drinksCrate,
    domainIdentifier: StorageDomainIdentifier.pantry,
    compartmentCount: 1,
    sortOrder: 40,
  );
}
