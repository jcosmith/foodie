import 'package:go_router/go_router.dart';

import '../domain/receipt.dart';
import 'receipt_detail_screen.dart';
import 'receipt_scan_screen.dart';

abstract final class ReceiptScanningRoutes {
  static const String scan = '/receipts/scan';
  static const String receiptPath = '/receipts/:receiptIdentifier';

  /// [highlightedLine] is marked, such as the line a search found.
  static String receipt(
    ReceiptIdentifier receiptIdentifier, {
    ReceiptLineIdentifier? highlightedLine,
  }) => Uri(
    path: '/receipts/${receiptIdentifier.value}',
    queryParameters: highlightedLine == null ? null : {'line': highlightedLine.value},
  ).toString();
}

List<RouteBase> buildReceiptScanningRoutes() => [
  GoRoute(path: ReceiptScanningRoutes.scan, builder: (context, state) => const ReceiptScanScreen()),
  GoRoute(
    path: ReceiptScanningRoutes.receiptPath,
    builder: (context, state) => ReceiptDetailScreen(
      receiptIdentifier: ReceiptIdentifier(state.pathParameters['receiptIdentifier']!),
      highlightedLine: switch (state.uri.queryParameters['line']) {
        final line? => ReceiptLineIdentifier(line),
        null => null,
      },
    ),
  ),
];
