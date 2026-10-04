import 'package:core_foundation/core_foundation.dart';
import 'package:feature_product_catalog/domain.dart';
import 'package:feature_statistics/domain.dart';
import 'package:feature_storage_layout/domain.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = CalendarDate(2026, 10, 2);
const _vegetables = CategoryIdentifier('category-vegetables');
const _meals = CategoryIdentifier('category-meals');
const _peas = ProductIdentifier('product-peas');
const _soup = ProductIdentifier('product-soup');
const _pizza = ProductIdentifier('product-pizza');
const _drawer1 = CompartmentIdentifier('drawer-1');
const _drawer2 = CompartmentIdentifier('drawer-2');

Category _category(CategoryIdentifier identifier, String? catalogKey, int sortOrder) => Category(
  identifier: identifier,
  catalogKey: catalogKey,
  customName: catalogKey == null ? 'Custom $sortOrder' : null,
  recommendedMaximumStorageDays: 180,
  iconEmoji: '❄️',
  sortOrder: sortOrder,
  storageDomain: StorageDomainIdentifier.freezer,
);

StatisticsMovementFact _fact({
  required int daysAgo,
  required StatisticsActivity activity,
  ProductIdentifier product = _peas,
  CategoryIdentifier category = _vegetables,
  CompartmentIdentifier compartment = _drawer1,
  int grams = 0,
  Quantity? quantity,
  int count = 1,
  int storedDays = 30,
  StatisticsDiscardReason reason = StatisticsDiscardReason.notGiven,
}) => StatisticsMovementFact(
  day: _today.addDays(-daysAgo),
  activity: activity,
  productIdentifier: product,
  categoryIdentifier: category,
  compartmentIdentifier: compartment,
  quantity: quantity ?? Quantity(amountInBaseUnits: grams, unit: QuantityUnit.gram),
  movementCount: count,
  storedDays: storedDays,
  discardReason: reason,
);

StatisticsAnalysis _analyse(
  List<StatisticsMovementFact> facts, {
  StatisticsFilter filter = StatisticsFilter.initial,
  CalendarDate? firstActivityDay,
}) {
  final periods = StatisticsPeriods.resolve(
    filter: filter,
    today: _today,
    firstActivityDay: firstActivityDay ?? _today.addDays(-400),
  );
  final comparisonPeriod = periods.comparisonPeriod;
  return StatisticsAnalysis(
    filter: filter,
    periods: periods,
    periodFacts: [
      for (final fact in facts)
        if (periods.period.contains(fact.day)) fact,
    ],
    comparisonFacts: [
      for (final fact in facts)
        if (comparisonPeriod != null && comparisonPeriod.contains(fact.day)) fact,
    ],
    categoryGrouping: StatisticsCategoryGrouping.fromCategories([
      _category(_vegetables, 'vegetables', 0),
      _category(_meals, 'meals', 1),
    ]),
  );
}

void main() {
  group('periods', () {
    test('presets end today and the comparison precedes them', () {
      final periods = StatisticsPeriods.resolve(
        filter: StatisticsFilter.initial,
        today: _today,
        firstActivityDay: CalendarDate(2025, 1, 1),
      );
      expect(periods.period, StatisticsDateRange(CalendarDate(2026, 7, 5), _today));
      expect(periods.period.lengthInDays, 90);
      expect(
        periods.comparisonPeriod,
        StatisticsDateRange(CalendarDate(2026, 4, 6), CalendarDate(2026, 7, 4)),
      );
    });

    test('this year, last year and all time', () {
      final thisYear = StatisticsPeriods.resolve(
        filter: StatisticsFilter.initial
            .withPeriodPreset(StatisticsPeriodPreset.thisYear)
            .withComparison(StatisticsComparison.samePeriodLastYear),
        today: CalendarDate(2028, 2, 29),
        firstActivityDay: CalendarDate(2026, 1, 1),
      );
      expect(thisYear.period.firstDay, CalendarDate(2028, 1, 1));
      expect(
        thisYear.comparisonPeriod,
        StatisticsDateRange(CalendarDate(2027, 1, 1), CalendarDate(2027, 2, 28)),
      );

      final allTime = StatisticsPeriods.resolve(
        filter: StatisticsFilter.initial.withPeriodPreset(StatisticsPeriodPreset.allTime),
        today: _today,
        firstActivityDay: CalendarDate(2026, 9, 1),
      );
      expect(allTime.period.firstDay, CalendarDate(2026, 9, 1));
      // Nothing was recorded before, so there is nothing to compare with.
      expect(allTime.comparisonPeriod, isNull);
    });
  });

  group('buckets', () {
    test('automatic granularity follows the period length', () {
      StatisticsBucketSize sizeFor(int days) => StatisticsBucketing.bucketSizeFor(
        StatisticsGranularity.automatic,
        StatisticsDateRange(_today.addDays(1 - days), _today),
      );
      expect(sizeFor(30), StatisticsBucketSize.day);
      expect(sizeFor(90), StatisticsBucketSize.week);
      expect(sizeFor(365), StatisticsBucketSize.month);
    });

    test('weeks start on the first day and months are cut to the period', () {
      final period = StatisticsDateRange(CalendarDate(2026, 8, 20), _today);
      final weeks = StatisticsBucketing.buildBuckets(period, StatisticsBucketSize.week);
      expect(
        weeks.first,
        StatisticsDateRange(CalendarDate(2026, 8, 20), CalendarDate(2026, 8, 26)),
      );
      expect(weeks.last, StatisticsDateRange(CalendarDate(2026, 10, 1), _today));
      final months = StatisticsBucketing.buildBuckets(period, StatisticsBucketSize.month);
      expect(months, [
        StatisticsDateRange(CalendarDate(2026, 8, 20), CalendarDate(2026, 8, 31)),
        StatisticsDateRange(CalendarDate(2026, 9, 1), CalendarDate(2026, 9, 30)),
        StatisticsDateRange(CalendarDate(2026, 10, 1), _today),
      ]);
      final index = StatisticsBucketIndex(months);
      expect(index.indexOf(CalendarDate(2026, 9, 15)), 1);
      expect(index.indexOf(CalendarDate(2026, 8, 19)), isNull);
    });
  });

  test('categories keep their colour slot; extra ones fold into Other', () {
    final grouping = StatisticsCategoryGrouping.fromCategories([
      _category(const CategoryIdentifier('fruit'), 'fruit', 0),
      _category(const CategoryIdentifier('custom-a'), null, 1),
      _category(const CategoryIdentifier('vegetables'), 'vegetables', 2),
      _category(const CategoryIdentifier('other'), 'other', 3),
      for (var number = 0; number < 5; number++)
        _category(CategoryIdentifier('custom-$number'), null, 4 + number),
    ]);
    expect(grouping.paletteIndexOf(const CategoryIdentifier('vegetables')), 0);
    expect(grouping.paletteIndexOf(const CategoryIdentifier('fruit')), 3);
    expect(grouping.paletteIndexOf(const CategoryIdentifier('custom-a')), 1);
    expect(grouping.paletteIndexOf(const CategoryIdentifier('other')), isNull);
    expect(grouping.groups, hasLength(7));
    expect(grouping.groups.last.isOther, isTrue);
    expect(grouping.groups.last.categoryIdentifiers, {
      const CategoryIdentifier('other'),
      const CategoryIdentifier('custom-3'),
      const CategoryIdentifier('custom-4'),
    });
  });

  group('analysis', () {
    final facts = [
      _fact(daysAgo: 80, activity: StatisticsActivity.added, grams: 3000),
      _fact(daysAgo: 10, activity: StatisticsActivity.consumed, grams: 400, storedDays: 70),
      _fact(
        daysAgo: 3,
        activity: StatisticsActivity.consumed,
        grams: 600,
        count: 2,
        storedDays: 10,
      ),
      _fact(
        daysAgo: 4,
        activity: StatisticsActivity.consumed,
        product: _soup,
        category: _meals,
        compartment: _drawer2,
        grams: 1000,
      ),
      _fact(
        daysAgo: 5,
        activity: StatisticsActivity.discarded,
        product: _soup,
        category: _meals,
        grams: 500,
        reason: StatisticsDiscardReason.freezerBurn,
      ),
      _fact(
        daysAgo: 6,
        activity: StatisticsActivity.consumed,
        product: _pizza,
        category: _meals,
        quantity: const Quantity(amountInBaseUnits: 2000, unit: QuantityUnit.piece),
      ),
      // In the comparison period.
      _fact(daysAgo: 100, activity: StatisticsActivity.consumed, grams: 1000),
    ];

    test('key figures with their change against the previous period', () {
      final analysis = _analyse(facts);
      expect(analysis.totalOf(StatisticsActivity.consumed).current, 2.0);
      expect(analysis.totalOf(StatisticsActivity.consumed).previous, 1.0);
      expect(analysis.totalOf(StatisticsActivity.consumed).relativeChange, 1.0);
      expect(analysis.totalOf(StatisticsActivity.added).current, 3.0);
      expect(analysis.wasteShare.current, closeTo(0.5 / 2.5, 1e-9));
      // Per item: 70 + 10 + 10 + 30 + 30 days over 5 items.
      expect(analysis.averageStoredDaysBeforeEaten.current, 30);
      expect(analysis.storedDaysHistogram.first, 4);
      expect(analysis.storedDaysHistogram[1], 1);
      expect(analysis.removalCount, 6);
      expect(analysis.isThinData, isFalse);
    });

    test('weight leaves out products in pieces; count includes them', () {
      final byWeight = _analyse(facts);
      expect(byWeight.productsLeftOutByMeasure, 1);
      final byCount = _analyse(
        facts,
        filter: StatisticsFilter.initial.withMeasure(StatisticsMeasure.count),
      );
      expect(byCount.totalOf(StatisticsActivity.consumed).current, 5);
      expect(byCount.productsLeftOutByMeasure, 0);
      final byPieces = _analyse(
        facts,
        filter: StatisticsFilter.initial.withMeasure(StatisticsMeasure.pieces),
      );
      expect(byPieces.totalOf(StatisticsActivity.consumed).current, 2);
    });

    test('category, drawer and weekday filters narrow every figure', () {
      final meals = _analyse(facts, filter: StatisticsFilter.initial.withCategoryToggled(_meals));
      expect(meals.totalOf(StatisticsActivity.consumed).current, 1.0);
      expect(meals.categorySeries.map((series) => series.group.categoryIdentifiers.single), [
        _meals,
      ]);
      expect(meals.isGroupDimmed(meals.categoryGrouping.groups.first), isTrue);

      final drawer2 = _analyse(
        facts,
        filter: StatisticsFilter.initial.withCompartmentToggled(_drawer2),
      );
      expect(drawer2.totalOf(StatisticsActivity.consumed).current, 1.0);

      final weekday = _today.addDays(-3).weekday;
      final oneWeekday = _analyse(
        facts,
        filter: StatisticsFilter.initial.withWeekdayToggled(weekday),
      );
      expect(oneWeekday.totalOf(StatisticsActivity.consumed).current, 1.0);
    });

    test('bucket values line up with the comparison period', () {
      final analysis = _analyse(facts);
      expect(analysis.bucketSize, StatisticsBucketSize.week);
      expect(analysis.buckets, hasLength(13));
      final eaten = analysis.bucketValuesOf(StatisticsActivity.consumed);
      expect(eaten.reduce((sum, value) => sum + value), 2.0);
      // The last, shorter week holds the last six days: peas and soup.
      expect(eaten.last, 1.6);
      final comparison = analysis.comparisonBucketValuesOf(StatisticsActivity.consumed)!;
      expect(comparison, hasLength(13));
      expect(comparison.reduce((sum, value) => sum + value), 1.0);
    });

    test('top products and waste reasons', () {
      final analysis = _analyse(facts);
      expect(analysis.topProducts(StatisticsActivity.consumed), [(_peas, 1.0), (_soup, 1.0)]);
      expect(analysis.topProducts(StatisticsActivity.discarded), [(_soup, 0.5)]);
      expect(analysis.discardedItemsByReason, [
        (StatisticsDiscardReason.tooOld, 0),
        (StatisticsDiscardReason.freezerBurn, 1),
        (StatisticsDiscardReason.unwanted, 0),
        (StatisticsDiscardReason.other, 0),
      ]);
    });

    test('a few removals are flagged as thin data', () {
      final analysis = _analyse([facts[1], facts[2]]);
      expect(analysis.removalCount, 3);
      expect(analysis.isThinData, isTrue);
    });
  });

  test('the filter counts its active choices and toggles back', () {
    final filter = StatisticsFilter.initial
        .withCategoryToggled(_meals)
        .withWeekdayToggled(DateTime.saturday)
        .withMeasure(StatisticsMeasure.count);
    expect(filter.activeFilterCount, 3);
    expect(
      filter.withCategoryToggled(_meals).withWeekdayToggled(DateTime.saturday).activeFilterCount,
      1,
    );
    expect(
      filter
          .withCategoryToggled(_meals)
          .withWeekdayToggled(DateTime.saturday)
          .withMeasure(StatisticsMeasure.weight),
      StatisticsFilter.initial,
    );
    final group = {_meals, _vegetables};
    expect(StatisticsFilter.initial.withCategoryGroupToggled(group).categoryIdentifiers, group);
    expect(
      StatisticsFilter.initial.withCategoryGroupToggled(group).withCategoryGroupToggled(group),
      StatisticsFilter.initial,
    );
  });
}
