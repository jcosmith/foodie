import 'package:core_preferences/core_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How long the snackbar after taking out, throwing away or opening offers
/// "Undo" (Options): 0 to 10 seconds, or until it is dismissed.
abstract final class UndoTimeLimit {
  static const int longestSeconds = 10;

  /// Stored for "until dismissed".
  static const int untilDismissed = -1;

  /// Flutter's own snackbar duration, as before the setting existed.
  static const int defaultSeconds = 4;

  static final PreferenceKey<int> seconds = PreferenceKey.integer(
    moduleNamespace: 'inventory',
    name: 'undo_seconds',
    defaultValue: defaultSeconds,
  );
}

/// The chosen undo time in seconds, or [UndoTimeLimit.untilDismissed].
final undoTimeLimitSecondsProvider = StreamProvider<int>(
  (ref) => ref.watch(preferencesStoreProvider).watch(UndoTimeLimit.seconds),
);
