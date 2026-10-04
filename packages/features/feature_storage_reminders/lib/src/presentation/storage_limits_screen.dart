import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/storage_reminders_localizations.dart';

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
                  padding: const EdgeInsets.all(FoodieSpacing.screenGutter),
                  child: Text(
                    localizations.storageLimitsExplanation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                for (final category in catalog.categories)
                  ListTile(
                    leading: ProductIcon(emoji: category.iconEmoji, size: 28),
                    title: Text(nameResolver.categoryName(category)),
                    trailing: Text(switch (category.recommendedMaximumStorageDays) {
                      final int days => context.shelfLifeFormatter.formatDays(days),
                      null => context.commonLocalizations.shelfLifeNone,
                    }),
                    onTap: () => _editStorageLimit(context, ref, category),
                  ),
              ],
            ),
    );
  }

  Future<void> _editStorageLimit(BuildContext context, WidgetRef ref, Category category) async {
    final chosenDays = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _ShelfLifeDialog(
        title: context.productDisplayNameResolver.categoryName(category),
        initialDays: category.recommendedMaximumStorageDays,
      ),
    );
    if (chosenDays == null) return;
    await ref
        .read(changeCategoryStorageLimitUseCaseProvider)
        .execute(
          categoryIdentifier: category.identifier,
          recommendedMaximumStorageDays: chosenDays,
        );
  }
}

class _ShelfLifeDialog extends StatefulWidget {
  const _ShelfLifeDialog({required this.title, required this.initialDays});

  final String title;

  /// `null` for a category without a shelf life, which gets one here.
  final int? initialDays;

  @override
  State<_ShelfLifeDialog> createState() => _ShelfLifeDialogState();
}

class _ShelfLifeDialogState extends State<_ShelfLifeDialog> {
  late final ShelfLifeFieldController _controller = ShelfLifeFieldController(
    initialDays: widget.initialDays,
  );
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final days = _controller.inDays;
    if (days == null || !_controller.isValid) {
      setState(() => _errorText = context.commonLocalizations.shelfLifeOutOfRange);
      return;
    }
    Navigator.of(context).pop(days);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: ShelfLifeField(
      controller: _controller,
      labelText: StorageRemindersLocalizations.of(context).shelfLifeLabel,
      errorText: _errorText,
      autofocus: true,
      onSubmitted: _submit,
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
