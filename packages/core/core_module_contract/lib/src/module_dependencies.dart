import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter_riverpod/misc.dart';

/// Shared services the app shell hands to every module when it builds the
/// module's provider overrides.
final class ModuleDependencies {
  const ModuleDependencies({
    required this.clock,
    required this.identifierGenerator,
    required this.domainEventBus,
    required this.logger,
  });

  final Clock clock;
  final IdentifierGenerator identifierGenerator;
  final DomainEventBus domainEventBus;
  final LocalLogger logger;
}

/// What a module gets when it is initialised at application start.
abstract interface class ModuleInitializationContext {
  DomainEventBus get domainEventBus;

  Clock get clock;

  LocalLogger get logger;

  /// Reads a provider from the application's provider container, for example
  /// the module's own repository to run start-up reconciliation.
  TValue read<TValue>(ProviderListenable<TValue> provider);
}
