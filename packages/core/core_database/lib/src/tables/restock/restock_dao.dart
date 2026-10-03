import 'package:drift/drift.dart';

import '../../application_database.dart';
import 'restock_tables.dart';

part 'restock_dao.g.dart';

/// Restock rules and the shopping list.
@DriftAccessor(tables: [RestockRules, ShoppingListEntries])
class RestockDao extends DatabaseAccessor<ApplicationDatabase> with _$RestockDaoMixin {
  RestockDao(super.attachedDatabase);

  Stream<List<RestockRuleRow>> watchRules() => select(restockRules).watch();

  Future<List<RestockRuleRow>> readRules() => select(restockRules).get();

  Future<RestockRuleRow?> readRule(String productIdentifier) => (select(
    restockRules,
  )..where((rule) => rule.productIdentifier.equals(productIdentifier))).getSingleOrNull();

  Future<void> saveRule(RestockRuleRow rule) => into(restockRules).insertOnConflictUpdate(rule);

  Future<void> deleteRule(String productIdentifier) => (delete(
    restockRules,
  )..where((rule) => rule.productIdentifier.equals(productIdentifier))).go();

  Stream<List<ShoppingListEntryRow>> watchShoppingListEntries() => (select(
    shoppingListEntries,
  )..orderBy([(entry) => OrderingTerm.asc(entry.createdAt)])).watch();

  Future<List<ShoppingListEntryRow>> readShoppingListEntries() =>
      (select(shoppingListEntries)..orderBy([(entry) => OrderingTerm.asc(entry.createdAt)])).get();

  Future<void> insertShoppingListEntry(ShoppingListEntryRow entry) =>
      into(shoppingListEntries).insert(entry);

  Future<void> replaceShoppingListEntry(ShoppingListEntryRow entry) =>
      update(shoppingListEntries).replace(entry);

  Future<void> deleteShoppingListEntry(String shoppingListEntryIdentifier) => (delete(
    shoppingListEntries,
  )..where((entry) => entry.shoppingListEntryIdentifier.equals(shoppingListEntryIdentifier))).go();
}
