import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/product.dart';
import '../../domain/product_catalog_events.dart';
import '../../domain/product_catalog_failure.dart';
import '../../domain/product_catalog_repository.dart';

/// Hides a product from pickers. Stock and history keep referring to it.
final class ArchiveProductUseCase {
  const ArchiveProductUseCase({
    required ProductCatalogRepository repository,
    required DomainEventBus domainEventBus,
    required Clock clock,
  }) : _repository = repository,
       _domainEventBus = domainEventBus,
       _clock = clock;

  final ProductCatalogRepository _repository;
  final DomainEventBus _domainEventBus;
  final Clock _clock;

  Future<Result<Unit, ProductCatalogFailure>> execute(ProductIdentifier productIdentifier) async {
    final product = await _repository.readProduct(productIdentifier);
    if (product == null) return const Result.failure(ProductNotFound());
    if (product.isArchived) return const Result.success(unit);
    await _repository.updateProduct(product.copyWith(isArchived: true));
    await _domainEventBus.publish(
      ProductArchived(productIdentifier: productIdentifier, occurredAt: _clock.nowUtc()),
    );
    return const Result.success(unit);
  }
}
