import 'dart:async';

import 'package:core_foundation/core_foundation.dart';

import 'domain_event.dart';

/// Handles one kind of event. May be asynchronous.
typedef DomainEventHandler<TEvent extends DomainEvent> = FutureOr<void> Function(TEvent event);

/// A live subscription; cancel it when the subscribing module is disposed.
abstract interface class DomainEventSubscription {
  Future<void> cancel();
}

/// In-process publish and subscribe for [DomainEvent]s.
///
/// Subscribers register for an event type and also receive its subtypes.
/// One failing subscriber never prevents the others from running: its error
/// is logged locally and dispatch continues.
abstract interface class DomainEventBus {
  /// Calls [handler] for every published event of type [TEvent] (or a subtype).
  DomainEventSubscription subscribe<TEvent extends DomainEvent>(DomainEventHandler<TEvent> handler);

  /// Delivers [event] to every matching subscriber.
  ///
  /// Call it after the transaction that produced the event has committed. The
  /// returned future completes when every handler has finished, which is
  /// mostly useful in tests; production code does not need to await it.
  Future<void> publish(DomainEvent event);
}

/// The default [DomainEventBus]: handlers run in subscription order.
final class InProcessDomainEventBus implements DomainEventBus {
  InProcessDomainEventBus({LocalLogger logger = const DeveloperConsoleLogger()}) : _logger = logger;

  final LocalLogger _logger;
  final List<_RegisteredHandler> _registeredHandlers = [];

  @override
  DomainEventSubscription subscribe<TEvent extends DomainEvent>(
    DomainEventHandler<TEvent> handler,
  ) {
    final registeredHandler = _RegisteredHandler(
      accepts: (event) => event is TEvent,
      handle: (event) => handler(event as TEvent),
      eventTypeDescription: '$TEvent',
    );
    _registeredHandlers.add(registeredHandler);
    return _InProcessSubscription(() => _registeredHandlers.remove(registeredHandler));
  }

  @override
  Future<void> publish(DomainEvent event) async {
    // Copy so handlers may subscribe or cancel while the event is dispatched.
    final matchingHandlers = _registeredHandlers
        .where((handler) => handler.accepts(event))
        .toList();
    for (final registeredHandler in matchingHandlers) {
      try {
        await registeredHandler.handle(event);
      } on Object catch (error, stackTrace) {
        _logger.log(
          LogSeverity.error,
          'Subscriber for ${registeredHandler.eventTypeDescription} failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }
}

final class _RegisteredHandler {
  _RegisteredHandler({
    required this.accepts,
    required this.handle,
    required this.eventTypeDescription,
  });

  final bool Function(DomainEvent event) accepts;
  final FutureOr<void> Function(DomainEvent event) handle;
  final String eventTypeDescription;
}

final class _InProcessSubscription implements DomainEventSubscription {
  _InProcessSubscription(this._unregister);

  final void Function() _unregister;
  bool _isCancelled = false;

  @override
  Future<void> cancel() async {
    if (_isCancelled) return;
    _isCancelled = true;
    _unregister();
  }
}
