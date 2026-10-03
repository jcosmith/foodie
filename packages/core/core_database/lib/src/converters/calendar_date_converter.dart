import 'package:core_foundation/core_foundation.dart';
import 'package:drift/drift.dart';

/// Stores a [CalendarDate] as ISO 8601 text such as `2026-03-03`, which sorts
/// chronologically and stays readable in backups.
class CalendarDateTextConverter extends TypeConverter<CalendarDate, String> {
  const CalendarDateTextConverter();

  @override
  CalendarDate fromSql(String fromDb) => CalendarDate.parseIso8601(fromDb);

  @override
  String toSql(CalendarDate value) => value.toIso8601String();
}
