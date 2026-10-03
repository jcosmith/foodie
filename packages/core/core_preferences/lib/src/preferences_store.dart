import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';

import 'preference_key.dart';

/// Reads, writes and observes typed settings.
abstract interface class PreferencesStore {
  /// The stored value, or the key's default when nothing (readable) is stored.
  Future<TValue> read<TValue>(PreferenceKey<TValue> key);

  /// Emits the current value and every change.
  Stream<TValue> watch<TValue>(PreferenceKey<TValue> key);

  Future<void> write<TValue>(PreferenceKey<TValue> key, TValue value);

  /// Removes the stored value, so the default applies again.
  Future<void> reset<TValue>(PreferenceKey<TValue> key);
}

/// Stores settings in the encrypted database through [PreferencesDao].
final class DatabasePreferencesStore implements PreferencesStore {
  DatabasePreferencesStore({
    required PreferencesDao preferencesDao,
    required Clock clock,
    LocalLogger logger = const DeveloperConsoleLogger(),
  }) : _preferencesDao = preferencesDao,
       _clock = clock,
       _logger = logger;

  final PreferencesDao _preferencesDao;
  final Clock _clock;
  final LocalLogger _logger;

  @override
  Future<TValue> read<TValue>(PreferenceKey<TValue> key) async =>
      _decodeOrDefault(key, await _preferencesDao.readEncodedValue(key.storageKey));

  @override
  Stream<TValue> watch<TValue>(PreferenceKey<TValue> key) => _preferencesDao
      .watchEncodedValue(key.storageKey)
      .map((encodedValue) => _decodeOrDefault(key, encodedValue))
      .distinct();

  @override
  Future<void> write<TValue>(PreferenceKey<TValue> key, TValue value) async {
    final encodedValue = key.codec.encode(value);
    if (encodedValue == null) {
      await _preferencesDao.removeEntry(key.storageKey);
      return;
    }
    await _preferencesDao.writeEncodedValue(
      preferenceKey: key.storageKey,
      encodedValue: encodedValue,
      updatedAt: _clock.nowUtc(),
    );
  }

  @override
  Future<void> reset<TValue>(PreferenceKey<TValue> key) =>
      _preferencesDao.removeEntry(key.storageKey);

  TValue _decodeOrDefault<TValue>(PreferenceKey<TValue> key, String? encodedValue) {
    if (encodedValue == null) return key.defaultValue;
    try {
      return key.codec.decode(encodedValue);
    } on FormatException catch (error) {
      // An unreadable value (for example from a removed enum option) falls
      // back to the default instead of breaking the screen that reads it.
      _logger.log(LogSeverity.warning, 'Unreadable preference ${key.storageKey}', error: error);
      return key.defaultValue;
    }
  }
}
