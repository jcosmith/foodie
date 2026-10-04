import 'package:meta/meta.dart';

import 'compartment.dart';
import 'storage_place.dart';

/// One storage place with its active compartments in the user's order.
@immutable
final class StoragePlaceLayout {
  const StoragePlaceLayout({required this.storagePlace, required this.compartments});

  final StoragePlace storagePlace;
  final List<Compartment> compartments;
}

/// The whole layout as a read model: active storage places in order, each with its
/// active compartments, plus everything archived for historical names.
@immutable
final class StorageLayout {
  const StorageLayout._({
    required this.storagePlaces,
    required Map<StoragePlaceIdentifier, StoragePlace> storagePlaceByIdentifier,
    required Map<CompartmentIdentifier, Compartment> compartmentByIdentifier,
  }) : _storagePlaceByIdentifier = storagePlaceByIdentifier,
       _compartmentByIdentifier = compartmentByIdentifier;

  /// Builds the read model from flat lists, archived entries included.
  factory StorageLayout.fromEntities({
    required List<StoragePlace> storagePlacesIncludingArchived,
    required List<Compartment> compartmentsIncludingArchived,
  }) {
    final activeStoragePlaces =
        storagePlacesIncludingArchived.where((storagePlace) => !storagePlace.isArchived).toList()
          ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
    return StorageLayout._(
      storagePlaces: [
        for (final storagePlace in activeStoragePlaces)
          StoragePlaceLayout(
            storagePlace: storagePlace,
            compartments:
                compartmentsIncludingArchived
                    .where(
                      (compartment) =>
                          compartment.storagePlaceIdentifier == storagePlace.identifier &&
                          !compartment.isArchived,
                    )
                    .toList()
                  ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder)),
          ),
      ],
      storagePlaceByIdentifier: {
        for (final storagePlace in storagePlacesIncludingArchived)
          storagePlace.identifier: storagePlace,
      },
      compartmentByIdentifier: {
        for (final compartment in compartmentsIncludingArchived)
          compartment.identifier: compartment,
      },
    );
  }

  static final StorageLayout empty = StorageLayout.fromEntities(
    storagePlacesIncludingArchived: const [],
    compartmentsIncludingArchived: const [],
  );

  /// Active storage places in the user's order.
  final List<StoragePlaceLayout> storagePlaces;
  final Map<StoragePlaceIdentifier, StoragePlace> _storagePlaceByIdentifier;
  final Map<CompartmentIdentifier, Compartment> _compartmentByIdentifier;

  bool get hasStoragePlace => storagePlaces.isNotEmpty;

  /// Active compartments of every active storage place, in display order.
  List<Compartment> get activeCompartments => [
    for (final storagePlace in storagePlaces) ...storagePlace.compartments,
  ];

  /// Archived compartments of the given storage place, for the "removed compartments" note.
  List<Compartment> archivedCompartmentsOf(StoragePlaceIdentifier storagePlaceIdentifier) => [
    for (final compartment in _compartmentByIdentifier.values)
      if (compartment.isArchived && compartment.storagePlaceIdentifier == storagePlaceIdentifier)
        compartment,
  ]..sort((first, second) => first.defaultNumber.compareTo(second.defaultNumber));

  /// Any storage place, archived ones included.
  StoragePlace? storagePlaceOf(StoragePlaceIdentifier storagePlaceIdentifier) =>
      _storagePlaceByIdentifier[storagePlaceIdentifier];

  /// An active storage place with its active compartments.
  StoragePlaceLayout? storagePlaceLayoutOf(StoragePlaceIdentifier storagePlaceIdentifier) {
    for (final storagePlaceLayout in storagePlaces) {
      if (storagePlaceLayout.storagePlace.identifier == storagePlaceIdentifier) {
        return storagePlaceLayout;
      }
    }
    return null;
  }

  /// Any compartment, archived ones included.
  Compartment? compartmentOf(CompartmentIdentifier compartmentIdentifier) =>
      _compartmentByIdentifier[compartmentIdentifier];

  /// Position of a compartment in [activeCompartments]; archived ones sort last.
  int displayPositionOf(CompartmentIdentifier compartmentIdentifier) {
    final position = activeCompartments.indexWhere(
      (compartment) => compartment.identifier == compartmentIdentifier,
    );
    return position < 0 ? activeCompartments.length : position;
  }
}
