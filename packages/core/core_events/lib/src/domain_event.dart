import 'package:meta/meta.dart';

/// Something that happened in one feature and that other features may react to.
///
/// Events are named in the past tense (`StockBatchConsumed`), are immutable and
/// are published only after the database transaction that caused them has
/// committed. They are hints, not the source of truth (decision D5): every
/// subscriber re-reads the database and must be idempotent, and the same
/// recomputation runs at application start, so a lost event never corrupts state.
@immutable
abstract base class DomainEvent {
  const DomainEvent({required this.occurredAt});

  /// When the change happened, in UTC.
  final DateTime occurredAt;
}
