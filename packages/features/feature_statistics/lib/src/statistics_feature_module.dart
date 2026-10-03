import 'package:core_database/core_database.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'application/statistics_providers.dart';
import 'data/drift_statistics_repository.dart';
import 'l10n/generated/statistics_localizations.dart';
import 'presentation/insight_details_screen.dart';
import 'presentation/insights_screen.dart';
import 'presentation/statistics_routes.dart';

/// Statistics (build order phase 5): the Insights tab. Read-only; it never
/// writes and never listens to events, it queries the movement log live
/// (architecture document, section 8.3).
final class StatisticsFeatureModule extends FeatureModuleBase {
  const StatisticsFeatureModule();

  static const String identifier = 'statistics';

  @override
  String get moduleIdentifier => identifier;

  @override
  List<LocalizationsDelegate<Object>> get localizationDelegates => const [
    StatisticsLocalizations.delegate,
  ];

  @override
  List<Override> buildProviderOverrides(ModuleDependencies dependencies) => [
    statisticsRepositoryProvider.overrideWith(
      (ref) => DriftStatisticsRepository(ref.watch(applicationDatabaseProvider).statisticsDao),
    ),
  ];

  @override
  NavigationDestinationContribution get navigationDestination => NavigationDestinationContribution(
    sortOrder: 30,
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
    labelBuilder: (context) => StatisticsLocalizations.of(context).navigationLabel,
    initialLocation: StatisticsRoutes.insights,
    routes: [
      GoRoute(
        path: StatisticsRoutes.insights,
        builder: (context, state) => const InsightsScreen(),
        routes: [
          GoRoute(
            path: StatisticsRoutes.details.substring(StatisticsRoutes.insights.length + 1),
            builder: (context, state) => const InsightDetailsScreen(),
          ),
        ],
      ),
    ],
  );
}
