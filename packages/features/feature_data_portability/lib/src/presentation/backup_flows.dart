import 'dart:async';

import 'package:core_database/core_database.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/csv_export_use_case.dart';
import '../application/data_portability_providers.dart';
import '../domain/backup_policies.dart';
import '../domain/data_portability_failure.dart';
import '../l10n/generated/data_portability_localizations.dart';

/// Asks for a password, and whether to include photos when there are any,
/// and saves a backup through the system dialog.
Future<void> showCreateBackupFlow(BuildContext context, WidgetRef ref) async {
  final localizations = DataPortabilityLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final createBackup = ref.read(createBackupUseCaseProvider);
  final pictureCount = await createBackup.countPictures();
  if (!context.mounted) return;
  final choice = await showDialog<_NewBackupChoice>(
    context: context,
    builder: (dialogContext) => _NewBackupPasswordDialog(pictureCount: pictureCount),
  );
  if (choice == null || !context.mounted) return;
  final result = await _whileShowingProgress(
    context,
    createBackup.execute(
      password: choice.password,
      repeatedPassword: choice.password,
      includesPictures: choice.includesPictures,
    ),
  );
  switch (result) {
    case SuccessfulResult(value: true):
      messenger.showSnackBar(SnackBar(content: Text(localizations.backupSaved)));
    case SuccessfulResult():
      break;
    case FailedResult(:final failure):
      messenger.showSnackBar(SnackBar(content: Text(localizations.describeFailure(failure))));
  }
}

/// Picks a backup file, checks its password, asks for confirmation and
/// restores it; the app then restarts with the restored data.
Future<void> showRestoreBackupFlow(BuildContext context, WidgetRef ref) async {
  final localizations = DataPortabilityLocalizations.of(context);
  final dateFormatter = context.dateDisplayFormatter;
  final backupPath = await ref.read(backupFileStoreProvider).pickFile();
  if (backupPath == null || !context.mounted) return;
  final restoreBackup = ref.read(restoreBackupUseCaseProvider);

  String? passwordError;
  while (true) {
    if (!context.mounted) return;
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _BackupPasswordDialog(errorText: passwordError),
    );
    if (password == null || !context.mounted) return;
    final inspection = await _whileShowingProgress(
      context,
      restoreBackup.inspect(backupPath: backupPath, password: password),
    );
    if (!context.mounted) return;
    switch (inspection) {
      case FailedResult(failure: BackupNotReadable()):
        passwordError = localizations.backupNotReadable;
        continue;
      case FailedResult(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.describeFailure(failure))));
        return;
      case SuccessfulResult(value: final BackupManifest manifest):
        final backupDate = dateFormatter.formatMediumDate(
          CalendarDate.fromDateTime(manifest.createdAt.toLocal()),
        );
        final confirmationMessage = [
          localizations.confirmRestoreMessage(backupDate),
          // Older backups do not say; they never had pictures.
          if (manifest.formatVersion >= 2)
            localizations.restoreIncludesPictures(manifest.pictureCount),
        ].join(' ');
        final isConfirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(localizations.confirmRestoreTitle),
            content: Text(confirmationMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(dialogContext.commonLocalizations.actionCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(localizations.restoreButton),
              ),
            ],
          ),
        );
        if (isConfirmed != true || !context.mounted) return;
        // On success the app restarts and this screen goes away.
        await _whileShowingProgress(
          context,
          restoreBackup.restore(backupPath: backupPath, password: password),
        );
        return;
    }
  }
}

/// Exports the freezer contents or the history as CSV.
Future<void> showCsvExportFlow(BuildContext context, WidgetRef ref, CsvExportKind kind) async {
  final localizations = DataPortabilityLocalizations.of(context);
  final quantityFormatter = context.quantityFormatter;
  final messenger = ScaffoldMessenger.of(context);
  final texts = CsvExportTexts(
    contentsHeader: [
      localizations.csvColumnProduct,
      localizations.csvColumnCategory,
      localizations.csvColumnAmount,
      localizations.csvColumnUnit,
      localizations.csvColumnStoredOn,
      localizations.csvColumnDrawer,
      localizations.csvColumnNote,
    ],
    historyHeader: [
      localizations.csvColumnTime,
      localizations.csvColumnChange,
      localizations.csvColumnProduct,
      localizations.csvColumnAmount,
      localizations.csvColumnUnit,
      localizations.csvColumnDrawer,
      localizations.csvColumnReason,
    ],
    catalogNames: context.catalogNames,
    layoutDefaultNames: context.layoutDefaultNames,
    movementKindName: (kind) => switch (kind) {
      MovementKind.added => localizations.movementAdded,
      MovementKind.consumed => localizations.movementConsumed,
      MovementKind.discarded => localizations.movementDiscarded,
      MovementKind.moved => localizations.movementMoved,
      MovementKind.corrected => localizations.movementCorrected,
    },
    discardReasonName: (reason) => switch (reason) {
      DiscardReason.tooOld => localizations.reasonTooOld,
      DiscardReason.freezerBurn => localizations.reasonFreezerBurn,
      DiscardReason.expired => localizations.reasonExpired,
      DiscardReason.spoiled => localizations.reasonSpoiled,
      DiscardReason.unwanted => localizations.reasonUnwanted,
      DiscardReason.other => localizations.reasonOther,
    },
    unitSymbol: quantityFormatter.unitSymbol,
  );
  final isSaved = await ref.read(csvExportUseCaseProvider).execute(kind, texts);
  if (isSaved) messenger.showSnackBar(SnackBar(content: Text(localizations.fileSaved)));
}

/// Shows a progress dialog that cannot be dismissed until [work] completes.
///
/// The dialog goes on the root navigator, above the tabs, while the Config
/// tab has a navigator of its own (issue #16). It is removed as the route it
/// is, so the page below it can never be closed instead.
Future<TResult> _whileShowingProgress<TResult>(BuildContext context, Future<TResult> work) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final message = DataPortabilityLocalizations.of(context).workingOnBackup;
  final progressRoute = DialogRoute<void>(
    context: context,
    themes: InheritedTheme.capture(from: context, to: navigator.context),
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: FoodieSpacing.large),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    ),
  );
  unawaited(navigator.push(progressRoute));
  try {
    return await work;
  } finally {
    if (navigator.mounted && progressRoute.isActive) navigator.removeRoute(progressRoute);
  }
}

extension DataPortabilityFailureTexts on DataPortabilityLocalizations {
  String describeFailure(DataPortabilityFailure failure) => switch (failure) {
    BackupPasswordTooShort() => passwordTooShort(BackupPasswordPolicy.minimumLength),
    BackupPasswordsDoNotMatch() => passwordsDoNotMatch,
    BackupNotReadable() => backupNotReadable,
    NotABackupOfThisApp() => notABackupOfThisApp,
    BackupNeedsNewerApp(:final applicationVersion) => backupNeedsNewerApp(applicationVersion),
  };
}

typedef _NewBackupChoice = ({String password, bool includesPictures});

/// A new password, typed twice, and whether photos go in.
class _NewBackupPasswordDialog extends StatefulWidget {
  const _NewBackupPasswordDialog({required this.pictureCount});

  /// The switch to leave photos out only shows when there are any.
  final int pictureCount;

  @override
  State<_NewBackupPasswordDialog> createState() => _NewBackupPasswordDialogState();
}

class _NewBackupPasswordDialogState extends State<_NewBackupPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatedPasswordController = TextEditingController();
  DataPortabilityFailure? _problem;
  bool _includesPictures = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatedPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final problem = BackupPasswordPolicy.check(
      password: _passwordController.text,
      repeatedPassword: _repeatedPasswordController.text,
    );
    if (problem != null) {
      setState(() => _problem = problem);
    } else {
      Navigator.of(
        context,
      ).pop((password: _passwordController.text, includesPictures: _includesPictures));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = DataPortabilityLocalizations.of(context);
    final problem = _problem;
    return AlertDialog(
      title: Text(localizations.passwordDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.passwordDialogMessage(BackupPasswordPolicy.minimumLength)),
            const SizedBox(height: FoodieSpacing.medium),
            TextField(
              controller: _passwordController,
              obscureText: true,
              autofocus: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: localizations.passwordLabel,
                errorText: problem is BackupPasswordTooShort
                    ? localizations.describeFailure(problem)
                    : null,
              ),
            ),
            const SizedBox(height: FoodieSpacing.small),
            TextField(
              controller: _repeatedPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: localizations.repeatPasswordLabel,
                errorText: problem is BackupPasswordsDoNotMatch
                    ? localizations.describeFailure(problem)
                    : null,
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (widget.pictureCount > 0) ...[
              const SizedBox(height: FoodieSpacing.small),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localizations.includePicturesLabel),
                subtitle: Text(localizations.includePicturesHint(widget.pictureCount)),
                value: _includesPictures,
                onChanged: (includesPictures) =>
                    setState(() => _includesPictures = includesPictures),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.commonLocalizations.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(localizations.saveBackupButton)),
      ],
    );
  }
}

/// The password of an existing backup.
class _BackupPasswordDialog extends StatefulWidget {
  const _BackupPasswordDialog({this.errorText});

  final String? errorText;

  @override
  State<_BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<_BackupPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = DataPortabilityLocalizations.of(context);
    return AlertDialog(
      title: Text(localizations.restorePasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localizations.restorePasswordMessage),
          const SizedBox(height: FoodieSpacing.medium),
          TextField(
            controller: _passwordController,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: localizations.passwordLabel,
              errorText: widget.errorText,
              errorMaxLines: 3,
            ),
            onSubmitted: (password) => Navigator.of(context).pop(password),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.commonLocalizations.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_passwordController.text),
          child: Text(localizations.openButton),
        ),
      ],
    );
  }
}
