import 'package:core_foundation/core_foundation.dart';

import '../../domain/freezer.dart';
import '../../domain/layout_default_names.dart';
import '../../domain/layout_name_policy.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';

/// Gives a freezer the user's own name; an empty name restores the default.
final class RenameFreezerUseCase {
  const RenameFreezerUseCase({required StorageLayoutRepository repository})
    : _repository = repository;

  final StorageLayoutRepository _repository;

  Future<Result<Unit, StorageLayoutFailure>> execute({
    required FreezerIdentifier freezerIdentifier,
    required String enteredName,
    required LayoutDefaultNames defaultNames,
  }) async {
    final activeFreezers = await _repository.readActiveFreezers();
    if (!activeFreezers.any((freezer) => freezer.identifier == freezerIdentifier)) {
      return const Result.failure(FreezerNotFound());
    }
    final nameValidation = LayoutNamePolicy.validate(
      enteredName: enteredName,
      siblingDisplayNames: [
        for (final freezer in activeFreezers)
          if (freezer.identifier != freezerIdentifier)
            freezer.customName ?? defaultNames.freezerName(freezer.storageKind),
      ],
    );
    return switch (nameValidation) {
      FailedResult(:final failure) => Result.failure(failure),
      SuccessfulResult(value: final customName) => await _store(freezerIdentifier, customName),
    };
  }

  Future<Result<Unit, StorageLayoutFailure>> _store(
    FreezerIdentifier freezerIdentifier,
    String? customName,
  ) async {
    await _repository.updateFreezerCustomName(freezerIdentifier, customName);
    return const Result.success(unit);
  }
}
