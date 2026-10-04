import 'package:core_preferences/core_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/receipt_scanning_providers.dart';
import '../domain/receipt_photo_retention.dart';
import '../l10n/generated/receipt_scanning_localizations.dart';

/// "Receipts" in Options: how long receipt photos are kept.
class ReceiptConfigSection extends ConsumerWidget {
  const ReceiptConfigSection({super.key});

  Future<void> _choose(WidgetRef ref, ReceiptPhotoRetention retention) async {
    await ref.read(preferencesStoreProvider).write(ReceiptPreferenceKeys.photoRetention, retention);
    await ref.read(applyReceiptPhotoRetentionUseCaseProvider).execute(retention);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ReceiptScanningLocalizations.of(context);
    final retention =
        ref.watch(receiptPhotoRetentionProvider).value ?? ReceiptPhotoRetention.forever;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(localizations.photoRetentionExplanation, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReceiptPhotoRetention>(
          initialValue: retention,
          isExpanded: true,
          decoration: InputDecoration(labelText: localizations.photoRetentionLabel),
          items: [
            for (final option in ReceiptPhotoRetention.values)
              DropdownMenuItem(
                value: option,
                child: Text(switch (option.months) {
                  null => localizations.photoRetentionForever,
                  final months => localizations.photoRetentionMonths(months),
                }),
              ),
          ],
          onChanged: (option) {
            if (option != null) _choose(ref, option);
          },
        ),
      ],
    );
  }
}
