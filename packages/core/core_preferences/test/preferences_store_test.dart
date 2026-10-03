import 'package:core_database/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

enum _ThemeChoice { system, light, dark }

final _themeChoiceKey = PreferenceKey.enumeration(
  moduleNamespace: 'configuration',
  name: 'theme_choice',
  defaultValue: _ThemeChoice.system,
  values: _ThemeChoice.values,
);

final _digestHourKey = PreferenceKey.integer(
  moduleNamespace: 'storage_reminders',
  name: 'digest_hour',
  defaultValue: 18,
);

final _lastBackupKey = PreferenceKey.optionalInstant(
  moduleNamespace: 'data_portability',
  name: 'last_backup_at',
);

void main() {
  test('returns the default until a value is written', () async {
    final database = createInMemoryApplicationDatabase();
    final store = DatabasePreferencesStore(
      preferencesDao: database.preferencesDao,
      clock: FixedClock(DateTime.utc(2026, 10, 2)),
      logger: RecordingLogger(),
    );

    expect(await store.read(_themeChoiceKey), _ThemeChoice.system);
    await store.write(_themeChoiceKey, _ThemeChoice.dark);
    expect(await store.read(_themeChoiceKey), _ThemeChoice.dark);
    await store.reset(_themeChoiceKey);
    expect(await store.read(_themeChoiceKey), _ThemeChoice.system);
    await database.close();
  });

  test('namespaces keep modules apart', () {
    expect(_themeChoiceKey.storageKey, 'configuration.theme_choice');
    expect(_digestHourKey.storageKey, 'storage_reminders.digest_hour');
  });

  test('unreadable stored values fall back to the default and are logged', () async {
    final database = createInMemoryApplicationDatabase();
    final logger = RecordingLogger();
    final store = DatabasePreferencesStore(
      preferencesDao: database.preferencesDao,
      clock: FixedClock(DateTime.utc(2026, 10, 2)),
      logger: logger,
    );
    await database.preferencesDao.writeEncodedValue(
      preferenceKey: _themeChoiceKey.storageKey,
      encodedValue: 'sepia',
      updatedAt: DateTime.utc(2026, 10, 2),
    );

    expect(await store.read(_themeChoiceKey), _ThemeChoice.system);
    expect(logger.recordedEntries.single.severity, LogSeverity.warning);
    await database.close();
  });

  test('optional instants are removed when set to null', () async {
    final database = createInMemoryApplicationDatabase();
    final store = DatabasePreferencesStore(
      preferencesDao: database.preferencesDao,
      clock: FixedClock(DateTime.utc(2026, 10, 2)),
    );
    final backupTime = DateTime.utc(2026, 9, 12, 18, 30);

    await store.write(_lastBackupKey, backupTime);
    expect(await store.read(_lastBackupKey), backupTime);
    await store.write(_lastBackupKey, null);
    expect(await database.preferencesDao.readEncodedValue(_lastBackupKey.storageKey), isNull);
    await database.close();
  });

  test('watch emits the current value and later changes', () async {
    final database = createInMemoryApplicationDatabase();
    final store = DatabasePreferencesStore(
      preferencesDao: database.preferencesDao,
      clock: FixedClock(DateTime.utc(2026, 10, 2)),
    );

    expect(await store.watch(_digestHourKey).first, 18);
    await store.write(_digestHourKey, 9);
    expect(await store.watch(_digestHourKey).first, 9);
    await database.close();
  });
}
