import 'compartment.dart';
import 'storage_place.dart';

/// Storage of storage places and compartments. Implemented in the data layer on
/// top of the storage layout DAO.
abstract interface class StorageLayoutRepository {
  Stream<List<StoragePlace>> watchStoragePlacesIncludingArchived();

  Stream<List<Compartment>> watchCompartmentsIncludingArchived();

  /// Active storage places in the user's order.
  Future<List<StoragePlace>> readActiveStoragePlaces();

  Future<StoragePlace?> readStoragePlace(StoragePlaceIdentifier storagePlaceIdentifier);

  Future<Compartment?> readCompartment(CompartmentIdentifier compartmentIdentifier);

  /// Active compartments of a storage place in the user's order.
  Future<List<Compartment>> readActiveCompartmentsOfStoragePlace(
    StoragePlaceIdentifier storagePlaceIdentifier,
  );

  /// The next number for a default name such as "Drawer 4"; numbers of
  /// archived compartments are never reused.
  Future<int> readNextCompartmentDefaultNumber(StoragePlaceIdentifier storagePlaceIdentifier);

  Future<void> insertStoragePlace(StoragePlace storagePlace);

  Future<void> insertCompartment(Compartment compartment);

  Future<void> updateStoragePlaceCustomName(
    StoragePlaceIdentifier storagePlaceIdentifier,
    String? customName,
  );

  Future<void> updateStoragePlaceSortOrders(
    Map<StoragePlaceIdentifier, int> sortOrderByStoragePlace,
  );

  Future<void> archiveStoragePlace(StoragePlaceIdentifier storagePlaceIdentifier);

  Future<void> updateCompartmentCustomName(
    CompartmentIdentifier compartmentIdentifier,
    String? customName,
  );

  Future<void> updateCompartmentColorTag(
    CompartmentIdentifier compartmentIdentifier,
    int colorTagIndex,
  );

  Future<void> updateCompartmentSortOrders(Map<CompartmentIdentifier, int> sortOrderByCompartment);

  Future<void> archiveCompartment(CompartmentIdentifier compartmentIdentifier);
}
