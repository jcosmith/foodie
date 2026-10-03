import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'storage_layout_tables.dart';

part 'storage_layout_dao.g.dart';

/// Data access for feature_storage_layout.
@DriftAccessor(tables: [Freezers, Compartments])
class StorageLayoutDao extends DatabaseAccessor<ApplicationDatabase> with _$StorageLayoutDaoMixin {
  StorageLayoutDao(super.attachedDatabase);

  Stream<List<FreezerRow>> watchFreezers({bool includeArchived = false}) =>
      _freezersQuery(includeArchived: includeArchived).watch();

  Future<List<FreezerRow>> readFreezers({bool includeArchived = false}) =>
      _freezersQuery(includeArchived: includeArchived).get();

  SimpleSelectStatement<$FreezersTable, FreezerRow> _freezersQuery({
    required bool includeArchived,
  }) {
    final query = select(freezers)..orderBy([(freezer) => OrderingTerm.asc(freezer.sortOrder)]);
    if (!includeArchived) query.where((freezer) => freezer.isArchived.equals(false));
    return query;
  }

  Future<FreezerRow?> readFreezer(String freezerIdentifier) => (select(
    freezers,
  )..where((freezer) => freezer.freezerIdentifier.equals(freezerIdentifier))).getSingleOrNull();

  /// Compartments ordered by freezer order, then by compartment order.
  Stream<List<CompartmentRow>> watchCompartments({bool includeArchived = false}) =>
      _compartmentsQuery(includeArchived: includeArchived).watch();

  Future<List<CompartmentRow>> readCompartments({bool includeArchived = false}) =>
      _compartmentsQuery(includeArchived: includeArchived).get();

  Selectable<CompartmentRow> _compartmentsQuery({required bool includeArchived}) {
    final query = select(compartments).join([
      innerJoin(freezers, freezers.freezerIdentifier.equalsExp(compartments.freezerIdentifier)),
    ])..orderBy([OrderingTerm.asc(freezers.sortOrder), OrderingTerm.asc(compartments.sortOrder)]);
    if (!includeArchived) query.where(compartments.isArchived.equals(false));
    return query.map((row) => row.readTable(compartments));
  }

  Future<CompartmentRow?> readCompartment(String compartmentIdentifier) =>
      (select(compartments)..where(
            (compartment) => compartment.compartmentIdentifier.equals(compartmentIdentifier),
          ))
          .getSingleOrNull();

  Future<List<CompartmentRow>> readCompartmentsOfFreezer(
    String freezerIdentifier, {
    bool includeArchived = false,
  }) {
    final query = select(compartments)
      ..where((compartment) => compartment.freezerIdentifier.equals(freezerIdentifier))
      ..orderBy([(compartment) => OrderingTerm.asc(compartment.sortOrder)]);
    if (!includeArchived) query.where((compartment) => compartment.isArchived.equals(false));
    return query.get();
  }

  /// The next number for a default name; archived compartments count too, so
  /// "Drawer 3" is never reused for a different drawer.
  Future<int> nextCompartmentDefaultNumber(String freezerIdentifier) async {
    final highestNumber = compartments.defaultNumber.max();
    final row =
        await (selectOnly(compartments)
              ..addColumns([highestNumber])
              ..where(compartments.freezerIdentifier.equals(freezerIdentifier)))
            .getSingle();
    return (row.read(highestNumber) ?? 0) + 1;
  }

  Future<void> insertFreezer(FreezerRow freezer) => into(freezers).insert(freezer);

  Future<void> insertCompartment(CompartmentRow compartment) =>
      into(compartments).insert(compartment);

  Future<void> updateFreezerCustomName(String freezerIdentifier, String? customName) =>
      (update(freezers)..where((freezer) => freezer.freezerIdentifier.equals(freezerIdentifier)))
          .write(FreezersCompanion(customName: Value(customName)));

  Future<void> updateFreezerSortOrders(Map<String, int> sortOrderByFreezerIdentifier) =>
      batch((batchBuilder) {
        sortOrderByFreezerIdentifier.forEach((freezerIdentifier, sortOrder) {
          batchBuilder.update(
            freezers,
            FreezersCompanion(sortOrder: Value(sortOrder)),
            where: (freezer) => freezer.freezerIdentifier.equals(freezerIdentifier),
          );
        });
      });

  Future<void> archiveFreezer(String freezerIdentifier) =>
      (update(freezers)..where((freezer) => freezer.freezerIdentifier.equals(freezerIdentifier)))
          .write(const FreezersCompanion(isArchived: Value(true)));

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
