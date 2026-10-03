/// What kind of cold storage a freezer is. Decides the default names of the
/// freezer and of its compartments ("Drawer", "Basket", "Compartment").
enum StorageKind {
  upright,
  chest,
  fridgeFreezerCompartment;

  String get storageName => name;

  static StorageKind fromStorageName(String storageName) => StorageKind.values.firstWhere(
    (kind) => kind.storageName == storageName,
    orElse: () => throw ArgumentError.value(storageName, 'storageName', 'Unknown storage kind'),
  );
}
