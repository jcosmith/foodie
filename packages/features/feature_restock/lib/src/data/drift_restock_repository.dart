import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';

import '../domain/restock_repository.dart';
import '../domain/restock_rule.dart';
import '../domain/shopping_list_entry.dart';

final class DriftRestockRepository implements RestockRepository {
  DriftRestockRepository({required RestockDao restockDao, required Clock clock})
    : _restockDao = restockDao,
      _clock = clock;

  final RestockDao _restockDao;
  final Clock _clock;

  @override
  Stream<List<RestockRule>> watchRules() =>
      _restockDao.watchRules().map((rows) => rows.map(_ruleFromRow).toList());

  @override
  Future<List<RestockRule>> readRules() async =>
      (await _restockDao.readRules()).map(_ruleFromRow).toList();

  @override
  Future<void> saveRule(RestockRule rule) => _restockDao.saveRule(
    RestockRuleRow(
      productIdentifier: rule.productIdentifier.value,
      quantityUnit: rule.minimumQuantity.unit.storageName,
      minimumQuantity: rule.minimumQuantity.amountInBaseUnits,
      targetQuantity: rule.targetQuantity?.amountInBaseUnits,
      isActive: rule.isActive,
      updatedAt: _clock.nowUtc(),
    ),
  );

  @override
  Future<void> deleteRule(ProductIdentifier productIdentifier) =>
      _restockDao.deleteRule(productIdentifier.value);

  @override
  Stream<List<ShoppingListEntry>> watchShoppingList() =>
      _restockDao.watchShoppingListEntries().map((rows) => rows.map(_entryFromRow).toList());

  @override
  Future<List<ShoppingListEntry>> readShoppingList() async =>
      (await _restockDao.readShoppingListEntries()).map(_entryFromRow).toList();

  @override
  Future<void> insertShoppingListEntry(ShoppingListEntry entry) =>
      _restockDao.insertShoppingListEntry(_rowFromEntry(entry));

  @override
  Future<void> replaceShoppingListEntry(ShoppingListEntry entry) =>
      _restockDao.replaceShoppingListEntry(_rowFromEntry(entry));

  @override
  Future<void> deleteShoppingListEntry(ShoppingListEntryIdentifier shoppingListEntryIdentifier) =>
      _restockDao.deleteShoppingListEntry(shoppingListEntryIdentifier.value);

  static RestockRule _ruleFromRow(RestockRuleRow row) {
    final unit = QuantityUnit.fromStorageName(row.quantityUnit);
    return RestockRule(
      productIdentifier: ProductIdentifier(row.productIdentifier),
      minimumQuantity: Quantity(amountInBaseUnits: row.minimumQuantity, unit: unit),
      targetQuantity: switch (row.targetQuantity) {
        final targetQuantity? => Quantity(amountInBaseUnits: targetQuantity, unit: unit),
        null => null,
      },
      isActive: row.isActive,
    );
  }

  static ShoppingListEntry _entryFromRow(ShoppingListEntryRow row) => ShoppingListEntry(
    identifier: ShoppingListEntryIdentifier(row.shoppingListEntryIdentifier),
    productIdentifier: switch (row.productIdentifier) {
      final productIdentifier? => ProductIdentifier(productIdentifier),
      null => null,
    },
    freeTextName: row.freeTextName,
    requestedQuantity: switch ((row.requestedQuantity, row.quantityUnit)) {
      (final amount?, final unit?) => Quantity(
        amountInBaseUnits: amount,
        unit: QuantityUnit.fromStorageName(unit),
      ),
      _ => null,
    },
    origin: ShoppingListEntryOrigin.values.byName(row.origin),
    createdAt: row.createdAt,
    checkedAt: row.checkedAt,
  );

  static ShoppingListEntryRow _rowFromEntry(ShoppingListEntry entry) => ShoppingListEntryRow(
    shoppingListEntryIdentifier: entry.identifier.value,
    productIdentifier: entry.productIdentifier?.value,
    freeTextName: entry.freeTextName,
    quantityUnit: entry.requestedQuantity?.unit.storageName,
    requestedQuantity: entry.requestedQuantity?.amountInBaseUnits,
    origin: entry.origin.name,
    createdAt: entry.createdAt,
    checkedAt: entry.checkedAt,
  );
}
