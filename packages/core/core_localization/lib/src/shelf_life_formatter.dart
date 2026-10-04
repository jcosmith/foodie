import 'package:core_foundation/core_foundation.dart';

import 'l10n/generated/common_localizations.dart';

/// Says how long something keeps: "2 days", "3 weeks", "9 months".
final class ShelfLifeFormatter {
  const ShelfLifeFormatter(this._localizations);

  final CommonLocalizations _localizations;

  String format(ShelfLife shelfLife) => switch (shelfLife.unit) {
    ShelfLifeUnit.days => _localizations.shelfLifeDays(shelfLife.amount),
    ShelfLifeUnit.weeks => _localizations.shelfLifeWeeks(shelfLife.amount),
    ShelfLifeUnit.months => _localizations.shelfLifeMonths(shelfLife.amount),
  };

  /// Stored days in the unit they were entered in; days that fit no unit
  /// from two weeks on are rounded, with "about".
  String formatDays(int days) {
    final shelfLife = ShelfLife.fromDays(days);
    if (shelfLife.unit != ShelfLifeUnit.days || days < 14) return format(shelfLife);
    if (days < 60) return _localizations.shelfLifeAboutWeeks((days / 7).round());
    return _localizations.shelfLifeAboutMonths((days / ShelfLife.averageDaysPerMonth).round());
  }

  /// "days", "weeks", "months", for a unit picker.
  String unitName(ShelfLifeUnit unit) => switch (unit) {
    ShelfLifeUnit.days => _localizations.shelfLifeUnitDays,
    ShelfLifeUnit.weeks => _localizations.shelfLifeUnitWeeks,
    ShelfLifeUnit.months => _localizations.shelfLifeUnitMonths,
  };
}
