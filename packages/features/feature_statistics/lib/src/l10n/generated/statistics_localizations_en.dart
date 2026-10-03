// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'statistics_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class StatisticsLocalizationsEn extends StatisticsLocalizations {
  StatisticsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationLabel => 'Insights';

  @override
  String get insightsTitle => 'Insights';

  @override
  String periodLabel(String from, String to) {
    return '$from – $to';
  }

  @override
  String get period30Days => '30 days';

  @override
  String get period3Months => '3 months';

  @override
  String get period12Months => '12 months';

  @override
  String get periodThisYear => 'This year';

  @override
  String get periodAllTime => 'All time';

  @override
  String get periodCustom => 'Custom';

  @override
  String filtersButton(int count) {
    return 'Filters · $count';
  }

  @override
  String get resetFilters => 'Reset';

  @override
  String get kpiEaten => 'Eaten';

  @override
  String get kpiAdded => 'Added';

  @override
  String get kpiWasted => 'Thrown away';

  @override
  String get kpiStored => 'Avg. days stored';

  @override
  String deltaUp(String value) {
    return '▲ $value vs before';
  }

  @override
  String deltaDown(String value) {
    return '▼ $value vs before';
  }

  @override
  String get deltaSame => '= same as before';

  @override
  String get deltaNone => 'no comparison';

  @override
  String get trendTitle => 'Eaten vs added';

  @override
  String get trendSubtitle => 'Drag across the chart to zoom in';

  @override
  String get trendSubtitleWithComparison => 'Dashed: eaten in the comparison period · drag to zoom';

  @override
  String get seriesEaten => 'Eaten';

  @override
  String get seriesAdded => 'Added';

  @override
  String get seriesComparison => 'Before';

  @override
  String stackedTitle(String activity) {
    return '$activity by category';
  }

  @override
  String get donutTitle => 'Category share';

  @override
  String get total => 'Total';

  @override
  String get topProductsTitle => 'Top products';

  @override
  String get wasteTitle => 'Thrown away, by reason';

  @override
  String get wasteSubtitle => 'Number of items';

  @override
  String get noData => 'Nothing matches these filters.';

  @override
  String thinData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Only $count items taken out in this period; trends need more data.',
      one: 'Only 1 item taken out in this period; trends need more data.',
    );
    return '$_temp0';
  }

  @override
  String get noHistoryTitle => 'No activity yet';

  @override
  String get noHistoryMessage =>
      'Insights appear once you put items in the freezer and take them out.';

  @override
  String get activityConsumed => 'Eaten';

  @override
  String get activityAdded => 'Added';

  @override
  String get activityDiscarded => 'Thrown away';

  @override
  String get activityMoved => 'Moved';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersSubtitle => 'Applies to every chart';

  @override
  String get filterPeriod => 'Period';

  @override
  String get filterFrom => 'From';

  @override
  String get filterTo => 'To';

  @override
  String get filterCompare => 'Compare with';

  @override
  String get compareOff => 'Off';

  @override
  String get comparePrevious => 'Previous period';

  @override
  String get compareLastYear => 'Last year';

  @override
  String get filterGranularity => 'Group by';

  @override
  String get granularityAuto => 'Auto';

  @override
  String get granularityDay => 'Day';

  @override
  String get granularityWeek => 'Week';

  @override
  String get granularityMonth => 'Month';

  @override
  String get filterMeasure => 'Measure';

  @override
  String get measureWeight => 'Weight';

  @override
  String get measureVolume => 'Volume';

  @override
  String get measurePieces => 'Pieces';

  @override
  String get measureCount => 'Count';

  @override
  String measureHiddenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products use other units and are left out.',
      one: '1 product uses another unit and is left out.',
    );
    return '$_temp0';
  }

  @override
  String get measureAllHint => 'Counts every item, whatever its unit.';

  @override
  String get filterActivity => 'Activity';

  @override
  String get filterCategories => 'Categories';

  @override
  String get filterDrawers => 'Drawers';

  @override
  String get filterProducts => 'Products';

  @override
  String get filterWeekdays => 'Weekdays';

  @override
  String get productSearch => 'Search products';

  @override
  String get otherCategories => 'Other';

  @override
  String get reasonTooOld => 'Stored too long';

  @override
  String get reasonFreezerBurn => 'Freezer burn';

  @override
  String get reasonUnwanted => 'Nobody wanted it';

  @override
  String get reasonOther => 'Other';

  @override
  String get reasonNotGiven => 'No reason given';

  @override
  String countValue(String count) {
    return '$count×';
  }

  @override
  String daysValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get detailsTitle => 'Insights · details';

  @override
  String get detailsButton => 'More insights';

  @override
  String get detailsButtonSubtitle => 'Freezer days, weekdays, storage time and the freezer map';

  @override
  String get calendarTitle => 'Freezer days';

  @override
  String calendarSubtitle(String activityItems) {
    return 'Number of $activityItems per day';
  }

  @override
  String calendarSelectedDay(String day, int count) {
    return '$day: $count';
  }

  @override
  String get activityItemsConsumed => 'items eaten';

  @override
  String get activityItemsAdded => 'items added';

  @override
  String get activityItemsDiscarded => 'items thrown away';

  @override
  String get activityItemsMoved => 'items moved';

  @override
  String get weekdayTitle => 'By weekday';

  @override
  String get durationTitle => 'Time in freezer before eaten';

  @override
  String get durationSubtitle => 'Number of items eaten, by storage time';

  @override
  String get durationUnderOneMonth => '< 1 mo';

  @override
  String get durationOneToThreeMonths => '1–3 mo';

  @override
  String get durationThreeToSixMonths => '3–6 mo';

  @override
  String get durationSixToNineMonths => '6–9 mo';

  @override
  String get durationNineToTwelveMonths => '9–12 mo';

  @override
  String get durationOverTwelveMonths => '> 12 mo';

  @override
  String get sixMonthMarker => '6 mo';

  @override
  String get freezerMapTitle => 'Freezer map';

  @override
  String get freezerMapSubtitle => 'Current contents by drawer, coloured by age. Tap to filter.';

  @override
  String drawerItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get filterSavedViews => 'Saved views';

  @override
  String get viewWeekendMeals => 'Weekend meals';

  @override
  String get viewWasteCheck => 'Waste check';

  @override
  String get viewFruitSeason => 'Fruit season';

  @override
  String get saveViewButton => 'Save this view';

  @override
  String get saveViewTitle => 'Save view';

  @override
  String get saveViewNameLabel => 'Name';
}
