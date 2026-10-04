import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/receipt_scanning_failure.dart';
import '../l10n/generated/receipt_scanning_localizations.dart';

/// Prices as printed, in the user's number format: "1.99" or "1,99". A
/// receipt does not say its currency reliably, so none is shown.
String formatCents(BuildContext context, int cents) => NumberFormat.decimalPatternDigits(
  locale: ReceiptScanningLocalizations.of(context).localeName,
  decimalDigits: 2,
).format(cents / 100);

/// Receipt text as printed, in a typewriter face.
TextStyle receiptTextStyle(BuildContext context) =>
    (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier'],
      fontWeight: FontWeight.w600,
    );

extension ReceiptScanningFailureTexts on ReceiptScanningLocalizations {
  String describeFailure(ReceiptScanningFailure failure) => switch (failure) {
    NoTextOnReceiptPhoto() => noTextOnPhoto,
    UnreadableReceiptPhoto() => unreadablePhoto,
    ReceiptLineNotOpen() => lineNotOpen,
  };
}
