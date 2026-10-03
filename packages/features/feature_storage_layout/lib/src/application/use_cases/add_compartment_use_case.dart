import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/compartment.dart';
import '../../domain/freezer.dart';
import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Adds a compartment at the bottom of a freezer, named "Drawer {next number}".
final class AddCompartmentUseCase {
  const AddCompartmentUseCase({
    required StorageLayoutRepository repository,
    required DomainEventBus domainEventBus,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
  }) : _repository = repository,
       _domainEventBus = domainEventBus,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final StorageLayoutRepository _repository;
  final DomainEventBus _domainEventBus;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;

  Future<Result<CompartmentIdentifier, StorageLayoutFailure>> execute(
    FreezerIdentifier freezerIdentifier,
  ) async {
    final freezer = await _repository.readFreezer(freezerIdentifier);
    if (freezer == null || freezer.isArchived) return const Result.failure(FreezerNotFound());

    final existingCompartments = await _repository.readActiveCompartmentsOfFreezer(
      freezerIdentifier,
    );
    final defaultNumber = await _repository.readNextCompartmentDefaultNumber(freezerIdentifier);
    final compartment = Compartment(
      identifier: _identifierGenerator.createIdentifier(),
      freezerIdentifier: freezerIdentifier,
      defaultNumber: defaultNumber,
      colorTagIndex: defaultColorTagIndexFor(defaultNumber),
      sortOrder: existingCompartments.isEmpty ? 0 : existingCompartments.last.sortOrder + 1,
      createdAt: _clock.nowUtc(),
    );
    await _repository.insertCompartment(compartment);
    await _domainEventBus.publish(
      CompartmentCreated(
        compartmentIdentifier: compartment.identifier,
        freezerIdentifier: freezerIdentifier,
        occurredAt: compartment.createdAt,
      ),
    );
    return Result.success(compartment.identifier);
  }
}
