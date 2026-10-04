import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/compartment_contents_port.dart';
import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';
import '../../domain/storage_place.dart';

/// Removes an empty storage place and its compartments from the layout. Nothing is
/// deleted, so statistics keep their names.
final class ArchiveStoragePlaceUseCase {
  const ArchiveStoragePlaceUseCase({
    required StorageLayoutRepository repository,
    required CompartmentContentsPort compartmentContents,
    required TransactionRunner transactionRunner,
    required DomainEventBus domainEventBus,
    required Clock clock,
  }) : _repository = repository,
       _compartmentContents = compartmentContents,
       _transactionRunner = transactionRunner,
       _domainEventBus = domainEventBus,
       _clock = clock;

  final StorageLayoutRepository _repository;
  final CompartmentContentsPort _compartmentContents;
  final TransactionRunner _transactionRunner;
  final DomainEventBus _domainEventBus;
  final Clock _clock;

  Future<Result<Unit, StorageLayoutFailure>> execute(
    StoragePlaceIdentifier storagePlaceIdentifier,
  ) async {
    final activeStoragePlaces = await _repository.readActiveStoragePlaces();
    if (!activeStoragePlaces.any(
      (storagePlace) => storagePlace.identifier == storagePlaceIdentifier,
    )) {
      return const Result.failure(StoragePlaceNotFound());
    }
    if (activeStoragePlaces.length == 1) {
      return const Result.failure(LastStoragePlaceCannotBeRemoved());
    }

    final compartments = await _repository.readActiveCompartmentsOfStoragePlace(
      storagePlaceIdentifier,
    );
    var itemCount = 0;
    for (final compartment in compartments) {
      itemCount += await _compartmentContents.countItemsInCompartment(compartment.identifier);
    }
    if (itemCount > 0) return Result.failure(StoragePlaceNotEmpty(itemCount: itemCount));

    await _transactionRunner.runInTransaction(() async {
      for (final compartment in compartments) {
        await _repository.archiveCompartment(compartment.identifier);
      }
      await _repository.archiveStoragePlace(storagePlaceIdentifier);
    });
    final occurredAt = _clock.nowUtc();
    for (final compartment in compartments) {
      await _domainEventBus.publish(
        CompartmentArchived(
          compartmentIdentifier: compartment.identifier,
          contentsMovedToCompartmentIdentifier: null,
          occurredAt: occurredAt,
        ),
      );
    }
    return const Result.success(unit);
  }
}
