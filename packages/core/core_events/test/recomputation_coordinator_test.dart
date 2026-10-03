import 'dart:async';

import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

final class _SomethingChanged extends DomainEvent {
  _SomethingChanged() : super(occurredAt: DateTime.utc(2026, 10, 2));
}

void main() {
  late InProcessDomainEventBus domainEventBus;
  late StreamController<int> settingChanges;
  late RecordingLogger logger;
  late int recomputationCount;
  late Completer<void>? blockingRecomputation;
  late RecomputationCoordinator coordinator;

  setUp(() {
    domainEventBus = InProcessDomainEventBus(logger: RecordingLogger());
    settingChanges = StreamController<int>.broadcast();
    logger = RecordingLogger();
    recomputationCount = 0;
    blockingRecomputation = null;
    coordinator = RecomputationCoordinator(
      description: 'the test state',
      subscribeToEvents: (requestRecomputation) => [
        domainEventBus.subscribe<_SomethingChanged>((_) => requestRecomputation()),
      ],
      settingChanges: [settingChanges.stream],
      recompute: () async {
        recomputationCount++;
        await blockingRecomputation?.future;
      },
      logger: logger,
    );
  });
  tearDown(() async {
    await coordinator.stop();
    await settingChanges.close();
  });

  test('recomputes at start and after events, skipping the first setting value', () async {
    await coordinator.start();
    settingChanges.add(1);
    await Future<void>.delayed(Duration.zero);
    await domainEventBus.publish(_SomethingChanged());

    // Start, then the event; the first setting value is the current one.
    expect(recomputationCount, 2);
  });

  test('requests that arrive during a run share one follow-up run', () async {
    await coordinator.start();
    blockingRecomputation = Completer<void>();
    final running = coordinator.requestRecomputation();
    await Future<void>.delayed(Duration.zero);
    final followUps = [for (var index = 0; index < 5; index++) coordinator.requestRecomputation()];
    blockingRecomputation!.complete();
    await Future.wait([running, ...followUps]);

    expect(recomputationCount, 3);
  });

  test('logs a failing run and keeps working', () async {
    var shouldFail = true;
    final failingCoordinator = RecomputationCoordinator(
      description: 'the test state',
      subscribeToEvents: (_) => const [],
      settingChanges: const [],
      recompute: () async {
        if (shouldFail) throw StateError('broken');
      },
      logger: logger,
    );

    await failingCoordinator.start();
    shouldFail = false;
    await failingCoordinator.requestRecomputation();

    expect(logger.recordedEntries.single.message, 'Recomputing the test state failed');
  });
}
