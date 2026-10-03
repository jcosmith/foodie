import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/compartment.dart';
import '../../domain/freezer.dart';
import '../../domain/freezer_template.dart';
import '../../domain/layout_default_names.dart';
import '../../domain/layout_name_policy.dart';
import '../../domain/storage_layout_events.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Adds a freezer with the compartments of a template, at the end of the list.
final class CreateFreezerFromTemplateUseCase {
  const CreateFreezerFromTemplateUseCase({
    required StorageLayoutRepository repository,
    required TransactionRunner transactionRunner,
    required DomainEventBus domainEventBus,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
  }) : _repository = repository,
       _transactionRunner = transactionRunner,
       _domainEventBus = domainEventBus,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final StorageLayoutRepository _repository;
  final TransactionRunner _transactionRunner;
  final DomainEventBus _domainEventBus;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;

  /// An empty [enteredName] keeps the translated default name.
  Future<Result<FreezerIdentifier, StorageLayoutFailure>> execute({
    required FreezerTemplate template,
    required LayoutDefaultNames defaultNames,
    String enteredName = '',
  }) async {
    final existingFreezers = await _repository.readActiveFreezers();
    final nameValidation = LayoutNamePolicy.validate(
      enteredName: enteredName,
      siblingDisplayNames: [
        for (final freezer in existingFreezers)
          freezer.customName ?? defaultNames.freezerName(freezer.storageKind),
      ],
    );
    if (nameValidation case FailedResult(:final failure)) return Result.failure(failure);

    final createdAt = _clock.nowUtc();
    final freezer = Freezer(
      identifier: _identifierGenerator.createIdentifier(),
      storageKind: template.storageKind,
      customName: nameValidation.valueOrNull,
      sortOrder: existingFreezers.isEmpty ? 0 : existingFreezers.last.sortOrder + 1,
      createdAt: createdAt,
    );
    final compartments = [
      for (var number = 1; number <= template.compartmentCount; number++)
        Compartment(
          identifier: _identifierGenerator.createIdentifier(),
          freezerIdentifier: freezer.identifier,
          defaultNumber: number,
          colorTagIndex: defaultColorTagIndexFor(number),
          sortOrder: number - 1,
          createdAt: createdAt,
        ),
    ];

    await _transactionRunner.runInTransaction(() async {
      await _repository.insertFreezer(freezer);
      for (final compartment in compartments) {
        await _repository.insertCompartment(compartment);
      }
    });
    for (final compartment in compartments) {
      await _domainEventBus.publish(
        CompartmentCreated(
          compartmentIdentifier: compartment.identifier,
          freezerIdentifier: freezer.identifier,
          occurredAt: createdAt,
        ),
      );
    }
    return Result.success(freezer.identifier);
  }
}
