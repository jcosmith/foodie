import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/category.dart';
import '../../domain/product.dart';
import '../../domain/product_catalog_repository.dart';
import '../../domain/seeded_catalog.dart';

/// Inserts the seeded categories and products that are not in the database
/// yet, matched by catalog key. Runs at every start, so entries added in a
/// later app version appear for existing users too, while entries the user
/// changed or archived are left alone.
final class SeedCatalogUseCase {
  const SeedCatalogUseCase({
    required ProductCatalogRepository repository,
    required TransactionRunner transactionRunner,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
  }) : _repository = repository,
       _transactionRunner = transactionRunner,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final ProductCatalogRepository _repository;
  final TransactionRunner _transactionRunner;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;

  /// Returns how many entries were added.
  Future<int> execute({
    List<SeededCategory> seededCategories = SeededCatalog.categories,
    List<SeededProduct> seededProducts = SeededCatalog.products,
  }) => _transactionRunner.runInTransaction(() async {
    var insertedCount = 0;
    final existingCategoryKeys = await _repository.readCategoryCatalogKeys();
    for (final (index, seededCategory) in seededCategories.indexed) {
      if (existingCategoryKeys.contains(seededCategory.catalogKey)) continue;
      await _repository.insertCategory(
        Category(
          identifier: _identifierGenerator.createIdentifier(),
          catalogKey: seededCategory.catalogKey,
          recommendedMaximumStorageDays: seededCategory.recommendedMaximumStorageDays,
          iconEmoji: seededCategory.iconEmoji,
          sortOrder: index,
          storageDomain: StorageDomainIdentifier.freezer,
        ),
      );
      insertedCount++;
    }

    final categoryIdentifierByKey = {
      for (final category in await _repository.readCategories())
        ?category.catalogKey: category.identifier,
    };
    final existingProductKeys = await _repository.readProductCatalogKeys();
    final createdAt = _clock.nowUtc();
    for (final seededProduct in seededProducts) {
      final categoryIdentifier = categoryIdentifierByKey[seededProduct.categoryCatalogKey];
      if (existingProductKeys.contains(seededProduct.catalogKey) || categoryIdentifier == null) {
        continue;
      }
      await _repository.insertProduct(
        Product(
          identifier: _identifierGenerator.createIdentifier(),
          categoryIdentifier: categoryIdentifier,
          catalogKey: seededProduct.catalogKey,
          canonicalUnit: seededProduct.canonicalUnit,
          defaultPackageQuantity: seededProduct.defaultPackageQuantity,
          iconEmoji: seededProduct.iconEmoji,
          createdAt: createdAt,
        ),
      );
      insertedCount++;
    }
    return insertedCount;
  });
}
