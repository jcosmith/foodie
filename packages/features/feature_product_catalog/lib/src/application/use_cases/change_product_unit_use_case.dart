import 'package:core_database/core_database.dart';
import 'package:core_events/core_events.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/product.dart';
import '../../domain/product_catalog_events.dart';
import '../../domain/product_catalog_failure.dart';
import '../../domain/product_catalog_repository.dart';
import '../../domain/product_name_policy.dart';

/// Changes how a product is counted. Every quantity of a product is stored
/// in its one unit (decision D10), so this creates a new product with the
/// same name and settings in [newUnit] and archives the old one: its stock
/// stays listed until used up and its history stays in Statistics.
final class ChangeProductUnitUseCase {
  const ChangeProductUnitUseCase({
    required ProductCatalogRepository repository,
    required TransactionRunner transactionRunner,
    required DomainEventBus domainEventBus,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
  }) : _repository = repository,
       _transactionRunner = transactionRunner,
       _domainEventBus = domainEventBus,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final ProductCatalogRepository _repository;
  final TransactionRunner _transactionRunner;
  final DomainEventBus _domainEventBus;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;

  /// [displayName] is the name the user sees, so a seeded product keeps its
  /// translated name; returns the new product.
  Future<Result<ProductIdentifier, ProductCatalogFailure>> execute({
    required ProductIdentifier productIdentifier,
    required QuantityUnit newUnit,
    required String displayName,
  }) async {
    final nameValidation = ProductNamePolicy.validate(displayName);
    if (nameValidation case FailedResult(:final failure)) return Result.failure(failure);
    final result = await _transactionRunner.runInTransaction(() async {
      final product = await _repository.readProduct(productIdentifier);
      if (product == null || product.isArchived) {
        return const Result<ProductUnitChanged, ProductCatalogFailure>.failure(ProductNotFound());
      }
      if (product.canonicalUnit == newUnit) {
        return const Result<ProductUnitChanged, ProductCatalogFailure>.failure(
          InvalidProductSetting(),
        );
      }
      final now = _clock.nowUtc();
      final replacement = Product(
        identifier: _identifierGenerator.createIdentifier(),
        categoryIdentifier: product.categoryIdentifier,
        customName: nameValidation.valueOrNull,
        canonicalUnit: newUnit,
        // The package size was in the old unit.
        recommendedMaximumStorageDays: product.recommendedMaximumStorageDays,
        shelfLifeAfterOpeningDays: product.shelfLifeAfterOpeningDays,
        iconEmoji: product.iconEmoji,
        iconImage: product.iconImage,
        defaultCompartmentIdentifier: product.defaultCompartmentIdentifier,
        pieceLabel: newUnit == QuantityUnit.piece ? product.pieceLabel : null,
        createdAt: now,
      );
      await _repository.insertProduct(replacement);
      await _repository.updateProduct(product.copyWith(isArchived: true));
      return Result<ProductUnitChanged, ProductCatalogFailure>.success(
        ProductUnitChanged(
          previousProductIdentifier: product.identifier,
          productIdentifier: replacement.identifier,
          occurredAt: now,
        ),
      );
    });
    if (result case SuccessfulResult(value: final event)) {
      await _domainEventBus.publish(
        ProductCreated(productIdentifier: event.productIdentifier, occurredAt: event.occurredAt),
      );
      await _domainEventBus.publish(
        ProductArchived(
          productIdentifier: event.previousProductIdentifier,
          occurredAt: event.occurredAt,
        ),
      );
      await _domainEventBus.publish(event);
    }
    return result.mapValue((event) => event.productIdentifier);
  }
}
