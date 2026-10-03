import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

void main() {
  group('CalendarDate', () {
    test('rejects impossible dates', () {
      expect(() => CalendarDate(2026, 2, 30), throwsArgumentError);
    });

    test('parses and prints ISO 8601 dates', () {
      final frozenOn = CalendarDate.parseIso8601('2026-03-03');
      expect(frozenOn, CalendarDate(2026, 3, 3));
      expect(frozenOn.toIso8601String(), '2026-03-03');
    });

    test('counts days across months and leap years', () {
      final start = CalendarDate(2028, 2, 28);
      expect(start.addDays(1), CalendarDate(2028, 2, 29));
      expect(start.daysUntil(CalendarDate(2028, 3, 1)), 2);
      expect(CalendarDate(2026, 10, 2).daysUntil(CalendarDate(2026, 3, 3)), -213);
    });

    test('round-trips through days since epoch', () {
      final date = CalendarDate(2026, 10, 2);
      expect(CalendarDate.fromDaysSinceEpoch(date.daysSinceEpoch), date);
    });

    test('orders dates chronologically', () {
      final dates = [CalendarDate(2026, 5, 1), CalendarDate(2025, 12, 31), CalendarDate(2026, 1, 1)]
        ..sort();
      expect(dates.first, CalendarDate(2025, 12, 31));
      expect(dates.last, CalendarDate(2026, 5, 1));
    });

    test('reports weekdays with Monday as 1', () {
      expect(CalendarDate(2026, 10, 2).weekday, DateTime.friday);
    });
  });
}
