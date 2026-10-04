import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';

import '../../domain/restock_events.dart';
import '../../domain/restock_policy.dart';
import '../../domain/restock_repository.dart';
import '../../domain/shopping_list_entry.dart';
import '../stock_totals.dart';

/// Brings the automatic shopping list entries in line with the stock. Runs
/// after every stock change and at start; idempotent, because events are
/// only hints and the database is the truth. Products of switched-off
/// domains are left alone: their minimums pause and their entries stay as
/// they are until the domain is switched on again.
final class ReconcileShoppingListUseCase {
  const ReconcileShoppingListUseCase({
    required RestockRepository repository,
    required InventoryQueryService inventory,
    required ProductCatalogQueryService productCatalog,
    required Set<StorageDomainIdentifier> Function() readPausedDomains,
    required TransactionRunner transactionRunner,
    required DomainEventBus domainEventBus,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
  }) : _repository = repository,
       _inventory = inventory,
       _productCatalog = productCatalog,
       _readPausedDomains = readPausedDomains,
       _transactionRunner = transactionRunner,
       _domainEventBus = domainEventBus,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final RestockRepository _repository;
  final InventoryQueryService _inventory;
  final ProductCatalogQueryService _productCatalog;
  final Set<StorageDomainIdentifier> Function() _readPausedDomains;
  final TransactionRunner _transactionRunner;
  final DomainEventBus _domainEventBus;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;

  Future<void> execute() async {
    final addedEntries = await _transactionRunner.runInTransaction(() async {
      final catalog = await _productCatalog.readCatalog();
      final pausedDomains = _readPausedDomains();
      final pausedProducts = {
        for (final product in catalog.activeProducts)
          if (pausedDomains.contains(catalog.storageDomainOf(product))) product.identifier,
      };
      final activeProducts = {
        for (final product in catalog.activeProducts)
          if (!pausedProducts.contains(product.identifier)) product.identifier,
      };
      final rules = [
        for (final rule in await _repository.readRules())
          if (activeProducts.contains(rule.productIdentifier)) rule,
      ];
      final changes = RestockPolicy.reconcile(
        rules: rules,
        stockByProduct: sumStockByProduct(await _inventory.readActiveBatches()),
        packageQuantityByProduct: {
          for (final rule in rules)
            rule.productIdentifier: catalog
                .productOf(rule.productIdentifier)
                ?.defaultPackageQuantity,
        },
        entries: [
          for (final entry in await _repository.readShoppingList())
            if (!pausedProducts.contains(entry.productIdentifier)) entry,
        ],
      );
      for (final entry in changes.entriesToRemove) {
        await _repository.deleteShoppingListEntry(entry.identifier);
      }
      for (final entry in changes.entriesToUpdate) {
        await _repository.replaceShoppingListEntry(entry);
      }
      final addedEntries = [
        for (final plannedEntry in changes.entriesToAdd)
          ShoppingListEntry(
            identifier: _identifierGenerator.createIdentifier(),
            productIdentifier: plannedEntry.productIdentifier,
            requestedQuantity: plannedEntry.quantityToBuy,
            origin: ShoppingListEntryOrigin.restock,
            createdAt: _clock.nowUtc(),
          ),
      ];
      for (final entry in addedEntries) {
        await _repository.insertShoppingListEntry(entry);
      }
      return addedEntries;
    });
    for (final entry in addedEntries) {
      await _domainEventBus.publish(
        ShoppingListEntryAdded(
          shoppingListEntryIdentifier: entry.identifier,
          productIdentifier: entry.productIdentifier,
          origin: entry.origin,
          occurredAt: entry.createdAt,
        ),
      );
    }
  }
}
