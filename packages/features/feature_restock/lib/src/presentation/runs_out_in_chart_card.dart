import 'package:core_design_system/core_design_system.dart';
import 'package:core_localization/core_localization.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/restock_providers.dart';
import '../domain/stock_run_out_forecast.dart';
import '../l10n/generated/restock_localizations.dart';

/// The "Runs out in" chart restock contributes to the Insights tab: one bar
/// per product with a minimum quantity, full at a month, urgent below ten
/// days. Tapping a row puts the product on the shopping list.
class RunsOutInChartCard extends ConsumerWidget {
  const RunsOutInChartCard({required this.filter, super.key});

  /// A full bar stands for this many days or more, and for "no recent use".
  static const int fullBarInDays = 30;

  final InsightFilterSnapshot filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = RestockLocalizations.of(context);
    final forecasts = ref.watch(stockRunOutForecastsProvider);
    final catalog = ref.watch(productCatalogProvider).value;
    if (forecasts == null || catalog == null) return const SizedBox.shrink();

    final productNames = context.productDisplayNameResolver;
    final quantityFormatter = context.quantityFormatter;
    final urgentColor = context.foodieColors.statusUrgent;
    final shownForecasts = [
      for (final forecast in forecasts)
        if (catalog.productOf(forecast.productIdentifier) case final product?
            when _matchesFilter(product))
          (forecast: forecast, product: product),
    ];

    String daysText(StockRunOutForecast forecast) => switch (forecast.daysLeft) {
      final daysLeft? => localizations.forecastDays(daysLeft),
      null => localizations.forecastNever,
    };

    return ChartCard(
      title: localizations.forecastTitle,
      subtitle: localizations.forecastSubtitle,
      emptyMessage: shownForecasts.isNotEmpty
          ? null
          : forecasts.isEmpty
          ? localizations.forecastEmpty
          : localizations.forecastNoMatch,
      chart: RankingBarList(
        maximumValue: fullBarInDays.toDouble(),
        rows: [
          for (final (:forecast, :product) in shownForecasts)
            RankingBarRow(
              leading: catalog.iconEmojiOf(product),
              label: productNames.productName(product),
              value: (forecast.daysLeft ?? fullBarInDays).clamp(0, fullBarInDays).toDouble(),
              formattedValue: daysText(forecast),
              barColor: forecast.runsOutSoon ? urgentColor : null,
            ),
        ],
        onRowTapped: (index) => _addToShoppingList(context, ref, shownForecasts[index].product),
      ),
      table: ChartTable(
        columnHeaders: [
          localizations.forecastTableProduct,
          localizations.forecastTableStock,
          localizations.forecastTableDays,
        ],
        rows: [
          for (final (:forecast, :product) in shownForecasts)
            [
              productNames.productName(product),
              quantityFormatter.format(forecast.stock),
              forecast.daysLeft?.toString() ?? '–',
            ],
        ],
      ),
    );
  }

  /// Follows the category and product filters; period and compartments do not
  /// change when the current stock runs out.
  bool _matchesFilter(Product product) =>
      (filter.categoryIdentifiers.isEmpty ||
          filter.categoryIdentifiers.contains(product.categoryIdentifier.value)) &&
      (filter.productIdentifiers.isEmpty ||
          filter.productIdentifiers.contains(product.identifier.value));

  Future<void> _addToShoppingList(BuildContext context, WidgetRef ref, Product product) async {
    final message = RestockLocalizations.of(
      context,
    ).forecastAddedToList(context.productDisplayNameResolver.productName(product));
    final messenger = ScaffoldMessenger.maybeOf(context);
    final result = await ref
        .read(addProductToShoppingListUseCaseProvider)
        .execute(product.identifier);
    if (result.isSuccess) messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}
