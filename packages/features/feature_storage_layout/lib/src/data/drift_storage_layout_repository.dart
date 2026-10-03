import 'package:core_database/core_database.dart';

import '../domain/compartment.dart';
import '../domain/freezer.dart';
import '../domain/storage_kind.dart';
import '../domain/storage_layout_repository.dart';

/// [StorageLayoutRepository] on top of the storage layout DAO.
final class DriftStorageLayoutRepository implements StorageLayoutRepository {
  const DriftStorageLayoutRepository(this._storageLayoutDao);

  final StorageLayoutDao _storageLayoutDao;

  @override
  Stream<List<Freezer>> watchFreezersIncludingArchived() => _storageLayoutDao
      .watchFreezers(includeArchived: true)
      .map((rows) => rows.map(_freezerFromRow).toList());

  @override
  Stream<List<Compartment>> watchCompartmentsIncludingArchived() => _storageLayoutDao
      .watchCompartments(includeArchived: true)
      .map((rows) => rows.map(_compartmentFromRow).toList());

  @override
  Future<List<Freezer>> readActiveFreezers() async =>
      (await _storageLayoutDao.readFreezers()).map(_freezerFromRow).toList();

  @override
  Future<Freezer?> readFreezer(FreezerIdentifier freezerIdentifier) async {
    final row = await _storageLayoutDao.readFreezer(freezerIdentifier.value);
    return row == null ? null : _freezerFromRow(row);
  }

  @override
  Future<Compartment?> readCompartment(CompartmentIdentifier compartmentIdentifier) async {
    final row = await _storageLayoutDao.readCompartment(compartmentIdentifier.value);
    return row == null ? null : _compartmentFromRow(row);
  }

  @override
  Future<List<Compartment>> readActiveCompartmentsOfFreezer(
    FreezerIdentifier freezerIdentifier,
  ) async => (await _storageLayoutDao.readCompartmentsOfFreezer(
    freezerIdentifier.value,
  )).map(_compartmentFromRow).toList();

  @override
  Future<int> readNextCompartmentDefaultNumber(FreezerIdentifier freezerIdentifier) =>
      _storageLayoutDao.nextCompartmentDefaultNumber(freezerIdentifier.value);

  @override
  Future<void> insertFreezer(Freezer freezer) => _storageLayoutDao.insertFreezer(
    FreezerRow(
      freezerIdentifier: freezer.identifier.value,
      // The default name follows the storage kind; the key is kept so a
      // later version can offer other default names without a migration.
      defaultNameKey: freezer.storageKind.storageName,
      customName: freezer.customName,
      storageKind: freezer.storageKind.storageName,
      sortOrder: freezer.sortOrder,
      isArchived: freezer.isArchived,
      createdAt: freezer.createdAt,
    ),
  );

  @override
  Future<void> insertCompartment(Compartment compartment) => _storageLayoutDao.insertCompartment(
    CompartmentRow(
      compartmentIdentifier: compartment.identifier.value,
      freezerIdentifier: compartment.freezerIdentifier.value,
      defaultNumber: compartment.defaultNumber,
      customName: compartment.customName,
      colorTagIndex: compartment.colorTagIndex,
      sortOrder: compartment.sortOrder,
      isArchived: compartment.isArchived,
      createdAt: compartment.createdAt,
    ),
  );

  @override
  Future<void> updateFreezerCustomName(FreezerIdentifier freezerIdentifier, String? customName) =>
      _storageLayoutDao.updateFreezerCustomName(freezerIdentifier.value, customName);

  @override
  Future<void> updateFreezerSortOrders(Map<FreezerIdentifier, int> sortOrderByFreezer) =>
      _storageLayoutDao.updateFreezerSortOrders({
        for (final MapEntry(key: freezerIdentifier, value: sortOrder) in sortOrderByFreezer.entries)
          freezerIdentifier.value: sortOrder,
      });

  @override
  Future<void> archiveFreezer(FreezerIdentifier freezerIdentifier) =>
      _storageLayoutDao.archiveFreezer(freezerIdentifier.value);

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

  static Freezer _freezerFromRow(FreezerRow row) => Freezer(
    identifier: FreezerIdentifier(row.freezerIdentifier),
    storageKind: StorageKind.fromStorageName(row.storageKind),
    customName: row.customName,
    sortOrder: row.sortOrder,
    isArchived: row.isArchived,
    createdAt: row.createdAt,
  );

  static Compartment _compartmentFromRow(CompartmentRow row) => Compartment(
    identifier: CompartmentIdentifier(row.compartmentIdentifier),
    freezerIdentifier: FreezerIdentifier(row.freezerIdentifier),
    defaultNumber: row.defaultNumber,
    customName: row.customName,
    colorTagIndex: row.colorTagIndex,
    sortOrder: row.sortOrder,
    isArchived: row.isArchived,
    createdAt: row.createdAt,
  );
}
