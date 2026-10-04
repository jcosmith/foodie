import 'package:core_design_system/core_design_system.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/statistics_providers.dart';
import '../domain/statistics_analysis.dart';
import '../domain/statistics_filter.dart';
import 'statistics_formatting.dart';

/// "Freezer days": a calendar of the chosen activity over the period's last
/// 26 weeks. Tapping a day shows its number below the calendar.
class ActivityCalendarChartCard extends StatefulWidget {
  const ActivityCalendarChartCard({required this.analysis, super.key});

  final StatisticsAnalysis analysis;

  @override
  State<ActivityCalendarChartCard> createState() => _ActivityCalendarChartCardState();
}

class _ActivityCalendarChartCardState extends State<ActivityCalendarChartCard> {
  CalendarDate? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final calendar = widget.analysis.calendarPeriod;
    final countsByDay = widget.analysis.dailyItemCounts;
    final selectedDay = _selectedDay != null && calendar.contains(_selectedDay!)
        ? _selectedDay
        : null;
    final sortedDays = countsByDay.keys.toList()..sort();
    return ChartCard(
      title: localizations.calendarTitle,
      subtitle: localizations.calendarSubtitle(
        formatting.activityItemsName(widget.analysis.filter.activity),
      ),
      emptyMessage: countsByDay.isEmpty ? localizations.noData : null,
      chart: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalendarHeatmap(
            firstDay: calendar.firstDay,
            lastDay: calendar.lastDay,
            countsByDay: countsByDay,
            weekdayLabels: [
              for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
                formatting.weekdayNarrow(weekday),
            ],
            formatMonth: formatting.month,
            selectedDay: selectedDay,
            onDayTapped: (day) => setState(() => _selectedDay = day == _selectedDay ? null : day),
          ),
          if (selectedDay != null)
            Padding(
              padding: const EdgeInsets.only(top: FoodieSpacing.small),
              child: Text(
                localizations.calendarSelectedDay(
                  formatting.date(selectedDay),
                  countsByDay[selectedDay] ?? 0,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
      table: ChartTable(
        columnHeaders: const ['', '#'],
        rows: [
          for (final day in sortedDays) [formatting.date(day), '${countsByDay[day]}'],
        ],
      ),
    );
  }
}

/// "By weekday": the chosen activity per weekday; tapping one filters it.
class WeekdayPatternChartCard extends ConsumerWidget {
  const WeekdayPatternChartCard({required this.analysis, super.key});

  final StatisticsAnalysis analysis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final filter = analysis.filter;
    final totals = analysis.weekdayTotals;
    String format(double value) => formatting.measureValue(value, filter.measure);
    final weekdayLabels = [
      for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
        formatting.weekdayShort(weekday),
    ];
    return ChartCard(
      title: localizations.weekdayTitle,
      subtitle:
          '${formatting.activityName(filter.activity)} · ${formatting.measureName(filter.measure)}',
      emptyMessage: totals.every((total) => total == 0) ? localizations.noData : null,
      chart: ColumnBarChart(
        labels: weekdayLabels,
        values: totals,
        formatValue: format,
        selectedIndexes: {for (final weekday in filter.weekdays) weekday - 1},
        onColumnTapped: (index) => ref
            .read(statisticsFilterProvider.notifier)
            .change((current) => current.withWeekdayToggled(index + 1)),
      ),
      table: ChartTable(
        columnHeaders: ['', localizations.total],
        rows: [
          for (final (index, label) in weekdayLabels.indexed) [label, format(totals[index])],
        ],
      ),
    );
  }
}

/// "Time in freezer before eaten": eaten items by storage time, with a
/// marker at six months.
class StorageDurationChartCard extends StatelessWidget {
  const StorageDurationChartCard({required this.analysis, super.key});

  final StatisticsAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    final counts = analysis.eatenItemsByStorageDuration;
    final labels = formatting.storageDurationLabels;
    // Columns from six months on are drawn lighter, past the marker.
    final sixMonthColumn = StatisticsAnalysis.storageDurationLimitsInDays.indexOf(182) + 1;
    return ChartCard(
      title: localizations.durationTitle,
      subtitle: localizations.durationSubtitle,
      emptyMessage: counts.every((count) => count == 0) ? localizations.noData : null,
      chart: ColumnBarChart(
        labels: labels,
        values: [for (final count in counts) count.toDouble()],
        formatValue: (value) => '${value.round()}',
        fadedIndexes: {for (var index = sixMonthColumn; index < counts.length; index++) index},
        marker: ColumnBarMarker(
          position: sixMonthColumn.toDouble(),
          label: localizations.sixMonthMarker,
        ),
      ),
      table: ChartTable(
        columnHeaders: const ['', '#'],
        rows: [
          for (final (index, label) in labels.indexed) [label, '${counts[index]}'],
        ],
      ),
    );
  }
}

/// "Freezer map": what is in each drawer now, coloured by age; tapping a
/// drawer filters it. Follows the category and product filters, not the period.
class StorageMapChartCard extends ConsumerWidget {
  const StorageMapChartCard({required this.filter, super.key});

  final StatisticsFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(inventoryOverviewProvider).value;
    final formatting = StatisticsFormatting.of(context);
    final localizations = formatting.localizations;
    if (overview == null) return const SizedBox.shrink();
    final compartmentNames = context.compartmentDisplayNameResolver(overview.layout);
    final compartments = overview.layout.activeCompartments;
    final itemsByCompartment = {
      for (final compartment in compartments)
        compartment.identifier: [
          for (final item in overview.items)
            if (item.batch.compartmentIdentifier == compartment.identifier &&
                (filter.categoryIdentifiers.isEmpty ||
                    filter.categoryIdentifiers.contains(item.product.categoryIdentifier)) &&
                (filter.productIdentifiers.isEmpty ||
                    filter.productIdentifiers.contains(item.product.identifier)))
              item,
        ],
    };
    return ChartCard(
      title: localizations.storageMapTitle,
      subtitle: localizations.storageMapSubtitle,
      emptyMessage: compartments.isEmpty ? localizations.noData : null,
      chart: StorageMap(
        drawers: [
          for (final compartment in compartments)
            StorageMapCompartment(
              label: compartmentNames.compartmentNameWithStoragePlace(compartment),
              tagColor: CompartmentColorPalette.colorAt(compartment.colorTagIndex),
              itemCountLabel: localizations.drawerItems(
                itemsByCompartment[compartment.identifier]!.length,
              ),
              itemAgeLevels: [
                for (final item in itemsByCompartment[compartment.identifier]!)
                  StorageAgeLevel.values.byName(item.storageAgeStatus.name),
              ],
              isSelected: filter.compartmentIdentifiers.contains(compartment.identifier),
            ),
        ],
        onDrawerTapped: (index) => ref
            .read(statisticsFilterProvider.notifier)
            .change((current) => current.withCompartmentToggled(compartments[index].identifier)),
      ),
      table: ChartTable(
        columnHeaders: const ['', '#'],
        rows: [
          for (final compartment in compartments)
            [
              compartmentNames.compartmentNameWithStoragePlace(compartment),
              '${itemsByCompartment[compartment.identifier]!.length}',
            ],
        ],
      ),
    );
  }
}
