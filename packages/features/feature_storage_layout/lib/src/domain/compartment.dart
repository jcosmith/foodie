import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'storage_place.dart';

typedef CompartmentIdentifier = TypedIdentifier<Compartment>;

/// A compartment, basket or shelf of a storage place. Never deleted, only archived, so
/// past statistics keep its name (decision D13).
@immutable
final class Compartment {
  const Compartment({
    required this.identifier,
    required this.storagePlaceIdentifier,
    required this.defaultNumber,
    required this.colorTagIndex,
    required this.sortOrder,
    required this.createdAt,
    this.customName,
    this.isArchived = false,
  });

  final CompartmentIdentifier identifier;
  final StoragePlaceIdentifier storagePlaceIdentifier;

  /// The number in the default name "Drawer {number}"; it stays the same when
  /// compartments are reordered.
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
      other.storagePlaceIdentifier == storagePlaceIdentifier &&
      other.defaultNumber == defaultNumber &&
      other.customName == customName &&
      other.colorTagIndex == colorTagIndex &&
      other.sortOrder == sortOrder &&
      other.isArchived == isArchived &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    identifier,
    storagePlaceIdentifier,
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
