import 'package:core_foundation/core_foundation.dart';

import '../../domain/compartment.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Picks another colour tag for a compartment.
final class ChangeCompartmentColorUseCase {
  const ChangeCompartmentColorUseCase({required StorageLayoutRepository repository})
    : _repository = repository;

  final StorageLayoutRepository _repository;

  Future<Result<Unit, StorageLayoutFailure>> execute({
    required CompartmentIdentifier compartmentIdentifier,
    required int colorTagIndex,
  }) async {
    final compartment = await _repository.readCompartment(compartmentIdentifier);
    if (compartment == null || compartment.isArchived) {
      return const Result.failure(CompartmentNotFound());
    }
    await _repository.updateCompartmentColorTag(
      compartmentIdentifier,
      colorTagIndex % compartmentColorTagCount,
    );
    return const Result.success(unit);
  }
}
