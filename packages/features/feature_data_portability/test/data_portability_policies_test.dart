import 'package:feature_data_portability/src/domain/backup_policies.dart';
import 'package:feature_data_portability/src/domain/csv_writer.dart';
import 'package:feature_data_portability/src/domain/data_portability_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a backup password needs eight characters, typed the same twice', () {
    expect(
      BackupPasswordPolicy.check(password: 'short', repeatedPassword: 'short'),
      isA<BackupPasswordTooShort>(),
    );
    expect(
      BackupPasswordPolicy.check(password: 'long enough', repeatedPassword: 'long enougH'),
      isA<BackupPasswordsDoNotMatch>(),
    );
    expect(
      BackupPasswordPolicy.check(password: 'long enough', repeatedPassword: 'long enough'),
      isNull,
    );
  });

  test('a backup is due with food and no backup in the last 90 days', () {
    final now = DateTime.utc(2026, 10, 2);
    bool isDue(DateTime? lastBackupAt, {bool hasStoredFood = true}) =>
        BackupReminderPolicy.isBackupDue(
          lastBackupAt: lastBackupAt,
          now: now,
          hasStoredFood: hasStoredFood,
        );

    expect(isDue(null), isTrue);
    expect(isDue(null, hasStoredFood: false), isFalse);
    expect(isDue(now.subtract(const Duration(days: 89))), isFalse);
    expect(isDue(now.subtract(const Duration(days: 90))), isTrue);
  });

  test('CSV quotes commas, quotes and line breaks', () {
    final csv = CsvWriter.write(
      ['Product', 'Note'],
      [
        ['Peas, frozen', 'Said "best"'],
        ['Soup', 'line one\nline two'],
      ],
    );

    expect(csv, '﻿Product,Note\r\n"Peas, frozen","Said ""best"""\r\nSoup,"line one\nline two"\r\n');
  });

  test('the backup notification comes 90 days after the last backup, then monthly', () {
    final nowLocal = DateTime(2026, 10, 2, 9);
    DateTime? nextAt({DateTime? lastBackupAt, DateTime? oldestStoredAt}) =>
        BackupReminderPolicy.nextNotificationAt(
          lastBackupAtLocal: lastBackupAt,
          oldestStoredAtLocal: oldestStoredAt,
          nowLocal: nowLocal,
        );

    expect(nextAt(lastBackupAt: DateTime(2026, 9, 1)), isNull);
    expect(
      nextAt(lastBackupAt: DateTime(2026, 9, 1, 20), oldestStoredAt: DateTime(2026, 1, 1)),
      DateTime(2026, 11, 30, 18),
    );
    expect(nextAt(oldestStoredAt: DateTime(2026, 9, 20)), DateTime(2026, 12, 19, 18));
    // Overdue since 30 June: every 30 days after that, next on 28 October.
    expect(
      nextAt(lastBackupAt: DateTime(2026, 4, 1), oldestStoredAt: DateTime(2026, 1, 1)),
      DateTime(2026, 10, 28, 18),
    );
  });
}
