import 'package:core_design_system/core_design_system.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_providers.dart';
import '../domain/statistics_filter.dart';
import 'statistics_filter_sheet.dart';
import 'statistics_formatting.dart';

/// The filter row pinned above the charts (UI examples document, phone 7):
/// period presets and the "Filters" button, then a removable chip for every
/// active choice and "Reset".
class StatisticsFilterBar extends ConsumerWidget {
  const StatisticsFilterBar({super.key});

  static const List<StatisticsPeriodPreset> _presetsInRow = [
    StatisticsPeriodPreset.last30Days,
    StatisticsPeriodPreset.last3Months,
    StatisticsPeriodPreset.last12Months,
    StatisticsPeriodPreset.thisYear,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(statisticsFilterProvider);
    final filterNotifier = ref.read(statisticsFilterProvider.notifier);
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final catalog = ref.watch(productCatalogProvider).value;
    final layout = ref.watch(storageLayoutProvider).value;
    final categoryGrouping = ref.watch(statisticsCategoryGroupingProvider).value;
    final chartColors = context.chartColors;
    final productNames = context.productDisplayNameResolver;
    final compartmentNames = layout == null ? null : context.compartmentDisplayNameResolver(layout);

    final registeredDomains = ref.watch(registeredStorageDomainsProvider);
    final activeChips = <Widget>[
      for (final domain in registeredDomains)
        if (filter.domainIdentifiers.contains(domain.identifier))
          _RemovableChip(
            label: '${domain.iconEmoji} ${domain.labelBuilder(context)}',
            onDeleted: () =>
                filterNotifier.change((current) => current.withDomainToggled(domain.identifier)),
          ),
      if (catalog != null)
        for (final categoryIdentifier in filter.categoryIdentifiers)
          if (catalog.categoryOf(categoryIdentifier) case final category?)
            _RemovableChip(
              label: productNames.categoryName(category),
              avatar: ChartColorSwatch(
                color: chartColors.seriesColorAt(
                  categoryGrouping?.paletteIndexOf(categoryIdentifier),
                ),
              ),
              onDeleted: () => filterNotifier.change(
                (current) => current.withCategoryToggled(categoryIdentifier),
              ),
            ),
      if (compartmentNames != null)
        for (final compartmentIdentifier in filter.compartmentIdentifiers)
          _RemovableChip(
            label: compartmentNames.compartmentNameOf(compartmentIdentifier),
            onDeleted: () => filterNotifier.change(
              (current) => current.withCompartmentToggled(compartmentIdentifier),
            ),
          ),
      if (catalog != null)
        for (final productIdentifier in filter.productIdentifiers)
          if (catalog.productOf(productIdentifier) case final product?)
            _RemovableChip(
              label: '${catalog.iconEmojiOf(product)} ${productNames.productName(product)}',
              onDeleted: () =>
                  filterNotifier.change((current) => current.withProductToggled(productIdentifier)),
            ),
      for (final weekday in [...filter.weekdays]..sort())
        _RemovableChip(
          label: formatting.weekdayShort(weekday),
          onDeleted: () => filterNotifier.change((current) => current.withWeekdayToggled(weekday)),
        ),
      if (filter.activity != StatisticsFilter.initial.activity)
        _RemovableChip(
          label: formatting.activityName(filter.activity),
          onDeleted: () => filterNotifier.change(
            (current) => current.withActivity(StatisticsFilter.initial.activity),
          ),
        ),
      if (filter.measure != StatisticsFilter.initial.measure)
        _RemovableChip(
          label: formatting.measureName(filter.measure),
          onDeleted: () => filterNotifier.change(
            (current) => current.withMeasure(StatisticsFilter.initial.measure),
          ),
        ),
      if (filter.comparison != StatisticsFilter.initial.comparison)
        _RemovableChip(
          label: '${localizations.filterCompare}: ${formatting.comparisonName(filter.comparison)}',
          onDeleted: () => filterNotifier.change(
            (current) => current.withComparison(StatisticsFilter.initial.comparison),
          ),
        ),
      if (filter.granularity != StatisticsFilter.initial.granularity)
        _RemovableChip(
          label:
              '${localizations.filterGranularity}: '
              '${formatting.granularityName(filter.granularity)}',
          onDeleted: () => filterNotifier.change(
            (current) => current.withGranularity(StatisticsFilter.initial.granularity),
          ),
        ),
    ];

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(bottom: FoodieSpacing.extraSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The presets scroll; the "Filters" button always stays in reach.
            Row(
              children: [
                Expanded(
                  child: _ChipRow(
                    children: [
                      for (final preset in [
                        ..._presetsInRow,
                        if (filter.periodPreset == StatisticsPeriodPreset.allTime)
                          StatisticsPeriodPreset.allTime,
                      ])
                        ChoiceChip(
                          label: Text(formatting.periodPresetName(preset)),
                          selected: filter.periodPreset == preset,
                          onSelected: (_) =>
                              filterNotifier.change((current) => current.withPeriodPreset(preset)),
                        ),
                      if (filter.periodPreset == StatisticsPeriodPreset.custom)
                        InputChip(
                          label: Text(localizations.periodCustom),
                          selected: true,
                          onDeleted: () => filterNotifier.change(
                            (current) =>
                                current.withPeriodPreset(StatisticsFilter.initial.periodPreset),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: FoodieSpacing.screenGutter),
                  child: ActionChip(
                    avatar: const Icon(Icons.tune, size: 18),
                    label: Text(localizations.filtersButton(filter.activeFilterCount)),
                    onPressed: () => showStatisticsFilterSheet(context),
                  ),
                ),
              ],
            ),
            if (activeChips.isNotEmpty)
              _ChipRow(
                children: [
                  ...activeChips,
                  ActionChip(
                    label: Text(localizations.resetFilters),
                    onPressed: filterNotifier.reset,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(
      horizontal: FoodieSpacing.screenGutter,
      vertical: FoodieSpacing.extraSmall,
    ),
    child: Row(
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(width: FoodieSpacing.small),
          child,
        ],
      ],
    ),
  );
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onDeleted, this.avatar});

  final String label;
  final Widget? avatar;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) =>
      InputChip(avatar: avatar, label: Text(label), onDeleted: onDeleted, onPressed: onDeleted);
}
