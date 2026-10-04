import 'package:core_database/core_database.dart';

import '../domain/compartment.dart';
import '../domain/storage_kind.dart';
import '../domain/storage_layout_repository.dart';
import '../domain/storage_place.dart';

/// [StorageLayoutRepository] on top of the storage layout DAO.
final class DriftStorageLayoutRepository implements StorageLayoutRepository {
  const DriftStorageLayoutRepository(this._storageLayoutDao);

  final StorageLayoutDao _storageLayoutDao;

  @override
  Stream<List<StoragePlace>> watchStoragePlacesIncludingArchived() => _storageLayoutDao
      .watchStoragePlaces(includeArchived: true)
      .map((rows) => rows.map(_storagePlaceFromRow).toList());

  @override
  Stream<List<Compartment>> watchCompartmentsIncludingArchived() => _storageLayoutDao
      .watchCompartments(includeArchived: true)
      .map((rows) => rows.map(_compartmentFromRow).toList());

  @override
  Future<List<StoragePlace>> readActiveStoragePlaces() async =>
      (await _storageLayoutDao.readStoragePlaces()).map(_storagePlaceFromRow).toList();

  @override
  Future<StoragePlace?> readStoragePlace(StoragePlaceIdentifier storagePlaceIdentifier) async {
    final row = await _storageLayoutDao.readStoragePlace(storagePlaceIdentifier.value);
    return row == null ? null : _storagePlaceFromRow(row);
  }

  @override
  Future<Compartment?> readCompartment(CompartmentIdentifier compartmentIdentifier) async {
    final row = await _storageLayoutDao.readCompartment(compartmentIdentifier.value);
    return row == null ? null : _compartmentFromRow(row);
  }

  @override
  Future<List<Compartment>> readActiveCompartmentsOfStoragePlace(
    StoragePlaceIdentifier storagePlaceIdentifier,
  ) async => (await _storageLayoutDao.readCompartmentsOfStoragePlace(
    storagePlaceIdentifier.value,
  )).map(_compartmentFromRow).toList();

  @override
  Future<int> readNextCompartmentDefaultNumber(StoragePlaceIdentifier storagePlaceIdentifier) =>
      _storageLayoutDao.nextCompartmentDefaultNumber(storagePlaceIdentifier.value);

  @override
  Future<void> insertStoragePlace(StoragePlace storagePlace) =>
      _storageLayoutDao.insertStoragePlace(
        StoragePlaceRow(
          storagePlaceIdentifier: storagePlace.identifier.value,
          // The default name follows the storage kind; the key is kept so a
          // later version can offer other default names without a migration.
          defaultNameKey: storagePlace.storageKind.storageName,
          customName: storagePlace.customName,
          storageKind: storagePlace.storageKind.storageName,
          sortOrder: storagePlace.sortOrder,
          isArchived: storagePlace.isArchived,
          createdAt: storagePlace.createdAt,
        ),
      );

  @override
  Future<void> insertCompartment(Compartment compartment) => _storageLayoutDao.insertCompartment(
    CompartmentRow(
      compartmentIdentifier: compartment.identifier.value,
      storagePlaceIdentifier: compartment.storagePlaceIdentifier.value,
      defaultNumber: compartment.defaultNumber,
      customName: compartment.customName,
      colorTagIndex: compartment.colorTagIndex,
      sortOrder: compartment.sortOrder,
      isArchived: compartment.isArchived,
      createdAt: compartment.createdAt,
    ),
  );

  @override
  Future<void> updateStoragePlaceCustomName(
    StoragePlaceIdentifier storagePlaceIdentifier,
    String? customName,
  ) => _storageLayoutDao.updateStoragePlaceCustomName(storagePlaceIdentifier.value, customName);

  @override
  Future<void> updateStoragePlaceSortOrders(
    Map<StoragePlaceIdentifier, int> sortOrderByStoragePlace,
  ) => _storageLayoutDao.updateStoragePlaceSortOrders({
    for (final MapEntry(key: storagePlaceIdentifier, value: sortOrder)
        in sortOrderByStoragePlace.entries)
      storagePlaceIdentifier.value: sortOrder,
  });

  @override
  Future<void> archiveStoragePlace(StoragePlaceIdentifier storagePlaceIdentifier) =>
      _storageLayoutDao.archiveStoragePlace(storagePlaceIdentifier.value);

  @override
  Future<void> updateCompartmentCustomName(
    CompartmentIdentifier compartmentIdentifier,
    String? customName,
  ) => _storageLayoutDao.updateCompartmentCustomName(compartmentIdentifier.value, customName);

  @override
  Future<void> updateCompartmentColorTag(
    CompartmentIdentifier compartmentIdentifier,
    int colorTagIndex,
  ) => _storageLayoutDao.updateCompartmentColorTag(compartmentIdentifier.value, colorTagIndex);

  @override
  Future<void> updateCompartmentSortOrders(
    Map<CompartmentIdentifier, int> sortOrderByCompartment,
  ) => _storageLayoutDao.updateCompartmentSortOrders({
    for (final MapEntry(key: compartmentIdentifier, value: sortOrder)
        in sortOrderByCompartment.entries)
      compartmentIdentifier.value: sortOrder,
  });

  @override
  Future<void> archiveCompartment(CompartmentIdentifier compartmentIdentifier) =>
      _storageLayoutDao.archiveCompartment(compartmentIdentifier.value);

  static StoragePlace _storagePlaceFromRow(StoragePlaceRow row) => StoragePlace(
    identifier: StoragePlaceIdentifier(row.storagePlaceIdentifier),
    storageKind: StorageKind(row.storageKind),
    customName: row.customName,
    sortOrder: row.sortOrder,
    isArchived: row.isArchived,
    createdAt: row.createdAt,
  );

  static Compartment _compartmentFromRow(CompartmentRow row) => Compartment(
    identifier: CompartmentIdentifier(row.compartmentIdentifier),
    storagePlaceIdentifier: StoragePlaceIdentifier(row.storagePlaceIdentifier),
    defaultNumber: row.defaultNumber,
    customName: row.customName,
    colorTagIndex: row.colorTagIndex,
    sortOrder: row.sortOrder,
    isArchived: row.isArchived,
    createdAt: row.createdAt,
  );
}
