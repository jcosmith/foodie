import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

/// Whole local days from [firstDay] to [lastDay], both included.
@immutable
final class StatisticsDateRange {
  StatisticsDateRange(CalendarDate firstDay, CalendarDate lastDay)
    : firstDay = firstDay.isAfter(lastDay) ? lastDay : firstDay,
      lastDay = firstDay.isAfter(lastDay) ? firstDay : lastDay;

  final CalendarDate firstDay;
  final CalendarDate lastDay;

  int get lengthInDays => firstDay.daysUntil(lastDay) + 1;

  bool contains(CalendarDate day) => !day.isBefore(firstDay) && !day.isAfter(lastDay);

  StatisticsDateRange shiftedByDays(int numberOfDays) =>
      StatisticsDateRange(firstDay.addDays(numberOfDays), lastDay.addDays(numberOfDays));

  @override
  bool operator ==(Object other) =>
      other is StatisticsDateRange && other.firstDay == firstDay && other.lastDay == lastDay;

  @override
  int get hashCode => Object.hash(firstDay, lastDay);

  @override
  String toString() => '$firstDay – $lastDay';
}
