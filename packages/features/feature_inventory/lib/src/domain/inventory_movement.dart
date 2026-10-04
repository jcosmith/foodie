import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:meta/meta.dart';

import 'stock_batch.dart';

typedef InventoryMovementIdentifier = TypedIdentifier<InventoryMovement>;

/// What happened to a batch. Stored by name; never rename a value.
enum MovementKind {
  added,
  consumed,
  discarded,
  moved,
  corrected;

  String get storageName => name;

  static MovementKind fromStorageName(String storageName) => MovementKind.values.firstWhere(
    (kind) => kind.storageName == storageName,
    orElse: () => throw ArgumentError.value(storageName, 'storageName', 'Unknown movement kind'),
  );
}

/// Why something was thrown away; feeds the "waste by reason" chart.
enum DiscardReason {
  tooOld,
  freezerBurn,
  expired,
  spoiled,
  unwanted,
  other;

  String get storageName => name;

  /// The reasons the discard sheet offers; freezer burn only for frozen food.
  static List<DiscardReason> offeredFor({required bool isFrozen}) => [
    for (final reason in values)
      if (reason != freezerBurn || isFrozen) reason,
  ];

  static DiscardReason fromStorageName(String storageName) => DiscardReason.values.firstWhere(
    (reason) => reason.storageName == storageName,
    orElse: () => throw ArgumentError.value(storageName, 'storageName', 'Unknown discard reason'),
  );
}

/// One entry of the append-only movement log. Never updated or deleted.
@immutable
final class InventoryMovement {
  const InventoryMovement({
    required this.identifier,
    required this.stockBatchIdentifier,
    required this.productIdentifier,
    required this.compartmentIdentifier,
    required this.kind,
    required this.quantityDelta,
    required this.occurredAt,
    this.discardReason,
    this.reversesMovementIdentifier,
  });

  final InventoryMovementIdentifier identifier;
  final StockBatchIdentifier stockBatchIdentifier;
  final ProductIdentifier productIdentifier;

  /// Where the batch was when this happened; for moves, the compartment the
  /// quantity left (negative delta) or arrived in (positive delta).
  final CompartmentIdentifier compartmentIdentifier;

  final MovementKind kind;

  /// Change of the batch's quantity; negative for removals.
  final Quantity quantityDelta;

  final DiscardReason? discardReason;

  /// Set on an undo: a movement of the same kind with the opposite delta, so
  /// sums per kind stay right and the log stays append-only.
  final InventoryMovementIdentifier? reversesMovementIdentifier;

  final DateTime occurredAt;

  bool get isReversal => reversesMovementIdentifier != null;
}
