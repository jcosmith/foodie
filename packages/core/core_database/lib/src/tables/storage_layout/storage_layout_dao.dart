import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'storage_layout_tables.dart';

part 'storage_layout_dao.g.dart';

/// Data access for feature_storage_layout.
@DriftAccessor(tables: [StoragePlaces, Compartments])
class StorageLayoutDao extends DatabaseAccessor<ApplicationDatabase> with _$StorageLayoutDaoMixin {
  StorageLayoutDao(super.attachedDatabase);

  Stream<List<StoragePlaceRow>> watchStoragePlaces({bool includeArchived = false}) =>
      _storagePlacesQuery(includeArchived: includeArchived).watch();

  Future<List<StoragePlaceRow>> readStoragePlaces({bool includeArchived = false}) =>
      _storagePlacesQuery(includeArchived: includeArchived).get();

  SimpleSelectStatement<$StoragePlacesTable, StoragePlaceRow> _storagePlacesQuery({
    required bool includeArchived,
  }) {
    final query = select(storagePlaces)
      ..orderBy([(storagePlace) => OrderingTerm.asc(storagePlace.sortOrder)]);
    if (!includeArchived) query.where((storagePlace) => storagePlace.isArchived.equals(false));
    return query;
  }

  Future<StoragePlaceRow?> readStoragePlace(String storagePlaceIdentifier) =>
      (select(storagePlaces)..where(
            (storagePlace) => storagePlace.storagePlaceIdentifier.equals(storagePlaceIdentifier),
          ))
          .getSingleOrNull();

  /// Compartments ordered by storage place order, then by compartment order.
  Stream<List<CompartmentRow>> watchCompartments({bool includeArchived = false}) =>
      _compartmentsQuery(includeArchived: includeArchived).watch();

  Future<List<CompartmentRow>> readCompartments({bool includeArchived = false}) =>
      _compartmentsQuery(includeArchived: includeArchived).get();

  Selectable<CompartmentRow> _compartmentsQuery({required bool includeArchived}) {
    final query =
        select(compartments).join([
          innerJoin(
            storagePlaces,
            storagePlaces.storagePlaceIdentifier.equalsExp(compartments.storagePlaceIdentifier),
          ),
        ])..orderBy([
          OrderingTerm.asc(storagePlaces.sortOrder),
          OrderingTerm.asc(compartments.sortOrder),
        ]);
    if (!includeArchived) query.where(compartments.isArchived.equals(false));
    return query.map((row) => row.readTable(compartments));
  }

  Future<CompartmentRow?> readCompartment(String compartmentIdentifier) =>
      (select(compartments)..where(
            (compartment) => compartment.compartmentIdentifier.equals(compartmentIdentifier),
          ))
          .getSingleOrNull();

  Future<List<CompartmentRow>> readCompartmentsOfStoragePlace(
    String storagePlaceIdentifier, {
    bool includeArchived = false,
  }) {
    final query = select(compartments)
      ..where((compartment) => compartment.storagePlaceIdentifier.equals(storagePlaceIdentifier))
      ..orderBy([(compartment) => OrderingTerm.asc(compartment.sortOrder)]);
    if (!includeArchived) query.where((compartment) => compartment.isArchived.equals(false));
    return query.get();
  }

  /// The next number for a default name; archived compartments count too, so
  /// "Drawer 3" is never reused for a different drawer.
  Future<int> nextCompartmentDefaultNumber(String storagePlaceIdentifier) async {
    final highestNumber = compartments.defaultNumber.max();
    final row =
        await (selectOnly(compartments)
              ..addColumns([highestNumber])
              ..where(compartments.storagePlaceIdentifier.equals(storagePlaceIdentifier)))
            .getSingle();
    return (row.read(highestNumber) ?? 0) + 1;
  }

  Future<void> insertStoragePlace(StoragePlaceRow storagePlace) =>
      into(storagePlaces).insert(storagePlace);

  Future<void> insertCompartment(CompartmentRow compartment) =>
      into(compartments).insert(compartment);

  Future<void> updateStoragePlaceCustomName(String storagePlaceIdentifier, String? customName) =>
      (update(storagePlaces)..where(
            (storagePlace) => storagePlace.storagePlaceIdentifier.equals(storagePlaceIdentifier),
          ))
          .write(StoragePlacesCompanion(customName: Value(customName)));

  Future<void> updateStoragePlaceSortOrders(Map<String, int> sortOrderByStoragePlaceIdentifier) =>
      batch((batchBuilder) {
        sortOrderByStoragePlaceIdentifier.forEach((storagePlaceIdentifier, sortOrder) {
          batchBuilder.update(
            storagePlaces,
            StoragePlacesCompanion(sortOrder: Value(sortOrder)),
            where: (storagePlace) =>
                storagePlace.storagePlaceIdentifier.equals(storagePlaceIdentifier),
          );
        });
      });

  Future<void> archiveStoragePlace(String storagePlaceIdentifier) =>
      (update(storagePlaces)..where(
            (storagePlace) => storagePlace.storagePlaceIdentifier.equals(storagePlaceIdentifier),
          ))
          .write(const StoragePlacesCompanion(isArchived: Value(true)));

  Future<void> updateCompartmentCustomName(String compartmentIdentifier, String? customName) =>
      (update(compartments)..where(
            (compartment) => compartment.compartmentIdentifier.equals(compartmentIdentifier),
          ))
          .write(CompartmentsCompanion(customName: Value(customName)));

  Future<void> updateCompartmentColorTag(String compartmentIdentifier, int colorTagIndex) =>
      (update(compartments)..where(
            (compartment) => compartment.compartmentIdentifier.equals(compartmentIdentifier),
          ))
          .write(CompartmentsCompanion(colorTagIndex: Value(colorTagIndex)));

  Future<void> updateCompartmentSortOrders(Map<String, int> sortOrderByCompartmentIdentifier) =>
      batch((batchBuilder) {
        sortOrderByCompartmentIdentifier.forEach((compartmentIdentifier, sortOrder) {
          batchBuilder.update(
            compartments,
            CompartmentsCompanion(sortOrder: Value(sortOrder)),
            where: (compartment) => compartment.compartmentIdentifier.equals(compartmentIdentifier),
          );
        });
      });

  Future<void> archiveCompartment(String compartmentIdentifier) =>
      (update(compartments)..where(
            (compartment) => compartment.compartmentIdentifier.equals(compartmentIdentifier),
          ))
          .write(const CompartmentsCompanion(isArchived: Value(true)));
}
