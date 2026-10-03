import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/freezer.dart';
import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Stores a new order of the active freezers.
final class ReorderFreezersUseCase {
  const ReorderFreezersUseCase({
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
    List<FreezerIdentifier> orderedFreezerIdentifiers,
  ) async {
    final activeFreezers = await _repository.readActiveFreezers();
    final activeIdentifiers = {for (final freezer in activeFreezers) freezer.identifier};
    if (orderedFreezerIdentifiers.length != activeIdentifiers.length ||
        !activeIdentifiers.containsAll(orderedFreezerIdentifiers)) {
      return const Result.failure(InvalidOrder());
    }
    await _repository.updateFreezerSortOrders({
      for (final (index, freezerIdentifier) in orderedFreezerIdentifiers.indexed)
        freezerIdentifier: index,
    });
    await _domainEventBus.publish(
      CompartmentReordered(freezerIdentifier: null, occurredAt: _clock.nowUtc()),
    );
    return const Result.success(unit);
  }
}
