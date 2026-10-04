/// How long receipt photos are kept (architecture 10.10, "Retention"). The
/// text and the lines always stay; the photos take most of the space.
enum ReceiptPhotoRetention {
  forever(null),
  twelveMonths(12),
  sixMonths(6),
  threeMonths(3);

  const ReceiptPhotoRetention(this.months);

  /// `null` keeps photos until the receipt is deleted.
  final int? months;

  /// Photos of receipts scanned before this are deleted; `null` for none.
  DateTime? cutoffBefore(DateTime now) {
    final months = this.months;
    if (months == null) return null;
    return DateTime.utc(now.year, now.month - months, now.day, now.hour, now.minute);
  }
}
