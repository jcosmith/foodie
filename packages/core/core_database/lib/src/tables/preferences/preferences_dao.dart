import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'preference_entries_table.dart';

part 'preferences_dao.g.dart';

/// Reads and writes raw preference entries. Typed access lives in core_preferences.
@DriftAccessor(tables: [PreferenceEntries])
class PreferencesDao extends DatabaseAccessor<ApplicationDatabase> with _$PreferencesDaoMixin {
  PreferencesDao(super.attachedDatabase);

  Future<String?> readEncodedValue(String preferenceKey) async {
    final row = await (select(
      preferenceEntries,
    )..where((entry) => entry.preferenceKey.equals(preferenceKey))).getSingleOrNull();
    return row?.encodedValue;
  }

  Stream<String?> watchEncodedValue(String preferenceKey) =>
      (select(preferenceEntries)..where((entry) => entry.preferenceKey.equals(preferenceKey)))
          .watchSingleOrNull()
          .map((row) => row?.encodedValue);

  Future<void> writeEncodedValue({
    required String preferenceKey,
    required String encodedValue,
    required DateTime updatedAt,
  }) => into(preferenceEntries).insertOnConflictUpdate(
    PreferenceEntriesCompanion.insert(
      preferenceKey: preferenceKey,
      encodedValue: encodedValue,
      updatedAt: updatedAt,
    ),
  );

  Future<void> removeEntry(String preferenceKey) =>
      (delete(preferenceEntries)..where((entry) => entry.preferenceKey.equals(preferenceKey))).go();
}
