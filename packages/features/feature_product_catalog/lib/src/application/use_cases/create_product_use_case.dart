import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/product.dart';
import '../../domain/product_catalog_events.dart';
import '../../domain/product_catalog_failure.dart';
import '../../domain/product_catalog_repository.dart';
import '../../domain/product_name_policy.dart';
import 'product_settings.dart';

/// Adds a product the user defined. Its unit is fixed from now on (decision D10).
final class CreateProductUseCase {
  const CreateProductUseCase({
    required ProductCatalogRepository repository,
    required DomainEventBus domainEventBus,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
  }) : _repository = repository,
       _domainEventBus = domainEventBus,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final ProductCatalogRepository _repository;
  final DomainEventBus _domainEventBus;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;

  Future<Result<ProductIdentifier, ProductCatalogFailure>> execute({
    required ProductSettings settings,
    required QuantityUnit canonicalUnit,
  }) async {
    final nameValidation = ProductNamePolicy.validate(settings.enteredName);
    if (nameValidation case FailedResult(:final failure)) return Result.failure(failure);
    if (settings.validateNumbers() case final failure?) return Result.failure(failure);
    final categories = await _repository.readCategories();
    if (!categories.any((category) => category.identifier == settings.categoryIdentifier)) {
      return const Result.failure(CategoryNotFound());
    }
    final packageQuantity = settings.defaultPackageQuantity;
    if (packageQuantity != null && packageQuantity.unit != canonicalUnit) {
      return const Result.failure(InvalidProductSetting());
    }

    final product = Product(
      identifier: _identifierGenerator.createIdentifier(),
      categoryIdentifier: settings.categoryIdentifier,
      customName: nameValidation.valueOrNull,
      canonicalUnit: canonicalUnit,
      defaultPackageQuantity: packageQuantity,
      recommendedMaximumStorageDays: settings.recommendedMaximumStorageDays,
      shelfLifeAfterOpeningDays: settings.shelfLifeAfterOpeningDays,
      iconEmoji: settings.trimmedIconEmoji,
      iconImage: settings.iconImage,
      defaultCompartmentIdentifier: settings.defaultCompartmentIdentifier,
      createdAt: _clock.nowUtc(),
    );
    await _repository.insertProduct(product);
    await _domainEventBus.publish(
      ProductCreated(productIdentifier: product.identifier, occurredAt: product.createdAt),
    );
    return Result.success(product.identifier);
  }
}
