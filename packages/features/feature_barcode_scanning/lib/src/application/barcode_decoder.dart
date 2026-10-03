import 'package:flutter/widgets.dart';

import '../domain/scanned_barcode.dart';

/// Why the camera shows no picture.
enum CameraProblem { permissionDenied, unavailable }

/// The on-device decoder behind the camera view (decision D12). The app uses
/// mobile_scanner; keeping it behind this interface lets it be swapped for
/// flutter_zxing and replaced by a fake in tests.
abstract interface class BarcodeDecoder {
  /// The live camera picture. Calls [onBarcodeDetected] for every code it
  /// decodes; [problemBuilder] replaces the picture when there is none.
  Widget buildCameraView(
    BuildContext context, {
    required ValueChanged<ScannedBarcode> onBarcodeDetected,
    required Widget Function(BuildContext context, CameraProblem problem) problemBuilder,
  });
}
