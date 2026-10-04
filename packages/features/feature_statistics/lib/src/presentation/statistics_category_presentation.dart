import 'package:core_design_system/core_design_system.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/widgets.dart';

import '../domain/statistics_category_grouping.dart';
import '../l10n/generated/statistics_localizations.dart';

/// Names and colours of category groups, the same on every chart.
final class StatisticsCategoryPresentation {
  StatisticsCategoryPresentation.of(BuildContext context, {required this.catalog})
    : _chartColors = context.chartColors,
      _nameResolver = context.productDisplayNameResolver,
      _otherLabel = StatisticsLocalizations.of(context).otherCategories;

  final ProductCatalog catalog;
  final FoodieChartColors _chartColors;
  final ProductDisplayNameResolver _nameResolver;
  final String _otherLabel;

  Color colorOf(StatisticsCategoryGroup group) => _chartColors.seriesColorAt(group.paletteIndex);

  String labelOf(StatisticsCategoryGroup group) {
    if (group.isOther) return _otherLabel;
    final category = catalog.categoryOf(group.categoryIdentifiers.single);
    return category == null ? _otherLabel : _nameResolver.categoryName(category);
  }
}
