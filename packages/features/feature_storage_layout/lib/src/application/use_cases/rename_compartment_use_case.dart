import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/compartment.dart';
import '../../domain/layout_default_names.dart';
import '../../domain/layout_name_policy.dart';
import '../../domain/storage_kind.dart';
import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Gives a compartment the user's own name; an empty name restores the
/// translated default. Names are unique within a storage place, ignoring case.
final class RenameCompartmentUseCase {
  const RenameCompartmentUseCase({
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
    required CompartmentIdentifier compartmentIdentifier,
    required String enteredName,
    required LayoutDefaultNames defaultNames,
  }) async {
    final compartment = await _repository.readCompartment(compartmentIdentifier);
    if (compartment == null || compartment.isArchived) {
      return const Result.failure(CompartmentNotFound());
    }
    final storagePlace = await _repository.readStoragePlace(compartment.storagePlaceIdentifier);
    final storageKind = storagePlace?.storageKind ?? StorageKind.upright;
    final siblings = await _repository.readActiveCompartmentsOfStoragePlace(
      compartment.storagePlaceIdentifier,
    );
    final nameValidation = LayoutNamePolicy.validate(
      enteredName: enteredName,
      siblingDisplayNames: [
        for (final sibling in siblings)
          if (sibling.identifier != compartmentIdentifier)
            sibling.customName ?? defaultNames.compartmentName(storageKind, sibling.defaultNumber),
      ],
    );
    if (nameValidation case FailedResult(:final failure)) return Result.failure(failure);

    final customName = nameValidation.valueOrNull;
    if (customName == compartment.customName) return const Result.success(unit);
    await _repository.updateCompartmentCustomName(compartmentIdentifier, customName);
    await _domainEventBus.publish(
      CompartmentRenamed(compartmentIdentifier: compartmentIdentifier, occurredAt: _clock.nowUtc()),
    );
    return const Result.success(unit);
  }
}
