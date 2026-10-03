import 'package:core_foundation/core_foundation.dart';
import 'package:intl/intl.dart';

/// Formats calendar dates in the user's language: "3 Mar 2026" or "3. März 2026".
final class DateDisplayFormatter {
  DateDisplayFormatter(String localeName)
    : _mediumDateFormat = DateFormat.yMMMd(localeName),
      _shortDateFormat = DateFormat.MMMd(localeName);

  final DateFormat _mediumDateFormat;
  final DateFormat _shortDateFormat;

  /// Day, month and year, for example on a batch detail.
  String formatMediumDate(CalendarDate date) => _mediumDateFormat.format(date.toLocalDateTime());

  /// Day and month only, for compact lists and chart axes.
  String formatShortDate(CalendarDate date) => _shortDateFormat.format(date.toLocalDateTime());
}
