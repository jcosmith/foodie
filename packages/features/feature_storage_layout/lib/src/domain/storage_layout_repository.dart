import 'compartment.dart';
import 'freezer.dart';

/// Storage of freezers and compartments. Implemented in the data layer on
/// top of the storage layout DAO.
abstract interface class StorageLayoutRepository {
  Stream<List<Freezer>> watchFreezersIncludingArchived();

  Stream<List<Compartment>> watchCompartmentsIncludingArchived();

  /// Active freezers in the user's order.
  Future<List<Freezer>> readActiveFreezers();

  Future<Freezer?> readFreezer(FreezerIdentifier freezerIdentifier);

  Future<Compartment?> readCompartment(CompartmentIdentifier compartmentIdentifier);

  /// Active compartments of a freezer in the user's order.
  Future<List<Compartment>> readActiveCompartmentsOfFreezer(FreezerIdentifier freezerIdentifier);

  /// The next number for a default name such as "Drawer 4"; numbers of
  /// archived compartments are never reused.
  Future<int> readNextCompartmentDefaultNumber(FreezerIdentifier freezerIdentifier);

  Future<void> insertFreezer(Freezer freezer);

  Future<void> insertCompartment(Compartment compartment);

  Future<void> updateFreezerCustomName(FreezerIdentifier freezerIdentifier, String? customName);

  Future<void> updateFreezerSortOrders(Map<FreezerIdentifier, int> sortOrderByFreezer);

  Future<void> archiveFreezer(FreezerIdentifier freezerIdentifier);

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
