import 'package:core_design_system/core_design_system.dart';
import 'package:core_design_system/testing.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_product_catalog/feature_product_catalog.dart';
import 'package:feature_statistics/feature_statistics.dart';
import 'package:feature_statistics/src/presentation/insights_screen.dart';
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

Future<void> _pumpInsights(
  WidgetTester tester,
  StatisticsTestHarness harness, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1200, 9000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: harness.container,
      child: buildLocalizedTestApplication(
        locale: locale,
        featureLocalizationDelegates: const [
          StatisticsLocalizations.delegate,
          ProductCatalogLocalizations.delegate,
          StorageLayoutLocalizations.delegate,
        ],
        home: const InsightsScreen(),
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

/// Peas and chicken by weight, pizza by the piece, over the last 40 days.
Future<void> _recordHistory(StatisticsTestHarness harness) async {
  await harness.seedCatalogAndFreezer();
  final peas = await harness.productWithKey('gardenPeas');
  final chicken = await harness.productWithKey('chickenBreast');
  final pizza = await harness.productWithKey('pizzaMargherita');
  final peasBatch = await harness.addBatch(peas, 1000, daysAgo: 40);
  final chickenBatch = await harness.addBatch(chicken, 800, daysAgo: 30);
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

  testWidgets('explains that insights need some history first', (tester) async {
    await tester.runAsync(harness.seedCatalogAndFreezer);
    await _pumpInsights(tester, harness);

    expect(find.text('No activity yet'), findsOneWidget);
    expect(find.byType(KpiTile), findsNothing);
  });

  testWidgets('shows key figures and charts for the last three months', (tester) async {
    await tester.runAsync(() => _recordHistory(harness));
    await _pumpInsights(tester, harness);

    expect(find.text('Jul 5, 2026 – Oct 2, 2026'), findsOneWidget);
    expect(find.text('Filters · 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Eaten: 0.5 kg, no comparison'), findsOneWidget);
    expect(find.bySemanticsLabel('Added: 1.8 kg, no comparison'), findsOneWidget);
    expect(find.bySemanticsLabel('Thrown away: 44.4%, no comparison'), findsOneWidget);
    expect(find.bySemanticsLabel('Avg. days stored: 27 days, no comparison'), findsOneWidget);
    expect(
      find.text('Only 4 items taken out in this period; trends need more data.'),
      findsOneWidget,
    );
    expect(find.byType(TrendLineChart), findsOneWidget);
    expect(find.text('Eaten by category'), findsOneWidget);
    expect(find.text('🫛 Garden peas'), findsOneWidget);
    expect(find.text('Freezer burn'), findsOneWidget);
    expect(find.text('More insights'), findsOneWidget);
    // Contributed charts live on the details screen.
    expect(find.textContaining('Contributed'), findsNothing);
  });

  testWidgets('tapping a category filters every chart until reset', (tester) async {
    await tester.runAsync(() => _recordHistory(harness));
    await _pumpInsights(tester, harness);

    await tester.tap(
      find.descendant(of: find.byType(ChartLegend), matching: find.text('Meat & fish')),
    );
    await _settle(tester);

    expect(find.text('Filters · 1'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Meat & fish'), findsOneWidget);
    expect(find.bySemanticsLabel('Eaten: 0 kg, no comparison'), findsOneWidget);
    expect(find.bySemanticsLabel('Thrown away: 100%, no comparison'), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionChip, 'Reset'));
    await _settle(tester);
    expect(find.text('Filters · 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Eaten: 0.5 kg, no comparison'), findsOneWidget);
  });

  testWidgets('the filter sheet switches the measure and says what it leaves out', (tester) async {
    await tester.runAsync(() => _recordHistory(harness));
    await _pumpInsights(tester, harness);

    await tester.tap(find.text('Filters · 0'));
    await _settle(tester);
    expect(find.text('1 product uses another unit and is left out.'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Count'));
    await _settle(tester);
    expect(find.text('Counts every item, whatever its unit.'), findsOneWidget);
    expect(find.bySemanticsLabel('Eaten: 3×, no comparison'), findsOneWidget);
    expect(harness.read(statisticsFilterProvider).measure, StatisticsMeasure.count);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All time'));
    await _settle(tester);
    expect(harness.read(statisticsFilterProvider).periodPreset, StatisticsPeriodPreset.allTime);
  });

  testWidgets('follows the app language', (tester) async {
    await tester.runAsync(() => _recordHistory(harness));
    await _pumpInsights(tester, harness, locale: const Locale('de'));

    expect(find.text('Auswertung'), findsOneWidget);
    expect(find.text('Filter · 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Gegessen: 0,5 kg, kein Vergleich'), findsOneWidget);
  });

  test('the module is wired into the inventory it reads', () {
    expect(const StatisticsFeatureModule().navigationDestination.initialLocation, '/statistics');
    expect(DiscardReason.values, hasLength(StatisticsDiscardReason.values.length - 1));
  });
}
