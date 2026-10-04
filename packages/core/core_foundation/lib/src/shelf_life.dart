/// The unit a shelf life is entered in.
enum ShelfLifeUnit { days, weeks, months }

/// How long something keeps, as the user entered it: "2 days", "3 weeks",
/// "9 months". Stored as days; a month counts 30.4 days, so 12 months are
/// 365 days.
final class ShelfLife {
  const ShelfLife(this.amount, this.unit);

  /// The unit a number of stored days was most likely entered in: months
  /// when the days are a whole number of months, else weeks, else days.
  /// Always gives back the same number of days.
  factory ShelfLife.fromDays(int days) {
    final months = (days / averageDaysPerMonth).round();
    if (months >= 1 && ShelfLife(months, ShelfLifeUnit.months).inDays == days) {
      return ShelfLife(months, ShelfLifeUnit.months);
    }
    if (days >= 7 && days % 7 == 0) return ShelfLife(days ~/ 7, ShelfLifeUnit.weeks);
    return ShelfLife(days, ShelfLifeUnit.days);
  }

  static const double averageDaysPerMonth = 30.4;

  /// One day is the shortest shelf life (fresh herbs, bakery rolls).
  static const int minimumInDays = 1;

  /// 36 months is the longest.
  static final int maximumInDays = const ShelfLife(36, ShelfLifeUnit.months).inDays;

  final int amount;
  final ShelfLifeUnit unit;

  int get inDays => switch (unit) {
    ShelfLifeUnit.days => amount,
    ShelfLifeUnit.weeks => amount * 7,
    ShelfLifeUnit.months => (amount * averageDaysPerMonth).round(),
  };

  bool get isWithinLimits => inDays >= minimumInDays && inDays <= maximumInDays;

  @override
  bool operator ==(Object other) =>
      other is ShelfLife && other.amount == amount && other.unit == unit;

  @override
  int get hashCode => Object.hash(amount, unit);

  @override
  String toString() => '$amount ${unit.name}';
}
