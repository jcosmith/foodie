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
