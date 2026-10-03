/// Public API of the statistics feature: the Insights tab and its shared filter.
library;

export 'domain.dart';
export 'src/application/statistics_providers.dart'
    show statisticsAnalysisProvider, statisticsFilterProvider;
export 'src/l10n/generated/statistics_localizations.dart';
export 'src/presentation/statistics_routes.dart';
export 'src/statistics_feature_module.dart';
