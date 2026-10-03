import 'package:core_foundation/core_foundation.dart';

import 'l10n/generated/common_localizations.dart';

/// Formats how long ago something happened, such as "3 months ago".
///
/// Uses days below two weeks, weeks below two months, months below two years
/// and years after that, which matches how people talk about freezer contents.
final class StorageAgeFormatter {
  const StorageAgeFormatter(this._localizations);

  static const double _averageDaysPerMonth = 30.4;

  final CommonLocalizations _localizations;

  String formatRelativeAge({required CalendarDate since, required CalendarDate today}) =>
      formatAgeInDays(since.daysUntil(today));

  String formatAgeInDays(int ageInDays) {
    if (ageInDays <= 0) return _localizations.relativeAgeToday;
    if (ageInDays == 1) return _localizations.relativeAgeYesterday;
    if (ageInDays < 14) return _localizations.relativeAgeDays(ageInDays);
    if (ageInDays < 60) return _localizations.relativeAgeWeeks((ageInDays / 7).round());
    if (ageInDays < 730) {
      return _localizations.relativeAgeMonths((ageInDays / _averageDaysPerMonth).round());
    }
    return _localizations.relativeAgeYears((ageInDays / 365).floor());
  }
}
