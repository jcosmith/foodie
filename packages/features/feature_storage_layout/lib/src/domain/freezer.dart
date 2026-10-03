import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'storage_kind.dart';

typedef FreezerIdentifier = TypedIdentifier<Freezer>;

/// A freezer (or chest freezer, or the freezer compartment of a fridge).
@immutable
final class Freezer {
  const Freezer({
    required this.identifier,
    required this.storageKind,
    required this.sortOrder,
    required this.createdAt,
    this.customName,
    this.isArchived = false,
  });

  final FreezerIdentifier identifier;
  final StorageKind storageKind;

  /// The name the user typed; `null` shows the translated default name.
  final String? customName;

  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is Freezer &&
      other.identifier == identifier &&
      other.storageKind == storageKind &&
      other.customName == customName &&
      other.sortOrder == sortOrder &&
      other.isArchived == isArchived &&
      other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(identifier, storageKind, customName, sortOrder, isArchived, createdAt);
}
