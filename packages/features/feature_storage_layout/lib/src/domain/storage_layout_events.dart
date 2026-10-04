import 'package:core_events/core_events.dart';

import 'compartment.dart';
import 'storage_place.dart';

/// A compartment was added, on its own or as part of a new storage place.
final class CompartmentCreated extends DomainEvent {
  const CompartmentCreated({
    required this.compartmentIdentifier,
    required this.storagePlaceIdentifier,
    required super.occurredAt,
  });

  final CompartmentIdentifier compartmentIdentifier;
  final StoragePlaceIdentifier storagePlaceIdentifier;
}

/// A compartment got a new name, or went back to its default name.
final class CompartmentRenamed extends DomainEvent {
  const CompartmentRenamed({required this.compartmentIdentifier, required super.occurredAt});

  final CompartmentIdentifier compartmentIdentifier;
}

/// The compartments of a storage place, or the storage places themselves, changed order.
final class CompartmentReordered extends DomainEvent {
  const CompartmentReordered({required this.storagePlaceIdentifier, required super.occurredAt});

  /// The storage place whose compartments moved; `null` when storage places were reordered.
  final StoragePlaceIdentifier? storagePlaceIdentifier;
}

/// A compartment was removed from the layout. It stays in the database so
/// past statistics keep its name.
final class CompartmentArchived extends DomainEvent {
  const CompartmentArchived({
    required this.compartmentIdentifier,
    required this.contentsMovedToCompartmentIdentifier,
    required super.occurredAt,
  });

  final CompartmentIdentifier compartmentIdentifier;

  /// Where its items went, if it held any.
  final CompartmentIdentifier? contentsMovedToCompartmentIdentifier;
}
