import 'package:core_foundation/core_foundation.dart';

import '../../domain/layout_default_names.dart';
import '../../domain/layout_name_policy.dart';
import '../../domain/storage_layout_failure.dart';
import '../../domain/storage_layout_repository.dart';
import '../../domain/storage_place.dart';

/// Gives a storage place the user's own name; an empty name restores the default.
final class RenameStoragePlaceUseCase {
  const RenameStoragePlaceUseCase({required StorageLayoutRepository repository})
    : _repository = repository;

  final StorageLayoutRepository _repository;

  Future<Result<Unit, StorageLayoutFailure>> execute({
    required StoragePlaceIdentifier storagePlaceIdentifier,
    required String enteredName,
    required LayoutDefaultNames defaultNames,
  }) async {
    final activeStoragePlaces = await _repository.readActiveStoragePlaces();
    if (!activeStoragePlaces.any(
      (storagePlace) => storagePlace.identifier == storagePlaceIdentifier,
    )) {
      return const Result.failure(StoragePlaceNotFound());
    }
    final nameValidation = LayoutNamePolicy.validate(
      enteredName: enteredName,
      siblingDisplayNames: [
        for (final storagePlace in activeStoragePlaces)
          if (storagePlace.identifier != storagePlaceIdentifier)
            storagePlace.customName ?? defaultNames.storagePlaceName(storagePlace.storageKind),
      ],
    );
    return switch (nameValidation) {
      FailedResult(:final failure) => Result.failure(failure),
      SuccessfulResult(value: final customName) => await _store(storagePlaceIdentifier, customName),
    };
  }

  Future<Result<Unit, StorageLayoutFailure>> _store(
    StoragePlaceIdentifier storagePlaceIdentifier,
    String? customName,
  ) async {
    await _repository.updateStoragePlaceCustomName(storagePlaceIdentifier, customName);
    return const Result.success(unit);
  }
}
