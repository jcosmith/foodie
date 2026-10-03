import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../application/barcode_decoder.dart';
import '../domain/scanned_barcode.dart';

/// The camera decoder (decision D12): on Android ML Kit with the model
/// bundled inside the app (mobile_scanner's default; the unbundled variant,
/// which downloads the model, is never switched on), on iOS Apple's Vision
/// framework. Both decode on the phone, and the release build has no
/// network permission at all. The camera permission is asked for when the
/// camera first starts, that is on the first scan.
final class MobileScannerBarcodeDecoder implements BarcodeDecoder {
  const MobileScannerBarcodeDecoder();

  @override
  Widget buildCameraView(
    BuildContext context, {
    required ValueChanged<ScannedBarcode> onBarcodeDetected,
    required Widget Function(BuildContext context, CameraProblem problem) problemBuilder,
  }) => _MobileScannerCameraView(
    onBarcodeDetected: onBarcodeDetected,
    problemBuilder: problemBuilder,
  );
}

class _MobileScannerCameraView extends StatefulWidget {
  const _MobileScannerCameraView({required this.onBarcodeDetected, required this.problemBuilder});

  final ValueChanged<ScannedBarcode> onBarcodeDetected;
  final Widget Function(BuildContext context, CameraProblem problem) problemBuilder;

  @override
  State<_MobileScannerCameraView> createState() => _MobileScannerCameraViewState();
}

class _MobileScannerCameraViewState extends State<_MobileScannerCameraView> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.qrCode,
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCapture(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;
      widget.onBarcodeDetected(
        ScannedBarcode(value: value, symbology: _symbologyOf(barcode.format)),
      );
    }
  }

  static BarcodeSymbology _symbologyOf(BarcodeFormat format) => switch (format) {
    BarcodeFormat.ean13 => BarcodeSymbology.ean13,
    BarcodeFormat.ean8 => BarcodeSymbology.ean8,
    BarcodeFormat.upcA => BarcodeSymbology.upcA,
    BarcodeFormat.upcE => BarcodeSymbology.upcE,
    BarcodeFormat.code128 => BarcodeSymbology.code128,
    BarcodeFormat.qrCode => BarcodeSymbology.qrCode,
    _ => BarcodeSymbology.other,
  };

  @override
  Widget build(BuildContext context) => MobileScanner(
    controller: _controller,
    onDetect: _handleCapture,
    errorBuilder: (context, exception) => widget.problemBuilder(
      context,
      exception.errorCode == MobileScannerErrorCode.permissionDenied
          ? CameraProblem.permissionDenied
          : CameraProblem.unavailable,
    ),
  );
}
