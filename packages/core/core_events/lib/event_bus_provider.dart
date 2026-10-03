/// The Riverpod provider for the application-wide [DomainEventBus].
library;

import 'package:core_foundation/foundation_providers.dart';
import 'package:riverpod/riverpod.dart';

import 'core_events.dart';

/// One event bus for the whole app; modules subscribe during initialisation.
final domainEventBusProvider = Provider<DomainEventBus>(
  (ref) => InProcessDomainEventBus(logger: ref.watch(localLoggerProvider)),
);
