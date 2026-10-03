import 'package:core_events/core_events.dart';

import 'compartment.dart';

/// What the layout needs to know about the items stored in compartments.
///
/// The storage layout cannot depend on the inventory (the inventory depends on
/// the layout), so the inventory implements this port and binds it through
/// its module's provider overrides. Without an inventory every compartment
/// counts as empty.
abstract interface class CompartmentContentsPort {
  /// Number of items (stock batches) per compartment; compartments without
  /// items may be missing from the map.
  Stream<Map<CompartmentIdentifier, int>> watchItemCountsByCompartment();

  Future<int> countItemsInCompartment(CompartmentIdentifier compartmentIdentifier);

  /// Moves every item from [sourceCompartmentIdentifier] to
  /// [destinationCompartmentIdentifier] and records the moves.
  ///
  /// Runs inside the caller's transaction and must not publish events itself:
  /// it returns the events, which the caller publishes after the commit.
  Future<List<DomainEvent>> moveAllContents({
    required CompartmentIdentifier sourceCompartmentIdentifier,
    required CompartmentIdentifier destinationCompartmentIdentifier,
  });
}

/// The port used while no inventory module is registered: nothing is stored.
final class EmptyCompartmentContents implements CompartmentContentsPort {
  const EmptyCompartmentContents();

  @override
  Stream<Map<CompartmentIdentifier, int>> watchItemCountsByCompartment() => Stream.value(const {});

  @override
  Future<int> countItemsInCompartment(CompartmentIdentifier compartmentIdentifier) async => 0;

  @override
  Future<List<DomainEvent>> moveAllContents({
    required CompartmentIdentifier sourceCompartmentIdentifier,
    required CompartmentIdentifier destinationCompartmentIdentifier,
  }) async => const [];
}
