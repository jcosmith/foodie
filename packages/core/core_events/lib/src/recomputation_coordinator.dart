import 'dart:async';

import 'package:core_foundation/core_foundation.dart';

import 'domain_event_bus.dart';

/// Recomputes something a module derives from the database (scheduled
/// notifications, the shopping list) whenever what it depends on changes:
/// domain events or settings. Events are hints and the database is the
/// truth, so each run recomputes everything; bursts of changes are folded
/// into one run (architecture document, decision D6).
final class RecomputationCoordinator {
  RecomputationCoordinator({
    required this.description,
    required List<DomainEventSubscription> Function(Future<void> Function() requestRecomputation)
    subscribeToEvents,
    required List<Stream<Object?>> settingChanges,
    required Future<void> Function() recompute,
    required LocalLogger logger,
  }) : _subscribeToEvents = subscribeToEvents,
       _settingChanges = settingChanges,
       _recompute = recompute,
       _logger = logger;

  /// Names what is recomputed in log entries, for example "storage reminders".
  final String description;
  final List<DomainEventSubscription> Function(Future<void> Function() requestRecomputation)
  _subscribeToEvents;
  final List<Stream<Object?>> _settingChanges;
  final Future<void> Function() _recompute;
  final LocalLogger _logger;

  final List<DomainEventSubscription> _eventSubscriptions = [];
  final List<StreamSubscription<Object?>> _settingSubscriptions = [];
  Future<void> _latestRecomputation = Future.value();
  Future<void>? _queuedRecomputation;

  bool _isStarted = false;

  /// Subscribes to changes and recomputes once.
  Future<void> start() {
    if (!_isStarted) {
      _isStarted = true;
      _eventSubscriptions.addAll(_subscribeToEvents(requestRecomputation));
      for (final changes in _settingChanges) {
        // The first value is the current one, which the run below covers.
        _settingSubscriptions.add(changes.skip(1).listen((_) => requestRecomputation()));
      }
    }
    return requestRecomputation();
  }

  /// Runs after the current run; requests that arrive while one is waiting
  /// share it.
  Future<void> requestRecomputation() {
    if (_queuedRecomputation case final queuedRecomputation?) return queuedRecomputation;
    final recomputation = _latestRecomputation.then((_) {
      _queuedRecomputation = null;
      return _recomputeLoggingFailures();
    });
    _queuedRecomputation = recomputation;
    _latestRecomputation = recomputation;
    return recomputation;
  }

  Future<void> stop() async {
    for (final subscription in _eventSubscriptions) {
      await subscription.cancel();
    }
    for (final subscription in _settingSubscriptions) {
      await subscription.cancel();
    }
    _eventSubscriptions.clear();
    _settingSubscriptions.clear();
    _isStarted = false;
  }

  Future<void> _recomputeLoggingFailures() async {
    try {
      await _recompute();
    } on Object catch (error, stackTrace) {
      // Derived state must never break the app; the next change or start retries.
      _logger.log(
        LogSeverity.error,
        'Recomputing $description failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
