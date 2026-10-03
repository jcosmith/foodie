import 'calendar_date.dart';

/// Source of the current time.
///
/// Every piece of code that needs "now" asks a [Clock] instead of calling
/// `DateTime.now()` directly, so time-based logic (storage age, reminders,
/// statistics periods) can be tested with a [FixedClock]. The architecture
/// check in `tool/` rejects `DateTime.now()` outside this file.
abstract interface class Clock {
  /// The current instant in UTC.
  DateTime nowUtc();

  /// The current instant in the device's local time zone.
  DateTime nowLocal();

  /// Today's date in the device's local time zone.
  CalendarDate todayLocal();
}

/// The production clock backed by the system time.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  DateTime nowLocal() => DateTime.now();

  @override
  CalendarDate todayLocal() => CalendarDate.fromDateTime(DateTime.now());
}

/// A clock that only moves when told to; used in tests.
final class FixedClock implements Clock {
  FixedClock(DateTime initialInstant) : _currentInstant = initialInstant.toUtc();

  DateTime _currentInstant;

  /// Moves the clock forward (or backward for negative durations).
  void advanceBy(Duration duration) {
    _currentInstant = _currentInstant.add(duration);
  }

  /// Jumps to [instant].
  void setTo(DateTime instant) {
    _currentInstant = instant.toUtc();
  }

  @override
  DateTime nowUtc() => _currentInstant;

  @override
  DateTime nowLocal() => _currentInstant.toLocal();

  @override
  CalendarDate todayLocal() => CalendarDate.fromDateTime(_currentInstant.toLocal());
}
