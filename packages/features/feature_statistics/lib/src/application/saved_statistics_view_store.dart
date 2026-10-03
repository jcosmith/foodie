import 'dart:convert';

import 'package:core_preferences/core_preferences.dart';

import '../domain/saved_statistics_views.dart';

/// Stores the user's saved views as one JSON preference, so they are part
/// of the encrypted database and of every backup.
final class SavedStatisticsViewStore {
  const SavedStatisticsViewStore(this._preferencesStore);

  static const PreferenceKey<List<SavedStatisticsView>> savedViewsKey = PreferenceKey(
    moduleNamespace: 'statistics',
    name: 'saved_views',
    defaultValue: [],
    codec: _SavedViewsPreferenceCodec(),
  );

  final PreferencesStore _preferencesStore;

  Stream<List<SavedStatisticsView>> watch() => _preferencesStore.watch(savedViewsKey);

  /// Saves [view], replacing a view with the same name.
  Future<void> save(SavedStatisticsView view) async {
    final views = await _preferencesStore.read(savedViewsKey);
    await _preferencesStore.write(savedViewsKey, [
      for (final existing in views)
        if (existing.name != view.name) existing,
      view,
    ]);
  }

  Future<void> remove(String name) async {
    final views = await _preferencesStore.read(savedViewsKey);
    await _preferencesStore.write(savedViewsKey, [
      for (final existing in views)
        if (existing.name != name) existing,
    ]);
  }
}

final class _SavedViewsPreferenceCodec implements PreferenceValueCodec<List<SavedStatisticsView>> {
  const _SavedViewsPreferenceCodec();

  @override
  String? encode(List<SavedStatisticsView> value) =>
      value.isEmpty ? null : jsonEncode(SavedStatisticsViewCodec.encodeViews(value));

  @override
  List<SavedStatisticsView> decode(String encodedValue) =>
      SavedStatisticsViewCodec.decodeViews(jsonDecode(encodedValue));
}
