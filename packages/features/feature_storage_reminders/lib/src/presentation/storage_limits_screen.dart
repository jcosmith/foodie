import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/storage_reminders_localizations.dart';

/// Storage times are entered in months, like in the product editor.
abstract final class StorageMonthConversion {
  static const double averageDaysPerMonth = 30.4;
  static const int maximumMonths = 36;

  static int monthsFromDays(int days) {
    final months = (days / averageDaysPerMonth).round();
    return months < 1 ? 1 : months;
  }

  static int daysFromMonths(int months) => (months * averageDaysPerMonth).round();
}

/// "Storage limits" from the Reminders section: how long each category
/// keeps; changing one moves the age badges and the reminders at once.
class StorageLimitsScreen extends ConsumerWidget {
  const StorageLimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = StorageRemindersLocalizations.of(context);
    final catalog = ref.watch(productCatalogProvider).value;
    final nameResolver = context.productDisplayNameResolver;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.storageLimitsTitle)),
      body: catalog == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(FreezerSpacing.screenGutter),
                  child: Text(
                    localizations.storageLimitsExplanation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                for (final category in catalog.categories)
                  ListTile(
                    leading: ProductIcon(emoji: category.iconEmoji, size: 28),
                    title: Text(nameResolver.categoryName(category)),
                    trailing: Text(
                      localizations.storageMonths(
                        StorageMonthConversion.monthsFromDays(
                          category.recommendedMaximumStorageDays,
                        ),
                      ),
                    ),
                    onTap: () => _editStorageLimit(context, ref, category),
                  ),
              ],
            ),
    );
  }

  Future<void> _editStorageLimit(BuildContext context, WidgetRef ref, Category category) async {
    final chosenMonths = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _StorageMonthsDialog(
        title: context.productDisplayNameResolver.categoryName(category),
        initialMonths: StorageMonthConversion.monthsFromDays(
          category.recommendedMaximumStorageDays,
        ),
      ),
    );
    if (chosenMonths == null) return;
    await ref
        .read(changeCategoryStorageLimitUseCaseProvider)
        .execute(
          categoryIdentifier: category.identifier,
          recommendedMaximumStorageDays: StorageMonthConversion.daysFromMonths(chosenMonths),
        );
  }
}

class _StorageMonthsDialog extends StatefulWidget {
  const _StorageMonthsDialog({required this.title, required this.initialMonths});

  final String title;
  final int initialMonths;

  @override
  State<_StorageMonthsDialog> createState() => _StorageMonthsDialogState();
}

class _StorageMonthsDialogState extends State<_StorageMonthsDialog> {
  late final TextEditingController _monthsController = TextEditingController(
    text: '${widget.initialMonths}',
  );
  String? _errorText;

  @override
  void dispose() {
    _monthsController.dispose();
    super.dispose();
  }

  void _submit() {
    final months = int.tryParse(_monthsController.text.trim());
    if (months == null || months < 1 || months > StorageMonthConversion.maximumMonths) {
      setState(
        () => _errorText = StorageRemindersLocalizations.of(
          context,
        ).storageMonthsInvalid(StorageMonthConversion.maximumMonths),
      );
      return;
    }
    Navigator.of(context).pop(months);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = StorageRemindersLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _monthsController,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: localizations.storageMonthsLabel,
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.commonLocalizations.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.commonLocalizations.actionSave)),
      ],
    );
  }
}
