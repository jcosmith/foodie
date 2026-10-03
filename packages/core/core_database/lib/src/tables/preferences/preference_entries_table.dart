import 'package:drift/drift.dart';

/// Typed key-value settings of every module (core_preferences).
///
/// Stored inside the encrypted database so they are part of every backup.
/// Keys are namespaced by module, for example `configuration.theme_choice`.
@DataClassName('PreferenceEntryRow')
class PreferenceEntries extends Table {
  TextColumn get preferenceKey => text()();

  /// The value encoded as text by the preference's codec.
  TextColumn get encodedValue => text()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {preferenceKey};
}
