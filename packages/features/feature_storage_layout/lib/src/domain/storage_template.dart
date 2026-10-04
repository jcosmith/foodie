import 'package:core_foundation/core_foundation.dart';
import 'package:meta/meta.dart';

import 'storage_kind.dart';

/// A starting point offered when adding a storage place, contributed by a
/// domain module. Every template has at least one compartment, because a
/// storage place always keeps one.
@immutable
final class StorageTemplate {
  const StorageTemplate({
    required this.identifier,
    required this.storageKind,
    required this.domainIdentifier,
    required this.compartmentCount,
    required this.sortOrder,
  }) : assert(compartmentCount > 0, 'A storage place always keeps a compartment');

  /// Unique across all modules, such as `freezer.upright_five`.
  final String identifier;

  final StorageKind storageKind;
  final StorageDomainIdentifier domainIdentifier;
  final int compartmentCount;

  /// Order in the list of templates of the domain.
  final int sortOrder;

  @override
  bool operator ==(Object other) =>
      other is StorageTemplate &&
      other.identifier == identifier &&
      other.storageKind == storageKind &&
      other.domainIdentifier == domainIdentifier &&
      other.compartmentCount == compartmentCount &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode =>
      Object.hash(identifier, storageKind, domainIdentifier, compartmentCount, sortOrder);

  @override
  String toString() => identifier;
}
