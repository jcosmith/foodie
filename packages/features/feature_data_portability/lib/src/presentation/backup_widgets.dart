import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/csv_export_use_case.dart';
import '../application/data_portability_providers.dart';
import '../l10n/generated/data_portability_localizations.dart';
import 'backup_flows.dart';

/// The "Backup and export" section of the Config tab.
class BackupConfigSection extends ConsumerWidget {
  const BackupConfigSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = DataPortabilityLocalizations.of(context);
    final lastBackupAt = ref.watch(lastBackupAtProvider).value;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          lastBackupAt == null
              ? localizations.noBackupYet
              : localizations.lastBackup(
                  context.dateDisplayFormatter.formatMediumDate(
                    CalendarDate.fromDateTime(lastBackupAt.toLocal()),
                  ),
                ),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: FoodieSpacing.extraSmall),
        Text(localizations.backupExplanation, style: textTheme.bodySmall),
        const SizedBox(height: FoodieSpacing.medium),
        FilledButton.icon(
          onPressed: () => showCreateBackupFlow(context, ref),
          icon: const Icon(Icons.save_alt_outlined),
          label: Text(localizations.saveBackupButton),
        ),
        const SizedBox(height: FoodieSpacing.small),
        OutlinedButton.icon(
          onPressed: () => showRestoreBackupFlow(context, ref),
          icon: const Icon(Icons.restore_outlined),
          label: Text(localizations.restoreBackupButton),
        ),
        const SizedBox(height: FoodieSpacing.small),
        Wrap(
          children: [
            TextButton(
              onPressed: () => showCsvExportFlow(context, ref, CsvExportKind.stockContents),
              child: Text(localizations.exportContentsButton),
            ),
            TextButton(
              onPressed: () => showCsvExportFlow(context, ref, CsvExportKind.history),
              child: Text(localizations.exportHistoryButton),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shown on Home while [isBackupDueProvider] is true: something is stored
/// but there is no recent backup.
class BackupReminderCard extends ConsumerWidget {
  const BackupReminderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = DataPortabilityLocalizations.of(context);
    return SectionCard(
      title: localizations.reminderCardTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.reminderCardMessage),
          const SizedBox(height: FoodieSpacing.small),
          FilledButton.tonal(
            onPressed: () => showCreateBackupFlow(context, ref),
            child: Text(localizations.saveBackupButton),
          ),
        ],
      ),
    );
  }
}

/// The backup section on its own screen, opened by the backup reminder.
class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(DataPortabilityLocalizations.of(context).configSectionTitle)),
    body: const SingleChildScrollView(
      padding: EdgeInsets.all(FoodieSpacing.screenGutter),
      child: BackupConfigSection(),
    ),
  );
}
