import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// A UUID-based identifier tagged with the kind of entity it identifies.
///
/// `TypedIdentifier<StockBatch>` and `TypedIdentifier<Product>` are different
/// types, so passing a product id where a batch id is expected fails at
/// compile time. Features declare short aliases such as
/// `typedef StockBatchIdentifier = TypedIdentifier<StockBatch>;`.
@immutable
final class TypedIdentifier<TEntity> {
  const TypedIdentifier(this.value);

  /// The UUID in its canonical lowercase text form.
  final String value;

  @override
  bool operator ==(Object other) => other is TypedIdentifier<TEntity> && other.value == value;

  @override
  int get hashCode => Object.hash(TEntity, value);

  @override
  String toString() => value;
}

/// Creates new identifiers; injected so tests get predictable values.
abstract interface class IdentifierGenerator {
  TypedIdentifier<TEntity> createIdentifier<TEntity>();
}

/// Generates random version 4 UUIDs.
final class UuidIdentifierGenerator implements IdentifierGenerator {
  const UuidIdentifierGenerator();

  static const Uuid _uuid = Uuid();

  @override
  TypedIdentifier<TEntity> createIdentifier<TEntity>() => TypedIdentifier<TEntity>(_uuid.v4());
}

/// Produces `00000000-0000-4000-8000-000000000001`, `...002` and so on; for tests.
final class SequentialIdentifierGenerator implements IdentifierGenerator {
  SequentialIdentifierGenerator({int firstSequenceNumber = 1})
    : _nextSequenceNumber = firstSequenceNumber;

  int _nextSequenceNumber;

  @override
  TypedIdentifier<TEntity> createIdentifier<TEntity>() {
    final sequenceText = (_nextSequenceNumber++).toRadixString(16).padLeft(12, '0');
    return TypedIdentifier<TEntity>('00000000-0000-4000-8000-$sequenceText');
  }
}
