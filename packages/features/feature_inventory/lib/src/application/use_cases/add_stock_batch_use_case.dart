import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:meta/meta.dart';

import '../../domain/inventory_events.dart';
import '../../domain/inventory_failure.dart';
import '../../domain/inventory_movement.dart';
import '../../domain/stock_batch.dart';
import 'inventory_use_case_dependencies.dart';

/// What the add form (or a barcode scan) submits.
@immutable
final class AddStockBatchCommand {
  const AddStockBatchCommand({
    required this.productIdentifier,
    required this.compartmentIdentifier,
    required this.quantity,
    required this.frozenOn,
    this.bestBeforeOn,
    this.note,
  });

  final ProductIdentifier productIdentifier;
  final CompartmentIdentifier compartmentIdentifier;
  final Quantity quantity;
  final CalendarDate frozenOn;
  final CalendarDate? bestBeforeOn;
  final String? note;
}

/// Puts a new bag or box into a compartment and records an "added" movement.
/// Part of the public API, so barcode scanning adds exactly like the form.
final class AddStockBatchUseCase {
  const AddStockBatchUseCase({
    required InventoryUseCaseDependencies dependencies,
    required ProductCatalogQueryService productCatalog,
    required StorageLayoutQueryService storageLayout,
  }) : _dependencies = dependencies,
       _productCatalog = productCatalog,
       _storageLayout = storageLayout;

  final InventoryUseCaseDependencies _dependencies;
  final ProductCatalogQueryService _productCatalog;
  final StorageLayoutQueryService _storageLayout;

  Future<Result<StockBatchIdentifier, InventoryFailure>> execute(
    AddStockBatchCommand command,
  ) async {
    switch (await executeAll([command])) {
      case SuccessfulResult(value: final stockBatchIdentifiers):
        return Result.success(stockBatchIdentifiers.single);
      case FailedResult(:final failure):
        return Result.failure(failure);
    }
  }

  /// Adds several batches in one transaction, such as the groceries scanned
  /// in a row (section 10.3): either all of them or, when one is invalid,
  /// none. Events are published once everything is stored.
  Future<Result<List<StockBatchIdentifier>, InventoryFailure>> executeAll(
    List<AddStockBatchCommand> commands,
  ) async {
    final batches = <StockBatch>[];
    for (final command in commands) {
      switch (await _createBatch(command)) {
        case SuccessfulResult(value: final batch):
          batches.add(batch);
        case FailedResult(:final failure):
          return Result.failure(failure);
      }
    }
    await _dependencies.transactionRunner.runInTransaction(() async {
      for (final batch in batches) {
        await _dependencies.repository.insertBatch(batch);
        await _dependencies.repository.appendMovement(
          InventoryMovement(
            identifier: _dependencies.identifierGenerator.createIdentifier(),
            stockBatchIdentifier: batch.identifier,
            productIdentifier: batch.productIdentifier,
            compartmentIdentifier: batch.compartmentIdentifier,
            kind: MovementKind.added,
            quantityDelta: batch.initialQuantity,
            occurredAt: batch.createdAt,
          ),
        );
      }
    });
    for (final batch in batches) {
      await _dependencies.domainEventBus.publish(
        StockBatchAdded(
          stockBatchIdentifier: batch.identifier,
          productIdentifier: batch.productIdentifier,
          compartmentIdentifier: batch.compartmentIdentifier,
          quantity: batch.initialQuantity,
          occurredAt: batch.createdAt,
        ),
      );
    }
    return Result.success([for (final batch in batches) batch.identifier]);
  }

  /// Checks a command and builds its batch without storing anything.
  Future<Result<StockBatch, InventoryFailure>> _createBatch(AddStockBatchCommand command) async {
    if (!command.quantity.isPositive) return const Result.failure(QuantityNotPositive());
    final product = await _productCatalog.readProduct(command.productIdentifier);
    if (product == null || product.isArchived) return const Result.failure(ProductNotAvailable());
    if (command.quantity.unit != product.canonicalUnit) {
      return const Result.failure(QuantityUnitMismatch());
    }
    final compartment = await _storageLayout.readCompartment(command.compartmentIdentifier);
    if (compartment == null || compartment.isArchived) {
      return const Result.failure(CompartmentNotAvailable());
    }
    if (command.frozenOn.isAfter(_dependencies.clock.todayLocal())) {
      return const Result.failure(FrozenOnInFuture());
    }
    final trimmedNote = command.note?.trim();
    return Result.success(
      StockBatch(
        identifier: _dependencies.identifierGenerator.createIdentifier(),
        productIdentifier: product.identifier,
        compartmentIdentifier: compartment.identifier,
        initialQuantity: command.quantity,
        quantityRemaining: command.quantity,
        frozenOn: command.frozenOn,
        bestBeforeOn: command.bestBeforeOn,
        note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
        createdAt: _dependencies.clock.nowUtc(),
      ),
    );
  }
}
