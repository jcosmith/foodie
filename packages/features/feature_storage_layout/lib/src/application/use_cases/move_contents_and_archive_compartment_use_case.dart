import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/compartment.dart';
import '../../domain/compartment_contents_port.dart';
import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Removes a compartment from the layout (architecture document, section
/// 10.4). Its items move to [destinationCompartmentIdentifier] with "moved"
/// movements, and the compartment is archived, all in one transaction. An
/// empty compartment is archived directly.
final class MoveContentsAndArchiveCompartmentUseCase {
  const MoveContentsAndArchiveCompartmentUseCase({
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

  Future<Result<Unit, StorageLayoutFailure>> execute({
    required CompartmentIdentifier compartmentIdentifier,
    CompartmentIdentifier? destinationCompartmentIdentifier,
  }) async {
    final compartment = await _repository.readCompartment(compartmentIdentifier);
    if (compartment == null || compartment.isArchived) {
      return const Result.failure(CompartmentNotFound());
    }
    final siblings = await _repository.readActiveCompartmentsOfStoragePlace(
      compartment.storagePlaceIdentifier,
    );
    if (siblings.length <= 1) return const Result.failure(LastCompartmentCannotBeRemoved());

    final itemCount = await _compartmentContents.countItemsInCompartment(compartmentIdentifier);
    if (itemCount > 0) {
      if (destinationCompartmentIdentifier == null) {
        return Result.failure(CompartmentNotEmpty(itemCount: itemCount));
      }
      final destination = await _repository.readCompartment(destinationCompartmentIdentifier);
      if (destination == null ||
          destination.isArchived ||
          destination.identifier == compartmentIdentifier) {
        return const Result.failure(InvalidMoveDestination());
      }
    }

    final eventsToPublish = await _transactionRunner.runInTransaction(() async {
      final moveEvents = itemCount > 0
          ? await _compartmentContents.moveAllContents(
              sourceCompartmentIdentifier: compartmentIdentifier,
              destinationCompartmentIdentifier: destinationCompartmentIdentifier!,
            )
          : const <DomainEvent>[];
      await _repository.archiveCompartment(compartmentIdentifier);
      return moveEvents;
    });

    for (final event in eventsToPublish) {
      await _domainEventBus.publish(event);
    }
    await _domainEventBus.publish(
      CompartmentArchived(
        compartmentIdentifier: compartmentIdentifier,
        contentsMovedToCompartmentIdentifier: itemCount > 0
            ? destinationCompartmentIdentifier
            : null,
        occurredAt: _clock.nowUtc(),
      ),
    );
    return const Result.success(unit);
  }
}
