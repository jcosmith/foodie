import 'package:core_foundation/core_foundation.dart';

sealed class BarcodeScanningFailure extends Failure {
  const BarcodeScanningFailure();
}

/// The product to learn a code for is gone or archived.
final class BarcodeProductUnavailable extends BarcodeScanningFailure {
  const BarcodeProductUnavailable();

  @override
  String get debugDescription => 'The product for this code is not available';
}
