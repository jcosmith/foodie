import 'package:meta/meta.dart';

/// What a [QuantityUnit] measures. Quantities of different dimensions are never added up.
enum QuantityDimension { mass, volume, count }

/// The canonical unit of a product. Amounts are stored as integers in the
/// unit's base unit (decision D10), so partial removal is exact arithmetic.
enum QuantityUnit {
  /// Stored in whole grams.
  gram(dimension: QuantityDimension.mass, baseUnitsPerDisplayUnit: 1),

  /// Stored in whole millilitres.
  milliliter(dimension: QuantityDimension.volume, baseUnitsPerDisplayUnit: 1),

  /// Stored in thousandths of a piece, so half a pizza is exactly 500.
  piece(dimension: QuantityDimension.count, baseUnitsPerDisplayUnit: 1000),

  /// Stored in thousandths of a portion.
  portion(dimension: QuantityDimension.count, baseUnitsPerDisplayUnit: 1000);

  const QuantityUnit({required this.dimension, required this.baseUnitsPerDisplayUnit});

  final QuantityDimension dimension;

  /// How many stored base units make one displayed unit (1 g, 1 ml, 1 piece).
  final int baseUnitsPerDisplayUnit;

  /// Stable name used in the database and in backups; never rename.
  String get storageName => name;

  static QuantityUnit fromStorageName(String storageName) => QuantityUnit.values.firstWhere(
    (unit) => unit.storageName == storageName,
    orElse: () => throw ArgumentError.value(storageName, 'storageName', 'Unknown quantity unit'),
  );
}

/// An exact amount of something in a [QuantityUnit].
@immutable
final class Quantity implements Comparable<Quantity> {
  const Quantity({required this.amountInBaseUnits, required this.unit});

  /// Converts a displayed amount such as 0.5 pieces or 200 g into base units, rounding
  /// to the nearest base unit.
  factory Quantity.fromDisplayAmount(num displayAmount, QuantityUnit unit) => Quantity(
    amountInBaseUnits: (displayAmount * unit.baseUnitsPerDisplayUnit).round(),
    unit: unit,
  );

  const Quantity.zero(this.unit) : amountInBaseUnits = 0;

  final int amountInBaseUnits;
  final QuantityUnit unit;

  /// The amount in displayed units, for example 0.5 for half a piece.
  double get displayAmount => amountInBaseUnits / unit.baseUnitsPerDisplayUnit;

  bool get isZero => amountInBaseUnits == 0;

  bool get isPositive => amountInBaseUnits > 0;

  bool get isNegative => amountInBaseUnits < 0;

  Quantity operator +(Quantity other) {
    _requireSameUnit(other);
    return Quantity(amountInBaseUnits: amountInBaseUnits + other.amountInBaseUnits, unit: unit);
  }

  Quantity operator -(Quantity other) {
    _requireSameUnit(other);
    return Quantity(amountInBaseUnits: amountInBaseUnits - other.amountInBaseUnits, unit: unit);
  }

  Quantity operator -() => Quantity(amountInBaseUnits: -amountInBaseUnits, unit: unit);

  /// Multiplies by a fraction such as ¼ and rounds to the nearest base unit.
  Quantity scaledBy(double factor) =>
      Quantity(amountInBaseUnits: (amountInBaseUnits * factor).round(), unit: unit);

  bool isGreaterThan(Quantity other) => compareTo(other) > 0;

  bool isLessThan(Quantity other) => compareTo(other) < 0;

  bool hasSameUnitAs(Quantity other) => other.unit == unit;

  @override
  int compareTo(Quantity other) {
    _requireSameUnit(other);
    return amountInBaseUnits.compareTo(other.amountInBaseUnits);
  }

  void _requireSameUnit(Quantity other) {
    if (other.unit != unit) {
      throw ArgumentError('Cannot combine ${other.unit.name} with ${unit.name}');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Quantity && other.amountInBaseUnits == amountInBaseUnits && other.unit == unit;

  @override
  int get hashCode => Object.hash(amountInBaseUnits, unit);

  @override
  String toString() => '$displayAmount ${unit.name}';
}
