import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';

import '../../domain/restock_events.dart';
import '../../domain/restock_failure.dart';
import '../../domain/restock_repository.dart';
import '../../domain/shopping_list_entry.dart';
import 'reconcile_shopping_list_use_case.dart';

/// Puts a product on the shopping list, with its package size as the amount.
/// A product already on the list is not added twice.
final class AddProductToShoppingListUseCase {
  const AddProductToShoppingListUseCase({
    required RestockRepository repository,
    required ProductCatalogQueryService productCatalog,
    required DomainEventBus domainEventBus,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
  }) : _repository = repository,
       _productCatalog = productCatalog,
       _domainEventBus = domainEventBus,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final RestockRepository _repository;
  final ProductCatalogQueryService _productCatalog;
  final DomainEventBus _domainEventBus;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;

  Future<Result<ShoppingListEntryIdentifier, RestockFailure>> execute(
    ProductIdentifier productIdentifier,
  ) async {
    final product = await _productCatalog.readProduct(productIdentifier);
    if (product == null) return const Result.failure(RestockProductNotFound());
    final existingEntry = (await _repository.readShoppingList())
        .where((entry) => entry.productIdentifier == productIdentifier && !entry.isChecked)
        .firstOrNull;
    if (existingEntry != null) return Result.success(existingEntry.identifier);

    final entry = ShoppingListEntry(
      identifier: _identifierGenerator.createIdentifier(),
      productIdentifier: productIdentifier,
      requestedQuantity: product.defaultPackageQuantity,
      origin: ShoppingListEntryOrigin.manual,
      createdAt: _clock.nowUtc(),
    );
    await _repository.insertShoppingListEntry(entry);
    await _domainEventBus.publish(
      ShoppingListEntryAdded(
        shoppingListEntryIdentifier: entry.identifier,
        productIdentifier: productIdentifier,
        origin: entry.origin,
        occurredAt: entry.createdAt,
      ),
    );
    return Result.success(entry.identifier);
  }
}

/// Ticks an entry as bought, or unticks it.
final class TickShoppingListEntryUseCase {
  const TickShoppingListEntryUseCase({required RestockRepository repository, required Clock clock})
    : _repository = repository,
      _clock = clock;

  final RestockRepository _repository;
  final Clock _clock;

  Future<Result<Unit, RestockFailure>> execute(
    ShoppingListEntryIdentifier shoppingListEntryIdentifier, {
    required bool isChecked,
  }) async {
    final entry = (await _repository.readShoppingList())
        .where((candidate) => candidate.identifier == shoppingListEntryIdentifier)
        .firstOrNull;
    if (entry == null) return const Result.failure(ShoppingListEntryNotFound());
    if (entry.isChecked == isChecked) return const Result.success(unit);
    await _repository.replaceShoppingListEntry(
      entry.copyWith(checkedAt: () => isChecked ? _clock.nowUtc() : null),
    );
    return const Result.success(unit);
  }
}

/// Removes an entry the user added. Running-low entries follow the stock.
final class RemoveShoppingListEntryUseCase {
  const RemoveShoppingListEntryUseCase({required RestockRepository repository})
    : _repository = repository;

  final RestockRepository _repository;

  Future<Result<Unit, RestockFailure>> execute(
    ShoppingListEntryIdentifier shoppingListEntryIdentifier,
  ) async {
    final entry = (await _repository.readShoppingList())
        .where((candidate) => candidate.identifier == shoppingListEntryIdentifier)
        .firstOrNull;
    if (entry == null) return const Result.failure(ShoppingListEntryNotFound());
    if (entry.isAutomatic && !entry.isChecked) {
      return const Result.failure(AutomaticEntryCannotBeRemoved());
    }
    await _repository.deleteShoppingListEntry(shoppingListEntryIdentifier);
    return const Result.success(unit);
  }
}

/// "Put ticked items in the freezer" (UI example phone 6): every ticked
/// product becomes a batch frozen today, in the drawer the product went into
/// last time, through the inventory's own use case. Returns how many batches
/// were added.
final class PutTickedItemsInFreezerUseCase {
  const PutTickedItemsInFreezerUseCase({
    required RestockRepository repository,
    required ProductCatalogQueryService productCatalog,
    required InventoryQueryService inventory,
    required StorageLayoutQueryService storageLayout,
    required AddStockBatchUseCase addStockBatch,
    required ReconcileShoppingListUseCase reconcileShoppingList,
    required Clock clock,
  }) : _repository = repository,
       _productCatalog = productCatalog,
       _inventory = inventory,
       _storageLayout = storageLayout,
       _addStockBatch = addStockBatch,
       _reconcileShoppingList = reconcileShoppingList,
       _clock = clock;

  final RestockRepository _repository;
  final ProductCatalogQueryService _productCatalog;
  final InventoryQueryService _inventory;
  final StorageLayoutQueryService _storageLayout;
  final AddStockBatchUseCase _addStockBatch;
  final ReconcileShoppingListUseCase _reconcileShoppingList;
  final Clock _clock;

  Future<Result<int, RestockFailure>> execute() async {
    final tickedEntries = (await _repository.readShoppingList())
        .where((entry) => entry.isChecked)
        .toList();
    if (tickedEntries.isEmpty) return const Result.success(0);
    final activeCompartments = (await _storageLayout.readStorageLayout()).activeCompartments;
    if (activeCompartments.isEmpty &&
        tickedEntries.any((entry) => entry.productIdentifier != null)) {
      return const Result.failure(NoCompartmentForBoughtItems());
    }

    var addedBatchCount = 0;
    for (final entry in tickedEntries) {
      final productIdentifier = entry.productIdentifier;
      final product = productIdentifier == null
          ? null
          : await _productCatalog.readProduct(productIdentifier);
      if (product != null) {
        final lastCompartment = await _inventory.readLastCompartmentOfProduct(product.identifier);
        final compartmentIdentifier =
            activeCompartments
                .where((compartment) => compartment.identifier == lastCompartment)
                .firstOrNull
                ?.identifier ??
            activeCompartments.first.identifier;
        final result = await _addStockBatch.execute(
          AddStockBatchCommand(
            productIdentifier: product.identifier,
            compartmentIdentifier: compartmentIdentifier,
            quantity:
                entry.requestedQuantity ??
                product.defaultPackageQuantity ??
                Quantity.fromDisplayAmount(1, product.canonicalUnit),
            frozenOn: _clock.todayLocal(),
          ),
        );
        // A batch that could not be added keeps its entry on the list.
        if (!result.isSuccess) continue;
        addedBatchCount++;
      }
      await _repository.deleteShoppingListEntry(entry.identifier);
    }
    await _reconcileShoppingList.execute();
    return Result.success(addedBatchCount);
  }
}
