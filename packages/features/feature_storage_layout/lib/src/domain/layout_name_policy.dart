import 'package:core_foundation/core_foundation.dart';

import 'storage_layout_failure.dart';

/// Rules for the names users give storage places and compartments (architecture
/// document, section 10.4): at most 30 characters, unique among their
/// siblings ignoring case, and an empty name goes back to the translated default.
abstract final class LayoutNamePolicy {
  static const int maximumNameLength = 30;

  /// Returns the custom name to store, or `null` to go back to the default name.
  ///
  /// [siblingDisplayNames] are the names the siblings currently show,
  /// translated defaults included, so "Drawer 2" cannot be typed for compartment 1
  /// while compartment 2 still shows that default.
  static Result<String?, StorageLayoutFailure> validate({
    required String enteredName,
    required Iterable<String> siblingDisplayNames,
  }) {
    final trimmedName = enteredName.trim();
    if (trimmedName.isEmpty) return const Result.success(null);
    if (trimmedName.characters > maximumNameLength) {
      return const Result.failure(LayoutNameTooLong());
    }
    final comparableName = trimmedName.toLowerCase();
    if (siblingDisplayNames.any(
      (siblingName) => siblingName.trim().toLowerCase() == comparableName,
    )) {
      return const Result.failure(LayoutNameAlreadyTaken());
    }
    return Result.success(trimmedName);
  }
}

extension on String {
  /// Counts user-perceived characters closely enough for a length limit
  /// without pulling in a grapheme library: surrogate pairs count once.
  int get characters => runes.length;
}
