import 'package:meta/meta.dart';

/// Names a storage domain: the unit a household switches on or off, each
/// with its own tab (architecture 10.7).
///
/// Domains are data, not a closed list: a module brings its domain with its
/// storage kinds and catalog, and nothing else in the app switches over the
/// known values. The constants only name the domains of the plan so their
/// modules and tests spell them the same way.
@immutable
final class StorageDomainIdentifier {
  const StorageDomainIdentifier(this.value);

  /// Checks that [value] is usable, for identifiers read from storage.
  factory StorageDomainIdentifier.parse(String value) {
    if (value.isEmpty) throw ArgumentError.value(value, 'value', 'Must not be empty');
    return StorageDomainIdentifier(value);
  }

  static const StorageDomainIdentifier freezer = StorageDomainIdentifier('freezer');
  static const StorageDomainIdentifier fridge = StorageDomainIdentifier('fridge');
  static const StorageDomainIdentifier pantry = StorageDomainIdentifier('pantry');
  static const StorageDomainIdentifier household = StorageDomainIdentifier('household');

  final String value;

  @override
  bool operator ==(Object other) => other is StorageDomainIdentifier && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
