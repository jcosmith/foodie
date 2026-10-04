import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:intl/intl.dart';

import '../application/inventory_overview.dart';
import '../domain/inventory_failure.dart';
import '../domain/inventory_movement.dart';
import '../domain/use_by_policy.dart';
import '../l10n/generated/inventory_localizations.dart';

extension InventoryTexts on InventoryLocalizations {
  String describeFailure(InventoryFailure failure) => switch (failure) {
    QuantityNotPositive() => quantityNotPositive,
    QuantityExceedsRemaining() => quantityExceedsRemaining,
    ProductNotAvailable() => productMissing,
    CompartmentNotAvailable() => compartmentMissing,
    StoredOnInFuture() => storedOnInFuture,
    QuantityUnitMismatch() ||
    StockBatchNotFound() ||
    AlreadyInCompartment() ||
    QuantityUnchanged() ||
    MovementCannotBeUndone() => genericFailure,
  };

  String discardReasonName(DiscardReason discardReason) => switch (discardReason) {
    DiscardReason.tooOld => reasonTooOld,
    DiscardReason.freezerBurn => reasonFreezerBurn,
    DiscardReason.expired => reasonExpired,
    DiscardReason.spoiled => reasonSpoiled,
    DiscardReason.unwanted => reasonUnwanted,
    DiscardReason.other => reasonOther,
  };
}

extension UseByStatusLevel on UseByStatus {
  StorageAgeLevel get level => switch (this) {
    UseByStatus.fresh => StorageAgeLevel.fresh,
    UseByStatus.aging => StorageAgeLevel.aging,
    UseByStatus.urgent => StorageAgeLevel.urgent,
    UseByStatus.overdue => StorageAgeLevel.overdue,
  };
}

extension UseByBadgeTexts on InventoryLocalizations {
  /// What a due item's badge says instead of its level's word: "Use today",
  /// "Use by tomorrow", "Use by Mon" within a week, "Past best before" once
  /// the best-before date has passed. `null` keeps the level's word.
  String? useByBadgeLabel(InventoryItem item, CalendarDate today) {
    final useBy = item.useBy;
    if (useBy == null || item.useByStatus == UseByStatus.fresh) return null;
    final daysLeft = useBy.daysLeftOn(today);
    if (daysLeft < 0) return useBy.reason == UseByReason.bestBefore ? pastBestBefore : null;
    if (daysLeft == 0) return useToday;
    if (daysLeft == 1) return useByTomorrow;
    if (daysLeft < 7) {
      return useByWeekday(DateFormat.E(localeName).format(useBy.lastGoodDay.toLocalDateTime()));
    }
    return null;
  }
}
