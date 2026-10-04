import 'package:core_foundation/core_foundation.dart';

import '../domain/compartment.dart';
import '../domain/compartment_contents_port.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_layout_repository.dart';

/// Read-only access to the storage place layout for other features (inventory,
/// onboarding, statistics).
final class StorageLayoutQueryService {
  const StorageLayoutQueryService({
    required StorageLayoutRepository repository,
    required CompartmentContentsPort compartmentContents,
  }) : _repository = repository,
       _compartmentContents = compartmentContents;

  final StorageLayoutRepository _repository;
  final CompartmentContentsPort _compartmentContents;

  /// The layout, updated whenever a storage place or compartment changes.
  Stream<StorageLayout> watchStorageLayout() => combineLatestOfTwo(
    _repository.watchStoragePlacesIncludingArchived(),
    _repository.watchCompartmentsIncludingArchived(),
    (storagePlaces, compartments) => StorageLayout.fromEntities(
      storagePlacesIncludingArchived: storagePlaces,
      compartmentsIncludingArchived: compartments,
    ),
  );

  Future<StorageLayout> readStorageLayout() => watchStorageLayout().first;

  /// Any compartment, archived ones included.
  Future<Compartment?> readCompartment(CompartmentIdentifier compartmentIdentifier) =>
      _repository.readCompartment(compartmentIdentifier);

  /// Number of items per compartment, as reported by the inventory.
  Stream<Map<CompartmentIdentifier, int>> watchItemCountsByCompartment() =>
      _compartmentContents.watchItemCountsByCompartment();
}
