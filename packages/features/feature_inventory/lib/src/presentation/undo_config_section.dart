import 'package:core_preferences/core_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/undo_time_limit.dart';
import '../l10n/generated/inventory_localizations.dart';

/// The "Undo" section of Options: how long "Undo" stays offered, from
/// none to 10 seconds, with a last stop for "until dismissed".
class UndoConfigSection extends ConsumerWidget {
  const UndoConfigSection({super.key});

  /// The slider position after 10 seconds.
  static const int _untilDismissedPosition = UndoTimeLimit.longestSeconds + 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = InventoryLocalizations.of(context);
    final seconds = ref.watch(undoTimeLimitSecondsProvider).value ?? UndoTimeLimit.defaultSeconds;
    final position = seconds == UndoTimeLimit.untilDismissed
        ? _untilDismissedPosition
        : seconds.clamp(0, UndoTimeLimit.longestSeconds);
    final label = undoTimeLimitLabel(localizations, seconds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: position.toDouble(),
          max: _untilDismissedPosition.toDouble(),
          divisions: _untilDismissedPosition,
          label: label,
          semanticFormatterCallback: (_) => label,
          onChanged: (value) {
            final newPosition = value.round();
            ref
                .read(preferencesStoreProvider)
                .write(
                  UndoTimeLimit.seconds,
                  newPosition == _untilDismissedPosition
                      ? UndoTimeLimit.untilDismissed
                      : newPosition,
                );
          },
        ),
        Text(localizations.undoTimeLimitHint, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

String undoTimeLimitLabel(InventoryLocalizations localizations, int seconds) => switch (seconds) {
  UndoTimeLimit.untilDismissed => localizations.undoUntilDismissed,
  0 => localizations.undoOff,
  _ => localizations.undoForSeconds(seconds),
};

/// The snackbar after a change that can be undone, offering "Undo" for as
/// long as the user chose in Options.
SnackBar buildUndoableSnackBar({
  required int undoSeconds,
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
}) => switch (undoSeconds) {
  0 => SnackBar(content: Text(message)),
  UndoTimeLimit.untilDismissed => SnackBar(
    content: Text(message),
    persist: true,
    showCloseIcon: true,
    action: SnackBarAction(label: undoLabel, onPressed: onUndo),
  ),
  _ => SnackBar(
    content: Text(message),
    duration: Duration(seconds: undoSeconds),
    persist: false,
    action: SnackBarAction(label: undoLabel, onPressed: onUndo),
  ),
};
