import 'package:meta/meta.dart';

/// What kind of storage a storage place is, such as an upright freezer or a
/// kitchen cupboard. The kinds come from the domain modules; this value only
/// carries the name stored with every place, so places of a kind whose module
/// is missing still load.
@immutable
final class StorageKind {
  const StorageKind(this.storageName);

  /// For places whose kind is not known; shown with neutral default names.
  static const StorageKind unknown = StorageKind('');

  final String storageName;

  @override
  bool operator ==(Object other) => other is StorageKind && other.storageName == storageName;

  @override
  int get hashCode => storageName.hashCode;

  @override
  String toString() => storageName;
}
