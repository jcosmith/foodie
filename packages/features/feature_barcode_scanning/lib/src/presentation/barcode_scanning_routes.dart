import 'package:go_router/go_router.dart';

import 'barcode_scanner_screen.dart';

/// Scan to add puts into storage; scan to remove takes out.
enum ScanMode { add, remove }

abstract final class BarcodeScanningRoutes {
  static const String scannerPath = '/barcode_scanning/scan';

  static String scanner(ScanMode mode) =>
      Uri(path: scannerPath, queryParameters: {'mode': mode.name}).toString();
}

List<RouteBase> buildBarcodeScanningRoutes() => [
  GoRoute(
    path: BarcodeScanningRoutes.scannerPath,
    builder: (context, state) => BarcodeScannerScreen(
      initialMode: ScanMode.values.asNameMap()[state.uri.queryParameters['mode']] ?? ScanMode.add,
    ),
  ),
];
