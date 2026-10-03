import 'package:meta/meta.dart';

/// A date without a time of day or time zone, such as the day a bag was frozen.
///
/// Freezing dates are calendar dates, not instants: "frozen on 3 March" must
/// stay 3 March when the user travels across time zones.
@immutable
final class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate(this.year, this.month, this.day) {
    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year || normalized.month != month || normalized.day != day) {
      throw ArgumentError('Invalid calendar date: $year-$month-$day');
    }
  }

  /// Takes the year, month and day of [dateTime] as they are, ignoring time and zone.
  factory CalendarDate.fromDateTime(DateTime dateTime) =>
      CalendarDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses an ISO 8601 date such as `2026-03-03`.
  factory CalendarDate.parseIso8601(String text) {
    final match = _iso8601DatePattern.firstMatch(text);
    if (match == null) {
      throw FormatException('Expected a date like 2026-03-03', text);
    }
    return CalendarDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  /// Creates a date from the number of days since 1970-01-01.
  factory CalendarDate.fromDaysSinceEpoch(int daysSinceEpoch) =>
      CalendarDate.fromDateTime(DateTime.utc(1970).add(Duration(days: daysSinceEpoch)));

  static final RegExp _iso8601DatePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// Days since 1970-01-01; convenient for storage and date arithmetic.
  int get daysSinceEpoch => DateTime.utc(year, month, day).difference(DateTime.utc(1970)).inDays;

  /// Monday is 1 and Sunday is 7, as in [DateTime.weekday].
  int get weekday => DateTime.utc(year, month, day).weekday;

  CalendarDate addDays(int numberOfDays) =>
      CalendarDate.fromDaysSinceEpoch(daysSinceEpoch + numberOfDays);

  /// Whole days from this date until [other]; negative if [other] is earlier.
  int daysUntil(CalendarDate other) => other.daysSinceEpoch - daysSinceEpoch;

  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  /// Midnight at the start of this date in the device's local time zone.
  DateTime toLocalDateTime() => DateTime(year, month, day);

  String toIso8601String() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CalendarDate other) => daysSinceEpoch.compareTo(other.daysSinceEpoch);

  @override
  bool operator ==(Object other) =>
      other is CalendarDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso8601String();
}
