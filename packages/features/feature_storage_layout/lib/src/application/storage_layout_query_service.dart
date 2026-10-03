import 'package:core_foundation/core_foundation.dart';

import '../domain/compartment.dart';
import '../domain/compartment_contents_port.dart';
import '../domain/storage_layout.dart';
import '../domain/storage_layout_repository.dart';

/// Read-only access to the freezer layout for other features (inventory,
/// onboarding, statistics).
final class StorageLayoutQueryService {
  const StorageLayoutQueryService({
    required StorageLayoutRepository repository,
    required CompartmentContentsPort compartmentContents,
  }) : _repository = repository,
       _compartmentContents = compartmentContents;

  final StorageLayoutRepository _repository;
  final CompartmentContentsPort _compartmentContents;

  /// The layout, updated whenever a freezer or compartment changes.
  Stream<StorageLayout> watchStorageLayout() => combineLatestOfTwo(
    _repository.watchFreezersIncludingArchived(),
    _repository.watchCompartmentsIncludingArchived(),
    (freezers, compartments) => StorageLayout.fromEntities(
      freezersIncludingArchived: freezers,
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
