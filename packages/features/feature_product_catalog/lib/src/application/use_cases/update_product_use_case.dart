import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/product.dart';
import '../../domain/product_catalog_events.dart';
import '../../domain/product_catalog_failure.dart';
import '../../domain/product_catalog_repository.dart';
import '../../domain/product_name_policy.dart';
import 'product_settings.dart';

/// Changes a product's name, category, package size, storage time, icon or
/// default drawer.
///
/// The unit never changes here: stock is stored in it (decision D10), and
/// converting existing batches needs its own use case.
final class UpdateProductUseCase {
  const UpdateProductUseCase({
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
    required ProductIdentifier productIdentifier,
    required ProductSettings settings,
  }) async {
    final product = await _repository.readProduct(productIdentifier);
    if (product == null) return const Result.failure(ProductNotFound());

    // A seeded product goes back to its translated name when the name is cleared.
    final String? customName;
    if (product.catalogKey != null && settings.enteredName.trim().isEmpty) {
      customName = null;
    } else {
      final nameValidation = ProductNamePolicy.validate(settings.enteredName);
      if (nameValidation case FailedResult(:final failure)) return Result.failure(failure);
      customName = nameValidation.valueOrNull;
    }
    if (settings.validateNumbers() case final failure?) return Result.failure(failure);
    final packageQuantity = settings.defaultPackageQuantity;
    if (packageQuantity != null && packageQuantity.unit != product.canonicalUnit) {
      return const Result.failure(InvalidProductSetting());
    }
    final categories = await _repository.readCategories();
    if (!categories.any((category) => category.identifier == settings.categoryIdentifier)) {
      return const Result.failure(CategoryNotFound());
    }

    await _repository.updateProduct(
      product.copyWith(
        categoryIdentifier: settings.categoryIdentifier,
        customName: () => customName,
        defaultPackageQuantity: () => packageQuantity,
        recommendedMaximumStorageDays: () => settings.recommendedMaximumStorageDays,
        shelfLifeAfterOpeningDays: () => settings.shelfLifeAfterOpeningDays,
        iconEmoji: () => settings.trimmedIconEmoji,
        iconImage: () => settings.iconImage,
        defaultCompartmentIdentifier: () => settings.defaultCompartmentIdentifier,
        pieceLabel: () => settings.pieceLabelFor(product.canonicalUnit),
      ),
    );
    await _domainEventBus.publish(
      ProductUpdated(productIdentifier: productIdentifier, occurredAt: _clock.nowUtc()),
    );
    return const Result.success(unit);
  }
}
