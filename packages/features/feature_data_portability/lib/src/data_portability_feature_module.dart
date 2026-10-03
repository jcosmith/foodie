import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'application/data_portability_providers.dart';
import 'data/system_dialog_backup_file_store.dart';
import 'data_portability_routes.dart';
import 'l10n/generated/data_portability_localizations.dart';
import 'presentation/backup_widgets.dart';

/// Encrypted backup and restore, CSV export and the backup reminder
/// (architecture document, section 11). Part of the first release, because
/// losing the phone otherwise loses the data.
final class DataPortabilityFeatureModule extends FeatureModuleBase {
  const DataPortabilityFeatureModule();

  static const String identifier = 'data_portability';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    DataPortabilityLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    backupFileStoreProvider.overrideWithValue(const SystemDialogBackupFileStore()),
  ];

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(path: DataPortabilityRoutes.backup, builder: (context, state) => const BackupScreen()),
  ];

  @override
  List<ConfigSectionContribution> get configSections => [
    ConfigSectionContribution(
      identifier: '$identifier.backup',
      sortOrder: 70,
      titleBuilder: (context) => DataPortabilityLocalizations.of(context).configSectionTitle,
      builder: (context) => const BackupConfigSection(),
    ),
  ];

  @override
  List<DashboardCardContribution> get dashboardCards => [
    DashboardCardContribution(
      identifier: '$identifier.backup_reminder',
      sortOrder: 90,
      builder: (context) => const BackupReminderCard(),
      isVisible: isBackupDueProvider,
    ),
  ];

  /// Plans the backup reminder notification at every start.
  @override
  Future<void> initializeModule(ModuleInitializationContext context) =>
      context.read(backupReminderReplanningCoordinatorProvider).start();
}
