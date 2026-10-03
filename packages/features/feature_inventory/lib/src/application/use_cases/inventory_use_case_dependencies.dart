import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/inventory_repository.dart';

/// What every inventory use case needs; bundled so constructors stay short.
final class InventoryUseCaseDependencies {
  const InventoryUseCaseDependencies({
    required this.repository,
    required this.transactionRunner,
    required this.domainEventBus,
    required this.clock,
    required this.identifierGenerator,
  });

  final InventoryRepository repository;
  final TransactionRunner transactionRunner;
  final DomainEventBus domainEventBus;
  final Clock clock;
  final IdentifierGenerator identifierGenerator;

  /// Publishes after the transaction committed (decision D5).
  Future<void> publishAll(Iterable<DomainEvent> events) async {
    for (final event in events) {
      await domainEventBus.publish(event);
    }
  }
}
