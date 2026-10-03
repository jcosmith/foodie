import 'package:meta/meta.dart';

import 'compartment.dart';
import 'freezer.dart';

/// One freezer with its active compartments in the user's order.
@immutable
final class FreezerLayout {
  const FreezerLayout({required this.freezer, required this.compartments});

  final Freezer freezer;
  final List<Compartment> compartments;
}

/// The whole layout as a read model: active freezers in order, each with its
/// active compartments, plus everything archived for historical names.
@immutable
final class StorageLayout {
  const StorageLayout._({
    required this.freezers,
    required Map<FreezerIdentifier, Freezer> freezerByIdentifier,
    required Map<CompartmentIdentifier, Compartment> compartmentByIdentifier,
  }) : _freezerByIdentifier = freezerByIdentifier,
       _compartmentByIdentifier = compartmentByIdentifier;

  /// Builds the read model from flat lists, archived entries included.
  factory StorageLayout.fromEntities({
    required List<Freezer> freezersIncludingArchived,
    required List<Compartment> compartmentsIncludingArchived,
  }) {
    final activeFreezers =
        freezersIncludingArchived.where((freezer) => !freezer.isArchived).toList()
          ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
    return StorageLayout._(
      freezers: [
        for (final freezer in activeFreezers)
          FreezerLayout(
            freezer: freezer,
            compartments:
                compartmentsIncludingArchived
                    .where(
                      (compartment) =>
                          compartment.freezerIdentifier == freezer.identifier &&
                          !compartment.isArchived,
                    )
                    .toList()
                  ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder)),
          ),
      ],
      freezerByIdentifier: {
        for (final freezer in freezersIncludingArchived) freezer.identifier: freezer,
      },
      compartmentByIdentifier: {
        for (final compartment in compartmentsIncludingArchived)
          compartment.identifier: compartment,
      },
    );
  }

  static final StorageLayout empty = StorageLayout.fromEntities(
    freezersIncludingArchived: const [],
    compartmentsIncludingArchived: const [],
  );

  /// Active freezers in the user's order.
  final List<FreezerLayout> freezers;
  final Map<FreezerIdentifier, Freezer> _freezerByIdentifier;
  final Map<CompartmentIdentifier, Compartment> _compartmentByIdentifier;

  bool get hasFreezer => freezers.isNotEmpty;

  /// Active compartments of every active freezer, in display order.
  List<Compartment> get activeCompartments => [
    for (final freezer in freezers) ...freezer.compartments,
  ];

  /// Archived compartments of the given freezer, for the "removed drawers" note.
  List<Compartment> archivedCompartmentsOf(FreezerIdentifier freezerIdentifier) => [
    for (final compartment in _compartmentByIdentifier.values)
      if (compartment.isArchived && compartment.freezerIdentifier == freezerIdentifier) compartment,
  ]..sort((first, second) => first.defaultNumber.compareTo(second.defaultNumber));

  /// Any freezer, archived ones included.
  Freezer? freezerOf(FreezerIdentifier freezerIdentifier) =>
      _freezerByIdentifier[freezerIdentifier];

  /// An active freezer with its active compartments.
  FreezerLayout? freezerLayoutOf(FreezerIdentifier freezerIdentifier) {
    for (final freezerLayout in freezers) {
      if (freezerLayout.freezer.identifier == freezerIdentifier) return freezerLayout;
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
