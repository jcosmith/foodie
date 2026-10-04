import 'package:core_events/core_events.dart';

import 'category.dart';
import 'product.dart';

final class ProductCreated extends DomainEvent {
  const ProductCreated({required this.productIdentifier, required super.occurredAt});

  final ProductIdentifier productIdentifier;
}

/// A product's name, category, package size, storage time or icon changed.
final class ProductUpdated extends DomainEvent {
  const ProductUpdated({required this.productIdentifier, required super.occurredAt});

  final ProductIdentifier productIdentifier;
}

/// A product was hidden from pickers. Its history stays.
final class ProductArchived extends DomainEvent {
  const ProductArchived({required this.productIdentifier, required super.occurredAt});

  final ProductIdentifier productIdentifier;
}

/// A category's storage time changed, so storage ages of its products may change.
final class CategoryUpdated extends DomainEvent {
  const CategoryUpdated({required this.categoryIdentifier, required super.occurredAt});

  final CategoryIdentifier categoryIdentifier;
}

/// A product's unit was changed: [productIdentifier] replaces
/// [previousProductIdentifier], which was archived and keeps its stock and
/// history (decision D10, one unit per product). Features that link to
/// products, such as learned barcodes, move their links over.
final class ProductUnitChanged extends DomainEvent {
  const ProductUnitChanged({
    required this.previousProductIdentifier,
    required this.productIdentifier,
    required super.occurredAt,
  });

  final ProductIdentifier previousProductIdentifier;
  final ProductIdentifier productIdentifier;
}
