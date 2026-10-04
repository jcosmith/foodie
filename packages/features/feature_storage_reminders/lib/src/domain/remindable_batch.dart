import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/domain.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:meta/meta.dart';

/// A batch at home that has a use-by deadline, as the planner sees it.
@immutable
final class RemindableBatch {
  const RemindableBatch({
    required this.stockBatchIdentifier,
    required this.productIdentifier,
    required this.storedSince,
    required this.deadline,
  });

  final StockBatchIdentifier stockBatchIdentifier;
  final ProductIdentifier productIdentifier;

  /// The local day the batch was put into the app. Food entered when it is
  /// already old is due from this day, not from a day in the past.
  final CalendarDate storedSince;

  /// The earliest of shelf life, best-before and opened dates.
  final UseByDeadline deadline;

  /// The first day the batch should be used now, as the badge shows it.
  CalendarDate get useSoonFrom => _notBefore(deadline.firstDayWithStatus(UseByStatus.urgent));

  /// The first day the batch is overdue.
  CalendarDate get overdueFrom => _notBefore(deadline.overdueFrom);

  bool isDueOn(CalendarDate day) => !day.isBefore(useSoonFrom);

  CalendarDate _notBefore(CalendarDate day) => day.isBefore(storedSince) ? storedSince : day;
}
