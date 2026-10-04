import 'package:core_foundation/core_foundation.dart';

/// Why a change to the storage place layout was refused.
sealed class StorageLayoutFailure extends Failure {
  const StorageLayoutFailure();
}

/// A name is longer than [LayoutNamePolicy.maximumNameLength].
final class LayoutNameTooLong extends StorageLayoutFailure {
  const LayoutNameTooLong();

  @override
  String get debugDescription => 'The name is too long';
}

/// Another compartment of the same storage place, or another storage place, already shows this name.
final class LayoutNameAlreadyTaken extends StorageLayoutFailure {
  const LayoutNameAlreadyTaken();

  @override
  String get debugDescription => 'The name is already taken';
}

final class StoragePlaceNotFound extends StorageLayoutFailure {
  const StoragePlaceNotFound();

  @override
  String get debugDescription => 'The freezer does not exist or was removed';
}

final class CompartmentNotFound extends StorageLayoutFailure {
  const CompartmentNotFound();

  @override
  String get debugDescription => 'The compartment does not exist or was removed';
}

/// A storage place always keeps at least one compartment.
final class LastCompartmentCannotBeRemoved extends StorageLayoutFailure {
  const LastCompartmentCannotBeRemoved();

  @override
  String get debugDescription => 'A freezer needs at least one compartment';
}

/// The compartment still holds items and no destination was given.
final class CompartmentNotEmpty extends StorageLayoutFailure {
  const CompartmentNotEmpty({required this.itemCount});

  final int itemCount;

  @override
  String get debugDescription => 'The compartment still holds $itemCount items';
}

/// Items can only move to another active compartment.
final class InvalidMoveDestination extends StorageLayoutFailure {
  const InvalidMoveDestination();

  @override
  String get debugDescription => 'The destination compartment is not available';
}

/// The app always keeps at least one storage place.
final class LastStoragePlaceCannotBeRemoved extends StorageLayoutFailure {
  const LastStoragePlaceCannotBeRemoved();

  @override
  String get debugDescription => 'At least one freezer is needed';
}

/// A storage place is only removed once all its compartments are empty.
final class StoragePlaceNotEmpty extends StorageLayoutFailure {
  const StoragePlaceNotEmpty({required this.itemCount});

  final int itemCount;

  @override
  String get debugDescription => 'The freezer still holds $itemCount items';
}

/// A reorder request did not list exactly the active entries.
final class InvalidOrder extends StorageLayoutFailure {
  const InvalidOrder();

  @override
  String get debugDescription => 'The new order must list every active entry exactly once';
}
