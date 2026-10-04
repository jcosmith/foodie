import 'package:core_foundation/core_foundation.dart';

/// Why something on a receipt could not be done.
sealed class ReceiptScanningFailure extends Failure {
  const ReceiptScanningFailure();
}

/// The line is gone, or was already added or ignored.
final class ReceiptLineNotOpen extends ReceiptScanningFailure {
  const ReceiptLineNotOpen();

  @override
  String get debugDescription => 'The receipt line is not open';
}

/// Recognition found no text on the photo: blurred, dark, or no receipt.
final class NoTextOnReceiptPhoto extends ReceiptScanningFailure {
  const NoTextOnReceiptPhoto();

  @override
  String get debugDescription => 'No text on the receipt photo';
}

/// The photo could not be read or recognised.
final class UnreadableReceiptPhoto extends ReceiptScanningFailure {
  const UnreadableReceiptPhoto();

  @override
  String get debugDescription => 'The receipt photo is unreadable';
}
