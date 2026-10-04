import 'package:core_database/core_database.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'application/storage_layout_providers.dart';
import 'data/drift_storage_layout_repository.dart';
import 'l10n/generated/storage_layout_localizations.dart';
import 'presentation/storage_layout_routes.dart';
import 'presentation/storage_place_list.dart';

/// Storage places and their compartments (decision D13). Contributes the "Storage place
/// layout" section of the Config tab and the layout editor screens.
final class StorageLayoutFeatureModule extends FeatureModuleBase {
  const StorageLayoutFeatureModule();

  static const String identifier = 'storage_layout';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    StorageLayoutLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    storageLayoutRepositoryProvider.overrideWith(
      (ref) => DriftStorageLayoutRepository(ref.watch(storageLayoutDaoProvider)),
    ),
  ];

  @override
  List<RouteBase> buildRoutes() => buildStorageLayoutRoutes();

  @override
  List<ConfigSectionContribution> get configSections => [
    ConfigSectionContribution(
      identifier: '$identifier.freezer_layout',
      sortOrder: 20,
      titleBuilder: (context) => StorageLayoutLocalizations.of(context).configSectionTitle,
      builder: (context) => const StorageLayoutConfigSection(),
    ),
  ];
}
