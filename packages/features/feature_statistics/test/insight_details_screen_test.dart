import 'package:core_design_system/core_design_system.dart';
import 'package:core_design_system/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_statistics/feature_statistics.dart';
import 'package:feature_statistics/src/application/statistics_providers.dart';
import 'package:feature_statistics/src/presentation/insight_details_screen.dart';
import 'package:feature_storage_layout/feature_storage_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/statistics_test_harness.dart';

/// Contributes a chart, as restock's "Runs out in" does.
final class _ChartContributingModule extends FeatureModuleBase {
  const _ChartContributingModule();

  @override
  String get moduleIdentifier => 'chart_contributor';

  @override
  List<InsightChartContribution> get insightCharts => [
    InsightChartContribution(
      identifier: 'chart_contributor.days',
      sortOrder: 10,
      builder: (context, filter) => Text(
        'Contributed: ${filter.periodEnd.difference(filter.periodStart).inDays} days, '
        '${filter.categoryIdentifiers.length} categories',
      ),
    ),
  ];
}

Future<void> _pumpDetails(WidgetTester tester, StatisticsTestHarness harness) async {
  tester.view.physicalSize = const Size(1200, 9000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: harness.container,
      child: buildLocalizedTestApplication(
        featureLocalizationDelegates: const [
          StatisticsLocalizations.delegate,
          ProductCatalogLocalizations.delegate,
          StorageLayoutLocalizations.delegate,
          InventoryLocalizations.delegate,
        ],
        home: const InsightDetailsScreen(),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var round = 0; round < 5; round++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}

/// Today is Friday 2 October 2026. Peas eaten on Saturday 12 and Sunday 27
/// September, pizza on Tuesday 29 September; chicken thrown away.
Future<void> _recordHistory(StatisticsTestHarness harness) async {
  await harness.seedCatalogAndStoragePlace();
  final peas = await harness.productWithKey('gardenPeas');
  final chicken = await harness.productWithKey('chickenBreast');
  final pizza = await harness.productWithKey('pizzaMargherita');
  final peasBatch = await harness.addBatch(peas, 1000, daysAgo: 40);
  final chickenBatch = await harness.addBatch(chicken, 800, daysAgo: 30, compartmentIndex: 1);
  final pizzaBatch = await harness.addBatch(pizza, 2, daysAgo: 30);
  await harness.consume(peasBatch, peas, 300, daysAgo: 20);
  await harness.consume(peasBatch, peas, 200, daysAgo: 5);
  await harness.discard(chickenBatch, chicken, 400, daysAgo: 10);
  await harness.consume(pizzaBatch, pizza, 1, daysAgo: 3);
}

void main() {
  late StatisticsTestHarness harness;

  setUp(
    () => harness = StatisticsTestHarness(registeredModules: [const _ChartContributingModule()]),
  );
  tearDown(() => harness.dispose());

  testWidgets('shows when and where the freezer is used, and contributed charts', (tester) async {
    await tester.runAsync(() => _recordHistory(harness));
    await _pumpDetails(tester, harness);

    expect(find.text('Insights · details'), findsOneWidget);
    expect(find.text('Busy days'), findsOneWidget);
    expect(find.byType(CalendarHeatmap), findsOneWidget);
    expect(find.text('By weekday'), findsOneWidget);
    expect(find.bySemanticsLabel('Sat: 0.3 kg'), findsOneWidget);
    expect(find.bySemanticsLabel('Sun: 0.2 kg'), findsOneWidget);
    expect(find.text('Time stored before use'), findsOneWidget);
    expect(find.bySemanticsLabel('< 1 mo: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('1–3 mo: 1'), findsOneWidget);
    expect(find.text('Storage map'), findsOneWidget);
    expect(find.byType(StorageMap), findsOneWidget);
    // The contributed chart sees the same 90-day period.
    expect(find.text('Contributed: 90 days, 0 categories'), findsOneWidget);
  });

  testWidgets('tapping a weekday or a drawer filters every chart', (tester) async {
    await tester.runAsync(() => _recordHistory(harness));
    await _pumpDetails(tester, harness);

    await tester.tap(find.bySemanticsLabel('Sat: 0.3 kg'));
    await _settle(tester);
    expect(harness.read(statisticsFilterProvider).weekdays, {DateTime.saturday});
    expect(find.widgetWithText(InputChip, 'Sat'), findsOneWidget);
    // The weekday chart keeps showing every day, so it can be changed again.
    expect(find.bySemanticsLabel('Sun: 0.2 kg'), findsOneWidget);
    expect(find.bySemanticsLabel('1–3 mo: 0'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('^Drawer 2')));
    await _settle(tester);
    expect(harness.read(statisticsFilterProvider).compartmentIdentifiers, hasLength(1));
    expect(find.text('Filters · 2'), findsOneWidget);
  });

  testWidgets('applies a suggested view and saves and removes a view of its own', (tester) async {
    await tester.runAsync(() => _recordHistory(harness));
    await _pumpDetails(tester, harness);

    await tester.tap(find.text('Filters · 0'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'Waste check'));
    await _settle(tester);
    final wasteCheck = harness.read(statisticsFilterProvider);
    expect(wasteCheck.activity, StatisticsActivity.discarded);
    expect(wasteCheck.comparison, StatisticsComparison.samePeriodLastYear);

    await tester.tap(find.text('Save this view'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).last, '  Chicken waste ');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);
    expect(
      await tester.runAsync(() => harness.read(savedStatisticsViewStoreProvider).watch().first),
      [SavedStatisticsView(name: 'Chicken waste', filter: wasteCheck)],
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'All time'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(InputChip, 'Chicken waste'));
    await _settle(tester);
    expect(harness.read(statisticsFilterProvider), wasteCheck);

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(InputChip, 'Chicken waste'),
        matching: find.byIcon(Icons.clear),
      ),
    );
    await _settle(tester);
    expect(find.widgetWithText(InputChip, 'Chicken waste'), findsNothing);
  });

  test('saved views keep every filter choice through the preference codec', () async {
    await harness.seedCatalogAndStoragePlace();
    final catalog = await harness.read(productCatalogQueryServiceProvider).readCatalog();
    final layout = await harness.read(storageLayoutQueryServiceProvider).readStorageLayout();
    final filter = SuggestedStatisticsView.weekendMeals
        .filterFor(catalog.categories)
        .withProductToggled(catalog.activeProducts.first.identifier)
        .withCompartmentToggled(layout.activeCompartments.first.identifier)
        .withCustomPeriod(StatisticsDateRange(CalendarDate(2026, 1, 1), CalendarDate(2026, 3, 31)));
    expect(filter.categoryIdentifiers, hasLength(1));

    final store = harness.read(savedStatisticsViewStoreProvider);
    await store.save(SavedStatisticsView(name: 'Weekends', filter: filter));
    await store.save(const SavedStatisticsView(name: 'Plain', filter: StatisticsFilter.initial));
    await store.save(SavedStatisticsView(name: 'Weekends', filter: filter));
    expect(await store.watch().first, [
      const SavedStatisticsView(name: 'Plain', filter: StatisticsFilter.initial),
      SavedStatisticsView(name: 'Weekends', filter: filter),
    ]);

    await store.remove('Plain');
    expect((await store.watch().first).single.filter, filter);
    // Unknown values from a newer app version fall back to the defaults.
    expect(
      SavedStatisticsViewCodec.decodeFilter({
        'measure': 'calories',
        'weekdays': [6, 9],
      }),
      StatisticsFilter.initial.withWeekdayToggled(DateTime.saturday),
    );
  });
}
