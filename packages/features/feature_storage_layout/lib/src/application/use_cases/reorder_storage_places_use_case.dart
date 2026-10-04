import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';
import '../../domain/storage_place.dart';

/// Stores a new order of the active storage places.
final class ReorderStoragePlacesUseCase {
  const ReorderStoragePlacesUseCase({
    required StorageLayoutRepository repository,
    required DomainEventBus domainEventBus,
    required Clock clock,
  }) : _repository = repository,
       _domainEventBus = domainEventBus,
       _clock = clock;

  final StorageLayoutRepository _repository;
  final DomainEventBus _domainEventBus;
  final Clock _clock;

  Future<Result<Unit, StorageLayoutFailure>> execute(
    List<StoragePlaceIdentifier> orderedStoragePlaceIdentifiers,
  ) async {
    final activeStoragePlaces = await _repository.readActiveStoragePlaces();
    final activeIdentifiers = {
      for (final storagePlace in activeStoragePlaces) storagePlace.identifier,
    };
    if (orderedStoragePlaceIdentifiers.length != activeIdentifiers.length ||
        !activeIdentifiers.containsAll(orderedStoragePlaceIdentifiers)) {
      return const Result.failure(InvalidOrder());
    }
    await _repository.updateStoragePlaceSortOrders({
      for (final (index, storagePlaceIdentifier) in orderedStoragePlaceIdentifiers.indexed)
        storagePlaceIdentifier: index,
    });
    await _domainEventBus.publish(
      CompartmentReordered(storagePlaceIdentifier: null, occurredAt: _clock.nowUtc()),
    );
    return const Result.success(unit);
  }
}
