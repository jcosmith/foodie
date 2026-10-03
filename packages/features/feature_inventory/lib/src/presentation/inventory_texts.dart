import 'package:core_design_system/core_design_system.dart';

import '../domain/inventory_failure.dart';
import '../domain/inventory_movement.dart';
import '../domain/storage_age_policy.dart';
import '../l10n/generated/inventory_localizations.dart';

extension InventoryTexts on InventoryLocalizations {
  String describeFailure(InventoryFailure failure) => switch (failure) {
    QuantityNotPositive() => quantityNotPositive,
    QuantityExceedsRemaining() => quantityExceedsRemaining,
    ProductNotAvailable() => productMissing,
    CompartmentNotAvailable() => compartmentMissing,
    FrozenOnInFuture() => frozenOnInFuture,
    QuantityUnitMismatch() ||
    StockBatchNotFound() ||
    AlreadyInCompartment() ||
    QuantityUnchanged() ||
    MovementCannotBeUndone() => genericFailure,
  };

  String discardReasonName(DiscardReason discardReason) => switch (discardReason) {
    DiscardReason.tooOld => reasonTooOld,
    DiscardReason.freezerBurn => reasonFreezerBurn,
    DiscardReason.unwanted => reasonUnwanted,
    DiscardReason.other => reasonOther,
  };
}

extension StorageAgeStatusLevel on StorageAgeStatus {
  StorageAgeLevel get level => switch (this) {
    StorageAgeStatus.fresh => StorageAgeLevel.fresh,
    StorageAgeStatus.aging => StorageAgeLevel.aging,
    StorageAgeStatus.urgent => StorageAgeLevel.urgent,
    StorageAgeStatus.overdue => StorageAgeLevel.overdue,
  };
}
