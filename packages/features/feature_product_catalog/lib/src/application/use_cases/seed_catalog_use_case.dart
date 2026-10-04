import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';

import '../../domain/category.dart';
import '../../domain/product.dart';
import '../../domain/product_catalog_repository.dart';
import '../../domain/seeded_catalog.dart';

/// Inserts the seeded categories and products of every module that are not
/// in the database yet, matched by catalog key. Runs at every start, so
/// entries added in a later app version appear for existing users too, while
/// entries the user changed or archived are left alone. New categories go
/// after the ones that exist, keeping the user's order.
final class SeedCatalogUseCase {
  const SeedCatalogUseCase({
    required ProductCatalogRepository repository,
    required TransactionRunner transactionRunner,
    required Clock clock,
    required IdentifierGenerator identifierGenerator,
    required SeededCatalog seededCatalog,
  }) : _repository = repository,
       _seededCatalog = seededCatalog,
       _transactionRunner = transactionRunner,
       _clock = clock,
       _identifierGenerator = identifierGenerator;

  final ProductCatalogRepository _repository;
  final TransactionRunner _transactionRunner;
  final Clock _clock;
  final IdentifierGenerator _identifierGenerator;
  final SeededCatalog _seededCatalog;

  /// Returns how many entries were added. [catalog] replaces the catalog of
  /// the registered modules, for tests of later versions.
  Future<int> execute({SeededCatalog? catalog}) => _transactionRunner.runInTransaction(() async {
    final seededCatalog = catalog ?? _seededCatalog;
    var insertedCount = 0;
    final existingCategories = await _repository.readCategories();
    final existingCategoryKeys = {for (final category in existingCategories) ?category.catalogKey};
    var nextSortOrder = existingCategories.fold(
      0,
      (next, category) => category.sortOrder >= next ? category.sortOrder + 1 : next,
    );
    for (final seededCategory in seededCatalog.categories) {
      if (!existingCategoryKeys.add(seededCategory.catalogKey)) continue;
      await _repository.insertCategory(
        Category(
          identifier: _identifierGenerator.createIdentifier(),
          catalogKey: seededCategory.catalogKey,
          recommendedMaximumStorageDays: seededCategory.recommendedMaximumStorageDays,
          shelfLifeAfterOpeningDays: seededCategory.shelfLifeAfterOpeningDays,
          iconEmoji: seededCategory.iconEmoji,
          sortOrder: nextSortOrder++,
          storageDomain: seededCategory.storageDomain,
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
    for (final seededProduct in seededCatalog.products) {
      final categoryIdentifier = categoryIdentifierByKey[seededProduct.categoryCatalogKey];
      if (categoryIdentifier == null || !existingProductKeys.add(seededProduct.catalogKey)) {
        continue;
      }
      await _repository.insertProduct(
        Product(
          identifier: _identifierGenerator.createIdentifier(),
          categoryIdentifier: categoryIdentifier,
          catalogKey: seededProduct.catalogKey,
          canonicalUnit: seededProduct.canonicalUnit,
          defaultPackageQuantity: seededProduct.defaultPackageQuantity,
          recommendedMaximumStorageDays: seededProduct.recommendedMaximumStorageDays,
          shelfLifeAfterOpeningDays: seededProduct.shelfLifeAfterOpeningDays,
          iconEmoji: seededProduct.iconEmoji,
          createdAt: createdAt,
        ),
      );
      insertedCount++;
    }
    return insertedCount;
  });
}
