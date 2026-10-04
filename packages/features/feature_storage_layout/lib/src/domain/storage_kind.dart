/// What kind of cold storage a storage place is. Decides the default names of the
/// storage place and of its compartments ("Drawer", "Basket", "Compartment").
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
