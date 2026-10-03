import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/compartment.dart';
import '../../domain/freezer.dart';
import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Stores a new order of a freezer's active compartments.
final class ReorderCompartmentsUseCase {
  const ReorderCompartmentsUseCase({
    required StorageLayoutRepository repository,
    required DomainEventBus domainEventBus,
    required Clock clock,
  }) : _repository = repository,
       _domainEventBus = domainEventBus,
       _clock = clock;

  final StorageLayoutRepository _repository;
  final DomainEventBus _domainEventBus;
  final Clock _clock;

  Future<Result<Unit, StorageLayoutFailure>> execute({
    required FreezerIdentifier freezerIdentifier,
    required List<CompartmentIdentifier> orderedCompartmentIdentifiers,
  }) async {
    final compartments = await _repository.readActiveCompartmentsOfFreezer(freezerIdentifier);
    final activeIdentifiers = {for (final compartment in compartments) compartment.identifier};
    if (orderedCompartmentIdentifiers.length != activeIdentifiers.length ||
        !activeIdentifiers.containsAll(orderedCompartmentIdentifiers)) {
      return const Result.failure(InvalidOrder());
    }
    await _repository.updateCompartmentSortOrders({
      for (final (index, compartmentIdentifier) in orderedCompartmentIdentifiers.indexed)
        compartmentIdentifier: index,
    });
    await _domainEventBus.publish(
      CompartmentReordered(freezerIdentifier: freezerIdentifier, occurredAt: _clock.nowUtc()),
    );
    return const Result.success(unit);
  }
}
