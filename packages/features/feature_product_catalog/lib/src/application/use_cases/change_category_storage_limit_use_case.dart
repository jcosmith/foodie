import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/category.dart';
import '../../domain/product_catalog_events.dart';
import '../../domain/product_catalog_failure.dart';
import '../../domain/product_catalog_repository.dart';

/// Sets how long food of a category keeps at home. Products with their
/// own storage time keep it.
final class ChangeCategoryStorageLimitUseCase {
  const ChangeCategoryStorageLimitUseCase({
    required ProductCatalogRepository repository,
    required DomainEventBus domainEventBus,
    required Clock clock,
  }) : _repository = repository,
       _domainEventBus = domainEventBus,
       _clock = clock;

  final ProductCatalogRepository _repository;
  final DomainEventBus _domainEventBus;
  final Clock _clock;

  Future<Result<Unit, ProductCatalogFailure>> execute({
    required CategoryIdentifier categoryIdentifier,
    required int recommendedMaximumStorageDays,
  }) async {
    if (recommendedMaximumStorageDays <= 0) return const Result.failure(InvalidProductSetting());
    final categories = await _repository.readCategories();
    final category = categories
        .where((candidate) => candidate.identifier == categoryIdentifier)
        .firstOrNull;
    if (category == null) return const Result.failure(CategoryNotFound());
    if (category.recommendedMaximumStorageDays == recommendedMaximumStorageDays) {
      return const Result.success(unit);
    }

    await _repository.updateCategory(
      category.withRecommendedMaximumStorageDays(recommendedMaximumStorageDays),
    );
    await _domainEventBus.publish(
      CategoryUpdated(categoryIdentifier: categoryIdentifier, occurredAt: _clock.nowUtc()),
    );
    return const Result.success(unit);
  }
}
