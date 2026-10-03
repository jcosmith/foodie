import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

final class _StockEvent extends DomainEvent {
  _StockEvent() : super(occurredAt: DateTime.utc(2026, 10, 2));
}

final class _StockBatchConsumed extends _StockEvent {}

final class _ProductCreated extends DomainEvent {
  _ProductCreated() : super(occurredAt: DateTime.utc(2026, 10, 2));
}

void main() {
  group('InProcessDomainEventBus', () {
    test('delivers events to subscribers of the type and its supertypes', () async {
      final eventBus = InProcessDomainEventBus(logger: RecordingLogger());
      final receivedByConsumedSubscriber = <DomainEvent>[];
      final receivedByStockSubscriber = <DomainEvent>[];
      eventBus
        ..subscribe<_StockBatchConsumed>(receivedByConsumedSubscriber.add)
        ..subscribe<_StockEvent>(receivedByStockSubscriber.add);

      await eventBus.publish(_StockBatchConsumed());
      await eventBus.publish(_ProductCreated());

      expect(receivedByConsumedSubscriber, hasLength(1));
      expect(receivedByStockSubscriber, hasLength(1));
    });

    test('a failing subscriber does not stop the others and is logged', () async {
      final logger = RecordingLogger();
      final eventBus = InProcessDomainEventBus(logger: logger);
      var secondSubscriberCalled = false;
      eventBus
        ..subscribe<_StockBatchConsumed>((_) => throw StateError('broken subscriber'))
        ..subscribe<_StockBatchConsumed>((_) => secondSubscriberCalled = true);

      await eventBus.publish(_StockBatchConsumed());

      expect(secondSubscriberCalled, isTrue);
      expect(logger.recordedEntries.single.severity, LogSeverity.error);
    });

    test('awaits asynchronous subscribers in order', () async {
      final eventBus = InProcessDomainEventBus(logger: RecordingLogger());
      final callOrder = <String>[];
      eventBus
        ..subscribe<_StockBatchConsumed>((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          callOrder.add('restock');
        })
        ..subscribe<_StockBatchConsumed>((_) => callOrder.add('reminders'));

      await eventBus.publish(_StockBatchConsumed());

      expect(callOrder, ['restock', 'reminders']);
    });

    test('cancelled subscriptions receive nothing', () async {
      final eventBus = InProcessDomainEventBus(logger: RecordingLogger());
      var callCount = 0;
      final subscription = eventBus.subscribe<_StockBatchConsumed>((_) => callCount++);

      await eventBus.publish(_StockBatchConsumed());
      await subscription.cancel();
      await eventBus.publish(_StockBatchConsumed());

      expect(callCount, 1);
    });
  });
}
