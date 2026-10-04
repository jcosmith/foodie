import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'compartment.dart';
import 'storage_kind.dart';
import 'storage_place.dart';

/// One storage place with its active compartments in the user's order.
@immutable
final class StoragePlaceLayout {
  const StoragePlaceLayout({
    required this.storagePlace,
    required this.compartments,
    this.domainIdentifier,
  });

  final StoragePlace storagePlace;
  final List<Compartment> compartments;

  /// The domain of the place's kind; `null` when no registered module knows
  /// the kind.
  final StorageDomainIdentifier? domainIdentifier;
}

/// The whole layout as a read model: active storage places in order, each with its
/// active compartments, plus everything archived for historical names.
@immutable
final class StorageLayout {
  const StorageLayout._({
    required this.storagePlaces,
    required Map<StoragePlaceIdentifier, StoragePlace> storagePlaceByIdentifier,
    required Map<CompartmentIdentifier, Compartment> compartmentByIdentifier,
    required Map<StorageKind, StorageDomainIdentifier> domainOfStorageKind,
  }) : _storagePlaceByIdentifier = storagePlaceByIdentifier,
       _compartmentByIdentifier = compartmentByIdentifier,
       _domainOfStorageKind = domainOfStorageKind;

  /// Builds the read model from flat lists, archived entries included.
  /// [domainOfStorageKind] tells which domain each known kind belongs to.
  factory StorageLayout.fromEntities({
    required List<StoragePlace> storagePlacesIncludingArchived,
    required List<Compartment> compartmentsIncludingArchived,
    Map<StorageKind, StorageDomainIdentifier> domainOfStorageKind = const {},
  }) {
    final activeStoragePlaces =
        storagePlacesIncludingArchived.where((storagePlace) => !storagePlace.isArchived).toList()
          ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
    return StorageLayout._(
      storagePlaces: [
        for (final storagePlace in activeStoragePlaces)
          StoragePlaceLayout(
            storagePlace: storagePlace,
            domainIdentifier: domainOfStorageKind[storagePlace.storageKind],
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
      domainOfStorageKind: domainOfStorageKind,
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
  final Map<StorageKind, StorageDomainIdentifier> _domainOfStorageKind;

  bool get hasStoragePlace => storagePlaces.isNotEmpty;

  /// Active compartments of every active storage place, in display order.
  List<Compartment> get activeCompartments => [
    for (final storagePlace in storagePlaces) ...storagePlace.compartments,
  ];

  /// Active storage places of one domain, in the user's order.
  List<StoragePlaceLayout> storagePlacesIn(StorageDomainIdentifier domainIdentifier) => [
    for (final storagePlace in storagePlaces)
      if (storagePlace.domainIdentifier == domainIdentifier) storagePlace,
  ];

  /// Active compartments of the active storage places of one domain.
  List<Compartment> activeCompartmentsIn(StorageDomainIdentifier domainIdentifier) => [
    for (final storagePlace in storagePlacesIn(domainIdentifier)) ...storagePlace.compartments,
  ];

  /// The domain of any storage place, archived ones included.
  StorageDomainIdentifier? domainOfStoragePlace(StoragePlaceIdentifier storagePlaceIdentifier) {
    final storagePlace = _storagePlaceByIdentifier[storagePlaceIdentifier];
    return storagePlace == null ? null : _domainOfStorageKind[storagePlace.storageKind];
  }

  /// The domain of any compartment, archived ones included.
  StorageDomainIdentifier? domainOfCompartment(CompartmentIdentifier compartmentIdentifier) {
    final compartment = _compartmentByIdentifier[compartmentIdentifier];
    return compartment == null ? null : domainOfStoragePlace(compartment.storagePlaceIdentifier);
  }

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
