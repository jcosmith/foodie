import 'package:core_foundation/core_foundation.dart';
import 'package:feature_storage_layout/domain.dart';

/// The kinds of household storage, as stored with every storage place. Never rename
/// one that has shipped.
abstract final class HouseholdSuppliesStorageKinds {
  static const StorageKind cleaningCupboard = StorageKind('cleaningCupboard');
  static const StorageKind bathroomCabinet = StorageKind('bathroomCabinet');
  static const StorageKind laundryRoom = StorageKind('laundryRoom');
  static const StorageKind gardenShed = StorageKind('gardenShed');
  static const StorageKind garage = StorageKind('garage');
  static const StorageKind storageRoom = StorageKind('storageRoom');
  static const StorageKind firstAidBox = StorageKind('firstAidBox');
}

/// The household_supplies templates, for onboarding defaults and tests.
abstract final class HouseholdSuppliesStorageTemplates {
  static const StorageTemplate cleaningCupboard = StorageTemplate(
    identifier: 'household.cleaning_cupboard',
    storageKind: HouseholdSuppliesStorageKinds.cleaningCupboard,
    domainIdentifier: StorageDomainIdentifier.household,
    compartmentCount: 3,
    sortOrder: 10,
  );
  static const StorageTemplate bathroomCabinet = StorageTemplate(
    identifier: 'household.bathroom_cabinet',
    storageKind: HouseholdSuppliesStorageKinds.bathroomCabinet,
    domainIdentifier: StorageDomainIdentifier.household,
    compartmentCount: 3,
    sortOrder: 20,
  );
  static const StorageTemplate laundryRoom = StorageTemplate(
    identifier: 'household.laundry_room',
    storageKind: HouseholdSuppliesStorageKinds.laundryRoom,
    domainIdentifier: StorageDomainIdentifier.household,
    compartmentCount: 2,
    sortOrder: 30,
  );
  static const StorageTemplate gardenShed = StorageTemplate(
    identifier: 'household.garden_shed',
    storageKind: HouseholdSuppliesStorageKinds.gardenShed,
    domainIdentifier: StorageDomainIdentifier.household,
    compartmentCount: 2,
    sortOrder: 40,
  );
  static const StorageTemplate garage = StorageTemplate(
    identifier: 'household.garage',
    storageKind: HouseholdSuppliesStorageKinds.garage,
    domainIdentifier: StorageDomainIdentifier.household,
    compartmentCount: 3,
    sortOrder: 50,
  );
  static const StorageTemplate storageRoom = StorageTemplate(
    identifier: 'household.storage_room',
    storageKind: HouseholdSuppliesStorageKinds.storageRoom,
    domainIdentifier: StorageDomainIdentifier.household,
    compartmentCount: 4,
    sortOrder: 60,
  );
  static const StorageTemplate firstAidBox = StorageTemplate(
    identifier: 'household.first_aid_box',
    storageKind: HouseholdSuppliesStorageKinds.firstAidBox,
    domainIdentifier: StorageDomainIdentifier.household,
    compartmentCount: 1,
    sortOrder: 70,
  );
}
