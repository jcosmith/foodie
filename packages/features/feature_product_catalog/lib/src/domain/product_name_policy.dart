import 'package:core_foundation/core_foundation.dart';

import 'product_catalog_failure.dart';

/// Names users give products: required, at most 40 characters.
abstract final class ProductNamePolicy {
  static const int maximumNameLength = 40;

  /// Returns the trimmed name to store.
  static Result<String, ProductCatalogFailure> validate(String enteredName) {
    final trimmedName = enteredName.trim();
    if (trimmedName.isEmpty) return const Result.failure(ProductNameMissing());
    if (trimmedName.runes.length > maximumNameLength) {
      return const Result.failure(ProductNameTooLong());
    }
    return Result.success(trimmedName);
  }
}
