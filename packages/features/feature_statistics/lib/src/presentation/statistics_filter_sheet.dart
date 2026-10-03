import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_foundation/foundation_providers.dart';
import 'package:core_localization/core_localization.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_providers.dart';
import '../domain/saved_statistics_views.dart';
import '../domain/statistics_date_range.dart';
import '../domain/statistics_filter.dart';
import 'statistics_formatting.dart';

/// Opens every filter dimension in one sheet (UI examples document, phone 8).
/// Changes apply live to the charts behind it.
Future<void> showStatisticsFilterSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.85,
    maxChildSize: 0.95,
    builder: (context, scrollController) =>
        StatisticsFilterSheet(scrollController: scrollController),
  ),
);

class StatisticsFilterSheet extends ConsumerStatefulWidget {
  const StatisticsFilterSheet({this.scrollController, super.key});

  final ScrollController? scrollController;

  @override
  ConsumerState<StatisticsFilterSheet> createState() => _StatisticsFilterSheetState();
}

class _StatisticsFilterSheetState extends ConsumerState<StatisticsFilterSheet> {
  String _productSearchText = '';

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(statisticsFilterProvider);
    final filterNotifier = ref.read(statisticsFilterProvider.notifier);
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final catalog = ref.watch(productCatalogProvider).value;
    final layout = ref.watch(storageLayoutProvider).value;
    final categoryGrouping = ref.watch(statisticsCategoryGroupingProvider).value;
    final periods = ref.watch(statisticsPeriodsProvider).value;
    final savedViews = ref.watch(savedStatisticsViewsProvider).value ?? const [];
    final analysis = ref.watch(statisticsAnalysisProvider).value;
    final chartColors = context.chartColors;
    final productNames = context.productDisplayNameResolver;
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(color: context.freezerColors.textMuted);

    void change(StatisticsFilter Function(StatisticsFilter current) change) =>
        filterNotifier.change(change);

    final productsLeftOut = analysis?.productsLeftOutByMeasure ?? 0;
    final measureHint = filter.measure == StatisticsMeasure.count
        ? localizations.measureAllHint
        : productsLeftOut > 0
        ? localizations.measureHiddenHint(productsLeftOut)
        : null;

    final searchText = _productSearchText.trim().toLowerCase();
    final listedProducts = catalog == null
        ? const <Product>[]
        : ([
            for (final product in catalog.activeProducts)
              if (searchText.isEmpty ||
                  productNames.productName(product).toLowerCase().contains(searchText))
                product,
            // Archived products stay removable once selected.
            for (final productIdentifier in filter.productIdentifiers)
              if (catalog.productOf(productIdentifier) case final product? when product.isArchived)
                product,
          ]..sort(
            (first, second) =>
                productNames.productName(first).compareTo(productNames.productName(second)),
          ));

    final compartmentNames = layout == null ? null : context.compartmentDisplayNameResolver(layout);
    final listedCompartments = layout == null
        ? const <Compartment>[]
        : [
            for (final freezerLayout in layout.freezers) ...[
              ...freezerLayout.compartments,
              // Removed drawers still have history (decision D13).
              ...layout.archivedCompartmentsOf(freezerLayout.freezer.identifier),
            ],
          ];

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(
        FreezerSpacing.large,
        0,
        FreezerSpacing.large,
        FreezerSpacing.extraLarge,
      ),
      children: [
        Text(
          localizations.filtersTitle,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(localizations.filtersSubtitle, style: mutedStyle),
        _FilterSection(
          title: localizations.filterSavedViews,
          choices: [
            if (catalog != null)
              for (final suggestedView in SuggestedStatisticsView.values)
                ActionChip(
                  avatar: const Text('★'),
                  label: Text(formatting.suggestedViewName(suggestedView)),
                  onPressed: () =>
                      filterNotifier.apply(suggestedView.filterFor(catalog.categories)),
                ),
            for (final savedView in savedViews)
              InputChip(
                label: Text(savedView.name),
                selected: savedView.filter == filter,
                onPressed: () => filterNotifier.apply(savedView.filter),
                onDeleted: () => ref.read(savedStatisticsViewStoreProvider).remove(savedView.name),
              ),
          ],
          footer: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: Text(localizations.saveViewButton),
              onPressed: () => _saveCurrentView(filter),
            ),
          ),
        ),
        _FilterSection(
          title: localizations.filterPeriod,
          choices: [
            for (final preset in StatisticsPeriodPreset.values)
              ChoiceChip(
                label: Text(formatting.periodPresetName(preset)),
                selected: filter.periodPreset == preset,
                onSelected: (_) => preset == StatisticsPeriodPreset.custom
                    ? _pickCustomPeriod(periods?.period)
                    : change((current) => current.withPeriodPreset(preset)),
              ),
          ],
          footer: periods == null
              ? null
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(formatting.periodLabel(periods.period)),
                    onPressed: () => _pickCustomPeriod(periods.period),
                  ),
                ),
        ),
        _FilterSection(
          title: localizations.filterCompare,
          choices: [
            for (final comparison in StatisticsComparison.values)
              ChoiceChip(
                label: Text(formatting.comparisonName(comparison)),
                selected: filter.comparison == comparison,
                onSelected: (_) => change((current) => current.withComparison(comparison)),
              ),
          ],
        ),
        _FilterSection(
          title: localizations.filterGranularity,
          choices: [
            for (final granularity in StatisticsGranularity.values)
              ChoiceChip(
                label: Text(formatting.granularityName(granularity)),
                selected: filter.granularity == granularity,
                onSelected: (_) => change((current) => current.withGranularity(granularity)),
              ),
          ],
        ),
        _FilterSection(
          title: localizations.filterMeasure,
          choices: [
            for (final measure in StatisticsMeasure.values)
              ChoiceChip(
                label: Text(formatting.measureName(measure)),
                selected: filter.measure == measure,
                onSelected: (_) => change((current) => current.withMeasure(measure)),
              ),
          ],
          footer: measureHint == null ? null : Text(measureHint, style: mutedStyle),
        ),
        _FilterSection(
          title: localizations.filterActivity,
          choices: [
            for (final activity in StatisticsActivity.values)
              ChoiceChip(
                label: Text(formatting.activityName(activity)),
                selected: filter.activity == activity,
                onSelected: (_) => change((current) => current.withActivity(activity)),
              ),
          ],
        ),
        if (catalog != null)
          _FilterSection(
            title: localizations.filterCategories,
            choices: [
              for (final category in catalog.categories)
                FilterChip(
                  avatar: ChartColorSwatch(
                    color: chartColors.seriesColorAt(
                      categoryGrouping?.paletteIndexOf(category.identifier),
                    ),
                  ),
                  label: Text(productNames.categoryName(category)),
                  selected: filter.categoryIdentifiers.contains(category.identifier),
                  onSelected: (_) =>
                      change((current) => current.withCategoryToggled(category.identifier)),
                ),
            ],
          ),
        if (compartmentNames != null && listedCompartments.isNotEmpty)
          _FilterSection(
            title: localizations.filterDrawers,
            choices: [
              for (final compartment in listedCompartments)
                FilterChip(
                  avatar: ChartColorSwatch(
                    color: CompartmentColorPalette.colorAt(compartment.colorTagIndex),
                  ),
                  label: Text(compartmentNames.compartmentNameWithFreezer(compartment)),
                  selected: filter.compartmentIdentifiers.contains(compartment.identifier),
                  onSelected: (_) =>
                      change((current) => current.withCompartmentToggled(compartment.identifier)),
                ),
            ],
          ),
        _FilterSection(
          title: localizations.filterWeekdays,
          choices: [
            for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
              FilterChip(
                label: Text(formatting.weekdayShort(weekday)),
                selected: filter.weekdays.contains(weekday),
                onSelected: (_) => change((current) => current.withWeekdayToggled(weekday)),
              ),
          ],
        ),
        if (catalog != null)
          _FilterSection(
            title: localizations.filterProducts,
            header: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: localizations.productSearch,
                isDense: true,
              ),
              onChanged: (text) => setState(() => _productSearchText = text),
            ),
            choices: [
              for (final product in listedProducts)
                FilterChip(
                  label: Text(
                    '${catalog.iconEmojiOf(product)} ${productNames.productName(product)}',
                  ),
                  selected: filter.productIdentifiers.contains(product.identifier),
                  onSelected: (_) =>
                      change((current) => current.withProductToggled(product.identifier)),
                ),
            ],
          ),
        const SizedBox(height: FreezerSpacing.large),
        OutlinedButton(onPressed: filterNotifier.reset, child: Text(localizations.resetFilters)),
      ],
    );
  }

  Future<void> _saveCurrentView(StatisticsFilter filter) async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _SaveViewDialog(),
    );
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isEmpty || !mounted) return;
    await ref
        .read(savedStatisticsViewStoreProvider)
        .save(SavedStatisticsView(name: trimmedName, filter: filter));
  }

  Future<void> _pickCustomPeriod(StatisticsDateRange? currentPeriod) async {
    final today = ref.read(clockProvider).todayLocal();
    final firstActivityDay = ref.read(firstActivityDayProvider).value;
    final earliestDay = firstActivityDay ?? today.addDays(-365);
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: earliestDay.toLocalDateTime(),
      lastDate: today.toLocalDateTime(),
      currentDate: today.toLocalDateTime(),
      initialDateRange: currentPeriod == null || currentPeriod.firstDay.isBefore(earliestDay)
          ? null
          : DateTimeRange(
              start: currentPeriod.firstDay.toLocalDateTime(),
              end: currentPeriod.lastDay.toLocalDateTime(),
            ),
    );
    if (pickedRange == null || !mounted) return;
    ref
        .read(statisticsFilterProvider.notifier)
        .change(
          (current) => current.withCustomPeriod(
            StatisticsDateRange(
              CalendarDate.fromDateTime(pickedRange.start),
              CalendarDate.fromDateTime(pickedRange.end),
            ),
          ),
        );
  }
}

/// Asks for the name of a view; the controller lives as long as the dialog,
/// including its closing animation.
class _SaveViewDialog extends StatefulWidget {
  const _SaveViewDialog();

  @override
  State<_SaveViewDialog> createState() => _SaveViewDialogState();
}

class _SaveViewDialogState extends State<_SaveViewDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = StatisticsFormatting.of(context).localizations;
    final commonLocalizations = context.commonLocalizations;
    return AlertDialog(
      title: Text(localizations.saveViewTitle),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: localizations.saveViewNameLabel),
        onSubmitted: (text) => Navigator.of(context).pop(text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(commonLocalizations.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_nameController.text),
          child: Text(commonLocalizations.actionSave),
        ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.choices, this.header, this.footer});

  final String title;
  final Widget? header;
  final List<Widget> choices;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: FreezerSpacing.large),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: FreezerSpacing.small),
        if (header != null) ...[header!, const SizedBox(height: FreezerSpacing.small)],
        Wrap(
          spacing: FreezerSpacing.small,
          runSpacing: FreezerSpacing.extraSmall,
          children: choices,
        ),
        if (footer != null) ...[const SizedBox(height: FreezerSpacing.extraSmall), footer!],
      ],
    ),
  );
}
