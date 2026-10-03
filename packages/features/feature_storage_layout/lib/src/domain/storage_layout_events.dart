import 'package:core_events/core_events.dart';

import 'compartment.dart';
import 'freezer.dart';

/// A compartment was added, on its own or as part of a new freezer.
final class CompartmentCreated extends DomainEvent {
  const CompartmentCreated({
    required this.compartmentIdentifier,
    required this.freezerIdentifier,
    required super.occurredAt,
  });

  final CompartmentIdentifier compartmentIdentifier;
  final FreezerIdentifier freezerIdentifier;
}

/// A compartment got a new name, or went back to its default name.
final class CompartmentRenamed extends DomainEvent {
  const CompartmentRenamed({required this.compartmentIdentifier, required super.occurredAt});

  final CompartmentIdentifier compartmentIdentifier;
}

/// The compartments of a freezer, or the freezers themselves, changed order.
final class CompartmentReordered extends DomainEvent {
  const CompartmentReordered({required this.freezerIdentifier, required super.occurredAt});

  /// The freezer whose compartments moved; `null` when freezers were reordered.
  final FreezerIdentifier? freezerIdentifier;
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
