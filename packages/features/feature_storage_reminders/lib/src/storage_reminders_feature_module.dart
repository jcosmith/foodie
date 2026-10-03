import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'application/storage_reminders_providers.dart';
import 'l10n/generated/storage_reminders_localizations.dart';
import 'presentation/eat_soon_widgets.dart';
import 'presentation/reminders_config_section.dart';
import 'presentation/storage_limits_screen.dart';
import 'storage_reminders_routes.dart';

/// Storage age reminders (build order phase 3): the "Eat soon" card and
/// screen, the rolling daily digest (decision D9) and the Reminders section
/// in Config. The age badges themselves belong to the inventory.
final class StorageRemindersFeatureModule extends FeatureModuleBase {
  const StorageRemindersFeatureModule();

  static const String identifier = 'storage_reminders';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    StorageRemindersLocalizations.delegate,
  ];

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(
      path: StorageRemindersRoutes.eatSoon,
      builder: (context, state) => const EatSoonScreen(),
    ),
    GoRoute(
      path: StorageRemindersRoutes.storageLimits,
      builder: (context, state) => const StorageLimitsScreen(),
    ),
  ];

  @override
  List<DashboardCardContribution> get dashboardCards => [
    DashboardCardContribution(
      identifier: '$identifier.eat_soon',
      sortOrder: 10,
      builder: (context) => const EatSoonCard(),
    ),
  ];

  @override
  List<ConfigSectionContribution> get configSections => [
    ConfigSectionContribution(
      identifier: '$identifier.reminders',
      sortOrder: 40,
      titleBuilder: (context) => StorageRemindersLocalizations.of(context).configSectionTitle,
      builder: (context) => const RemindersConfigSection(),
    ),
  ];

  /// Plans the digest at every start and replans after every change.
  @override
  Future<void> initializeModule(ModuleInitializationContext context) =>
      context.read(storageReminderReplanningCoordinatorProvider).start();
}
