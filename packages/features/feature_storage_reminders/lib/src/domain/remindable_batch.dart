import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

/// A batch in the freezer that has a storage limit, as the planner sees it.
@immutable
final class RemindableBatch {
  const RemindableBatch({
    required this.stockBatchIdentifier,
    required this.productIdentifier,
    required this.frozenOn,
    required this.storedSince,
    required this.recommendedMaximumStorageDays,
  });

  final StockBatchIdentifier stockBatchIdentifier;
  final ProductIdentifier productIdentifier;

  /// The storage age counts from here.
  final CalendarDate frozenOn;

  /// The local day the batch was put into the app. Food entered when it is
  /// already old is due from this day, not from a day in the past.
  final CalendarDate storedSince;

  final int recommendedMaximumStorageDays;

  /// The first day the batch should be eaten soon, as the badge shows it.
  CalendarDate get eatSoonFrom => _notBefore(
    StorageAgePolicy.firstDayWithStatus(
      frozenOn: frozenOn,
      recommendedMaximumStorageDays: recommendedMaximumStorageDays,
      status: StorageAgeStatus.urgent,
    ),
  );

  /// The day its recommended storage time is used up.
  CalendarDate get storageLimitReachedOn => _notBefore(
    StorageAgePolicy.storageLimitReachedOn(
      frozenOn: frozenOn,
      recommendedMaximumStorageDays: recommendedMaximumStorageDays,
    ),
  );

  double storageShareOn(CalendarDate day) => StorageAgePolicy.storageShare(
    frozenOn: frozenOn,
    today: day,
    recommendedMaximumStorageDays: recommendedMaximumStorageDays,
  );

  bool isEatSoonOn(CalendarDate day) => !day.isBefore(eatSoonFrom);

  CalendarDate _notBefore(CalendarDate day) => day.isBefore(storedSince) ? storedSince : day;
}
