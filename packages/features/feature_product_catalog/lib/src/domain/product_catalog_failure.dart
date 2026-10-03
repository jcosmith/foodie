import 'package:core_foundation/core_foundation.dart';

/// Why a change to the product catalog was refused.
sealed class ProductCatalogFailure extends Failure {
  const ProductCatalogFailure();
}

final class ProductNameMissing extends ProductCatalogFailure {
  const ProductNameMissing();

  @override
  String get debugDescription => 'A product needs a name';
}

final class ProductNameTooLong extends ProductCatalogFailure {
  const ProductNameTooLong();

  @override
  String get debugDescription => 'The product name is too long';
}

final class ProductNotFound extends ProductCatalogFailure {
  const ProductNotFound();

  @override
  String get debugDescription => 'The product does not exist';
}

final class CategoryNotFound extends ProductCatalogFailure {
  const CategoryNotFound();

  @override
  String get debugDescription => 'The category does not exist';
}

/// Package sizes and storage times must be positive.
final class InvalidProductSetting extends ProductCatalogFailure {
  const InvalidProductSetting();

  @override
  String get debugDescription => 'Package size and storage time must be positive';
}

/// The chosen file is no picture the app can read.
final class UnreadableIconImage extends ProductCatalogFailure {
  const UnreadableIconImage();

  @override
  String get debugDescription => 'The icon picture could not be read';
}
