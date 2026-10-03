/// Riverpod providers for the foundation services.
///
/// Kept out of the main library so domain code, which imports only
/// `core_foundation.dart`, never depends on Riverpod (decision D1).
library;

import 'package:riverpod/riverpod.dart';

import 'core_foundation.dart';

/// The clock used everywhere. Tests override it with a [FixedClock].
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Creates new entity identifiers. Tests override it with a [SequentialIdentifierGenerator].
final identifierGeneratorProvider = Provider<IdentifierGenerator>(
  (ref) => const UuidIdentifierGenerator(),
);

/// Local-only logging; nothing is ever sent off the device.
final localLoggerProvider = Provider<LocalLogger>((ref) => const DeveloperConsoleLogger());
