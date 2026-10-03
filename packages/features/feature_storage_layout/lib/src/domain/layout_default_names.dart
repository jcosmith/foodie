import 'storage_kind.dart';

/// Translated default names. The presentation layer implements this with the
/// current localizations, so untouched names follow the app language while
/// names the user typed stay as written.
abstract interface class LayoutDefaultNames {
  String freezerName(StorageKind storageKind);

  /// "Drawer 3", "Basket 2" or "Compartment 1".
  String compartmentName(StorageKind storageKind, int number);

  /// "Drawer 3 (removed)", for archived compartments in historical views.
  String removedName(String name);
}
