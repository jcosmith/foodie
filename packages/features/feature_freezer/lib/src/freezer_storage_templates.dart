import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/domain.dart';

/// The kinds of freezer, as stored with every storage place. Never rename
/// one that has shipped.
abstract final class FreezerStorageKinds {
  static const StorageKind upright = StorageKind('upright');
  static const StorageKind chest = StorageKind('chest');
  static const StorageKind fridgeFreezerCompartment = StorageKind('fridgeFreezerCompartment');
}

/// The freezer templates, for onboarding defaults and tests.
abstract final class FreezerStorageTemplates {
  static const StorageTemplate uprightWithThreeDrawers = StorageTemplate(
    identifier: 'freezer.upright_three',
    storageKind: FreezerStorageKinds.upright,
    domainIdentifier: StorageDomainIdentifier.freezer,
    compartmentCount: 3,
    sortOrder: 10,
  );
  static const StorageTemplate uprightWithFiveDrawers = StorageTemplate(
    identifier: 'freezer.upright_five',
    storageKind: FreezerStorageKinds.upright,
    domainIdentifier: StorageDomainIdentifier.freezer,
    compartmentCount: 5,
    sortOrder: 20,
  );
  static const StorageTemplate uprightWithSevenDrawers = StorageTemplate(
    identifier: 'freezer.upright_seven',
    storageKind: FreezerStorageKinds.upright,
    domainIdentifier: StorageDomainIdentifier.freezer,
    compartmentCount: 7,
    sortOrder: 30,
  );
  static const StorageTemplate chestWithBaskets = StorageTemplate(
    identifier: 'freezer.chest_baskets',
    storageKind: FreezerStorageKinds.chest,
    domainIdentifier: StorageDomainIdentifier.freezer,
    compartmentCount: 3,
    sortOrder: 40,
  );
  static const StorageTemplate fridgeFreezerCompartment = StorageTemplate(
    identifier: 'freezer.fridge_compartment',
    storageKind: FreezerStorageKinds.fridgeFreezerCompartment,
    domainIdentifier: StorageDomainIdentifier.freezer,
    compartmentCount: 1,
    sortOrder: 50,
  );

  /// Offered last: one drawer to start from.
  static const StorageTemplate empty = StorageTemplate(
    identifier: 'freezer.empty',
    storageKind: FreezerStorageKinds.upright,
    domainIdentifier: StorageDomainIdentifier.freezer,
    compartmentCount: 1,
    sortOrder: 90,
  );
}
