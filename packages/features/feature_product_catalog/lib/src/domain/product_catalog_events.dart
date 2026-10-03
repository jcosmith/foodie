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
