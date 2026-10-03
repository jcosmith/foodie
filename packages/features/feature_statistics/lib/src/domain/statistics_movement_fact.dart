import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:meta/meta.dart';

import 'statistics_filter.dart';

/// Why something was thrown away, as recorded by the inventory.
enum StatisticsDiscardReason {
  tooOld,
  freezerBurn,
  unwanted,
  other,

  /// Thrown away without a reason.
  notGiven;

  static StatisticsDiscardReason fromStorageName(String? storageName) {
    for (final reason in values) {
      if (reason != notGiven && reason.name == storageName) return reason;
    }
    return notGiven;
  }
}

/// Movements of one day that share activity, product, compartment, discard
/// reason and storage age, summed. The unit of analysis of every chart.
@immutable
final class StatisticsMovementFact {
  const StatisticsMovementFact({
    required this.day,
    required this.activity,
    required this.productIdentifier,
    required this.categoryIdentifier,
    required this.compartmentIdentifier,
    required this.quantity,
    required this.movementCount,
    required this.storedDays,
    this.discardReason = StatisticsDiscardReason.notGiven,
  });

  final CalendarDate day;
  final StatisticsActivity activity;
  final ProductIdentifier productIdentifier;
  final CategoryIdentifier categoryIdentifier;
  final CompartmentIdentifier compartmentIdentifier;

  /// Always positive: what was added, eaten, thrown away or moved.
  final Quantity quantity;

  /// Number of movements; each one is one item taken out, put in or moved.
  final int movementCount;

  /// Days between freezing and this movement.
  final int storedDays;
  final StatisticsDiscardReason discardReason;
}
