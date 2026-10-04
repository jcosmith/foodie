import 'package:core_design_system/core_design_system.dart';
import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) => buildLocalizedTestApplication(
  featureLocalizationDelegates: const [],
  locale: locale,
  home: Scaffold(
    body: SingleChildScrollView(child: SizedBox(width: 360, child: child)),
  ),
);

String _formatKilograms(double value) => '${value.toStringAsFixed(1)} kg';

const _bucketLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

void main() {
  test('axis maxima are round numbers', () {
    expect(ChartScale.niceMaximum(0), 1);
    expect(ChartScale.niceMaximum(3.2), 5);
    expect(ChartScale.niceMaximum(17), 20);
    expect(ChartScale.niceMaximum(240), 250);
    expect(ChartScale.niceMaximum(800), 1000);
    expect(ChartScale.labelStep(30), 6);
    expect(ChartScale.labelStep(4), 1);
  });

  testWidgets('a chart card switches between the chart and its table', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ChartCard(
          title: 'Eaten vs added',
          chart: TrendLineChart(
            bucketLabels: _bucketLabels,
            series: const [
              ChartSeries(label: 'Eaten', color: Colors.blue, values: [1, 2, 3, 2, 1, 0, 4]),
            ],
            formatValue: _formatKilograms,
            formatAxisValue: (value) => value.toStringAsFixed(0),
          ),
          table: const ChartTable(
            columnHeaders: ['', 'Eaten'],
            rows: [
              ['Mon', '1.0 kg'],
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TrendLineChart), findsOneWidget);
    expect(find.text('1.0 kg'), findsNothing);

    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();
    expect(find.byType(TrendLineChart), findsNothing);
    expect(find.text('1.0 kg'), findsOneWidget);

    await tester.tap(find.text('Chart'));
    await tester.pumpAndSettle();
    expect(find.byType(TrendLineChart), findsOneWidget);
  });

  testWidgets('a chart card explains missing data instead of drawing it', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ChartCard(
          title: 'Category share',
          emptyMessage: 'Nothing matches these filters.',
          chart: SizedBox(),
          table: ChartTable(columnHeaders: [], rows: []),
        ),
        locale: const Locale('de'),
      ),
    );
    expect(find.text('Nothing matches these filters.'), findsOneWidget);
    expect(find.text('Tabelle'), findsNothing);
  });

  testWidgets('dragging across a trend chart selects a range of buckets', (tester) async {
    ChartIndexRange? selectedRange;
    await tester.pumpWidget(
      _wrap(
        TrendLineChart(
          bucketLabels: _bucketLabels,
          series: const [
            ChartSeries(label: 'Eaten', color: Colors.blue, values: [1, 2, 3, 2, 1, 0, 4]),
            ChartSeries(
              label: 'Before',
              color: Colors.grey,
              values: [2, 2, 2, 2, 2, 2, 2],
              isComparison: true,
            ),
          ],
          formatValue: _formatKilograms,
          formatAxisValue: (value) => value.toStringAsFixed(0),
          onRangeSelected: (range) => selectedRange = range,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chartBox = tester.getRect(find.byType(TrendLineChart));
    // The plot starts after the 34 pixel axis labels on the left.
    final plotLeft = chartBox.left + 34;
    final bucketWidth = (chartBox.right - plotLeft) / 6;
    final start = Offset(plotLeft + bucketWidth * 1, chartBox.top + 80);
    final gesture = await tester.startGesture(start);
    for (var step = 1; step <= 6; step++) {
      await gesture.moveTo(start + Offset(bucketWidth * 3 * step / 6, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(selectedRange, const ChartIndexRange(1, 4));
  });

  testWidgets('tapping legend entries and donut rows reports the series', (tester) async {
    final tappedLegendEntries = <int>[];
    final tappedSlices = <int>[];
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            StackedBarChart(
              bucketLabels: _bucketLabels.sublist(0, 3),
              series: const [
                ChartSeries(label: 'Vegetables', color: Colors.blue, values: [1, 2, 3]),
                ChartSeries(label: 'Meals', color: Colors.green, values: [3, 0, 1]),
              ],
              formatValue: _formatKilograms,
              formatAxisValue: (value) => value.toStringAsFixed(0),
              onLegendEntryTapped: tappedLegendEntries.add,
            ),
            DonutChart(
              slices: const [
                ChartSlice(label: 'Fruit', value: 3, color: Colors.orange),
                ChartSlice(label: 'Bakery', value: 1, color: Colors.pink),
              ],
              centerLabel: 'Total',
              formatValue: _formatKilograms,
              formatShare: (share) => '${(share * 100).round()} %',
              onSliceTapped: tappedSlices.add,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meals'));
    await tester.tap(find.text('Bakery'));
    expect(tappedLegendEntries, [1]);
    expect(tappedSlices, [1]);
    expect(find.text('75 %'), findsOneWidget);
    expect(find.text('4.0 kg'), findsOneWidget);
  });

  testWidgets('ranking rows scale to the largest value and report taps', (tester) async {
    final tappedRows = <int>[];
    await tester.pumpWidget(
      _wrap(
        RankingBarList(
          rows: const [
            RankingBarRow(label: 'Peas', leading: '🫛', value: 4, formattedValue: '4 kg'),
            RankingBarRow(label: 'Pizza', value: 1, formattedValue: '1 kg', isSelected: true),
          ],
          onRowTapped: tappedRows.add,
        ),
      ),
    );
    await tester.tap(find.text('Pizza'));
    expect(tappedRows, [1]);
    expect(find.text('🫛 Peas'), findsOneWidget);
  });

  testWidgets('KPI tiles read as one sentence and render in the dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FoodieTheme.dark(),
        home: const Scaffold(
          body: SizedBox(
            width: 180,
            child: KpiTile(
              label: 'Eaten',
              value: '12 kg',
              deltaText: '▲ 8 % vs before',
              chart: Sparkline(values: [1, 3, 2, 5]),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Eaten: 12 kg, ▲ 8 % vs before'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(KpiTile))).extension<FoodieChartColors>(),
      FoodieChartColors.dark,
    );
  });

  testWidgets('tapping a calendar cell reports its day', (tester) async {
    CalendarDate? tappedDay;
    final firstDay = CalendarDate(2026, 9, 7); // A Monday.
    await tester.pumpWidget(
      _wrap(
        CalendarHeatmap(
          firstDay: firstDay,
          lastDay: CalendarDate(2026, 10, 2),
          countsByDay: {CalendarDate(2026, 9, 9): 3, CalendarDate(2026, 10, 1): 1},
          weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
          formatMonth: (day) => 'M${day.month}',
          onDayTapped: (day) => tappedDay = day,
        ),
      ),
    );
    final origin = tester.getTopLeft(find.byType(CustomPaint).first);
    // Four weeks fill 360 - 18 pixels, so cells are 16 pixels plus a 2 pixel gap.
    await tester.tapAt(origin + const Offset(18 + 18 * 0 + 8, 14 + 18 * 2 + 8));
    expect(tappedDay, CalendarDate(2026, 9, 9));
    await tester.tapAt(origin + const Offset(18 + 18 * 3 + 8, 14 + 18 * 4 + 8));
    expect(tappedDay, CalendarDate(2026, 10, 2));
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('column bars and freezer drawers are labelled tap targets', (tester) async {
    final tappedColumns = <int>[];
    final tappedDrawers = <int>[];
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            ColumnBarChart(
              labels: const ['Mon', 'Tue', 'Wed'],
              values: const [2, 0, 5],
              formatValue: (value) => value.toStringAsFixed(0),
              selectedIndexes: const {2},
              marker: const ColumnBarMarker(position: 2, label: '6 mo'),
              onColumnTapped: tappedColumns.add,
            ),
            StorageMap(
              drawers: const [
                StorageMapCompartment(
                  label: 'Drawer 1',
                  tagColor: Colors.blue,
                  itemCountLabel: '3 items',
                  itemAgeLevels: [
                    StorageAgeLevel.urgent,
                    StorageAgeLevel.fresh,
                    StorageAgeLevel.fresh,
                  ],
                ),
              ],
              onDrawerTapped: tappedDrawers.add,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Wed: 5'));
    await tester.tap(find.bySemanticsLabel('Drawer 1, 3 items, Fresh: 2, Eat now: 1'));
    expect(tappedColumns, [2]);
    expect(tappedDrawers, [0]);
    expect(find.text('▲ 6 mo'), findsOneWidget);
  });
}
