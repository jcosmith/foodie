import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'freezer.dart';

typedef CompartmentIdentifier = TypedIdentifier<Compartment>;

/// A drawer, basket or shelf of a freezer. Never deleted, only archived, so
/// past statistics keep its name (decision D13).
@immutable
final class Compartment {
  const Compartment({
    required this.identifier,
    required this.freezerIdentifier,
    required this.defaultNumber,
    required this.colorTagIndex,
    required this.sortOrder,
    required this.createdAt,
    this.customName,
    this.isArchived = false,
  });

  final CompartmentIdentifier identifier;
  final FreezerIdentifier freezerIdentifier;

  /// The number in the default name "Drawer {number}"; it stays the same when
  /// drawers are reordered.
  final int defaultNumber;

  /// The name the user typed; `null` shows the translated default name.
  final String? customName;

  /// Index into the design system's compartment colour palette.
  final int colorTagIndex;

  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is Compartment &&
      other.identifier == identifier &&
      other.freezerIdentifier == freezerIdentifier &&
      other.defaultNumber == defaultNumber &&
      other.customName == customName &&
      other.colorTagIndex == colorTagIndex &&
      other.sortOrder == sortOrder &&
      other.isArchived == isArchived &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    identifier,
    freezerIdentifier,
    defaultNumber,
    customName,
    colorTagIndex,
    sortOrder,
    isArchived,
    createdAt,
  );
}

/// How many colour tags a compartment can choose from; matches the palette
/// in the design system.
const int compartmentColorTagCount = 6;

/// The colour tag a compartment gets by default, so neighbours differ.
int defaultColorTagIndexFor(int defaultNumber) => (defaultNumber - 1) % compartmentColorTagCount;
