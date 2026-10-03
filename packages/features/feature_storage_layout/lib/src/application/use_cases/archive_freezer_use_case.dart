import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/compartment_contents_port.dart';
import '../../domain/freezer.dart';
import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Removes an empty freezer and its compartments from the layout. Nothing is
/// deleted, so statistics keep their names.
final class ArchiveFreezerUseCase {
  const ArchiveFreezerUseCase({
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

  Future<Result<Unit, StorageLayoutFailure>> execute(FreezerIdentifier freezerIdentifier) async {
    final activeFreezers = await _repository.readActiveFreezers();
    if (!activeFreezers.any((freezer) => freezer.identifier == freezerIdentifier)) {
      return const Result.failure(FreezerNotFound());
    }
    if (activeFreezers.length == 1) return const Result.failure(LastFreezerCannotBeRemoved());

    final compartments = await _repository.readActiveCompartmentsOfFreezer(freezerIdentifier);
    var itemCount = 0;
    for (final compartment in compartments) {
      itemCount += await _compartmentContents.countItemsInCompartment(compartment.identifier);
    }
    if (itemCount > 0) return Result.failure(FreezerNotEmpty(itemCount: itemCount));

    await _transactionRunner.runInTransaction(() async {
      for (final compartment in compartments) {
        await _repository.archiveCompartment(compartment.identifier);
      }
      await _repository.archiveFreezer(freezerIdentifier);
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
