import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';

import '../../domain/restock_failure.dart';
import '../../domain/restock_repository.dart';
import '../../domain/restock_rule.dart';
import 'reconcile_shopping_list_use_case.dart';

/// Sets the minimum (and optionally the target) quantity of a product.
final class SaveRestockRuleUseCase {
  const SaveRestockRuleUseCase({
    required RestockRepository repository,
    required ProductCatalogQueryService productCatalog,
    required ReconcileShoppingListUseCase reconcileShoppingList,
  }) : _repository = repository,
       _productCatalog = productCatalog,
       _reconcileShoppingList = reconcileShoppingList;

  final RestockRepository _repository;
  final ProductCatalogQueryService _productCatalog;
  final ReconcileShoppingListUseCase _reconcileShoppingList;

  Future<Result<Unit, RestockFailure>> execute({
    required ProductIdentifier productIdentifier,
    required Quantity minimumQuantity,
    Quantity? targetQuantity,
  }) async {
    final product = await _productCatalog.readProduct(productIdentifier);
    if (product == null) return const Result.failure(RestockProductNotFound());
    if (minimumQuantity.unit != product.canonicalUnit ||
        (targetQuantity != null && targetQuantity.unit != product.canonicalUnit)) {
      return const Result.failure(RestockUnitMismatch());
    }
    if (!minimumQuantity.isPositive) return const Result.failure(MinimumQuantityNotPositive());
    if (targetQuantity != null && targetQuantity.isLessThan(minimumQuantity)) {
      return const Result.failure(TargetBelowMinimum());
    }

    await _repository.saveRule(
      RestockRule(
        productIdentifier: productIdentifier,
        minimumQuantity: minimumQuantity,
        targetQuantity: targetQuantity,
        isActive: true,
      ),
    );
    await _reconcileShoppingList.execute();
    return const Result.success(unit);
  }
}

/// Stops watching a product; its running-low entry leaves the list.
final class RemoveRestockRuleUseCase {
  const RemoveRestockRuleUseCase({
    required RestockRepository repository,
    required ReconcileShoppingListUseCase reconcileShoppingList,
  }) : _repository = repository,
       _reconcileShoppingList = reconcileShoppingList;

  final RestockRepository _repository;
  final ReconcileShoppingListUseCase _reconcileShoppingList;

  Future<void> execute(ProductIdentifier productIdentifier) async {
    await _repository.deleteRule(productIdentifier);
    await _reconcileShoppingList.execute();
  }
}
