import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:meta/meta.dart';

typedef StockBatchIdentifier = TypedIdentifier<StockBatch>;

/// One physical bag or box in a compartment, with its freezing date.
///
/// [quantityRemaining] is the fast current state; the movement log is the
/// history. Both change together in one transaction.
@immutable
final class StockBatch {
  const StockBatch({
    required this.identifier,
    required this.productIdentifier,
    required this.compartmentIdentifier,
    required this.initialQuantity,
    required this.quantityRemaining,
    required this.frozenOn,
    required this.createdAt,
    this.parentBatchIdentifier,
    this.bestBeforeOn,
    this.note,
  });

  final StockBatchIdentifier identifier;
  final ProductIdentifier productIdentifier;
  final CompartmentIdentifier compartmentIdentifier;
  final Quantity initialQuantity;
  final Quantity quantityRemaining;

  /// Set when this batch was split off another one; it keeps that batch's
  /// freezing date.
  final StockBatchIdentifier? parentBatchIdentifier;

  /// Storage age counts from here, also after partial removals.
  final CalendarDate frozenOn;

  final CalendarDate? bestBeforeOn;
  final String? note;
  final DateTime createdAt;

  QuantityUnit get unit => initialQuantity.unit;

  /// Empty batches are hidden but kept for statistics.
  bool get isDepleted => !quantityRemaining.isPositive;

  /// How much of the original package is left, between 0 and 1.
  double get remainingShare => initialQuantity.isPositive
      ? (quantityRemaining.amountInBaseUnits / initialQuantity.amountInBaseUnits).clamp(0, 1)
      : 0;

  StockBatch copyWith({
    Quantity? quantityRemaining,
    CompartmentIdentifier? compartmentIdentifier,
  }) => StockBatch(
    identifier: identifier,
    productIdentifier: productIdentifier,
    compartmentIdentifier: compartmentIdentifier ?? this.compartmentIdentifier,
    initialQuantity: initialQuantity,
    quantityRemaining: quantityRemaining ?? this.quantityRemaining,
    parentBatchIdentifier: parentBatchIdentifier,
    frozenOn: frozenOn,
    bestBeforeOn: bestBeforeOn,
    note: note,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is StockBatch &&
      other.identifier == identifier &&
      other.productIdentifier == productIdentifier &&
      other.compartmentIdentifier == compartmentIdentifier &&
      other.initialQuantity == initialQuantity &&
      other.quantityRemaining == quantityRemaining &&
      other.parentBatchIdentifier == parentBatchIdentifier &&
      other.frozenOn == frozenOn &&
      other.bestBeforeOn == bestBeforeOn &&
      other.note == note &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    identifier,
    productIdentifier,
    compartmentIdentifier,
    initialQuantity,
    quantityRemaining,
    parentBatchIdentifier,
    frozenOn,
    bestBeforeOn,
    note,
    createdAt,
  );
}
