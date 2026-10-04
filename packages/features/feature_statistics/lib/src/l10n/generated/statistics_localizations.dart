import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'statistics_localizations_de.dart';
import 'statistics_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of StatisticsLocalizations
/// returned by `StatisticsLocalizations.of(context)`.
///
/// Applications need to include `StatisticsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/statistics_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: StatisticsLocalizations.localizationsDelegates,
///   supportedLocales: StatisticsLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the StatisticsLocalizations.supportedLocales
/// property.
abstract class StatisticsLocalizations {
  StatisticsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static StatisticsLocalizations of(BuildContext context) {
    return Localizations.of<StatisticsLocalizations>(context, StatisticsLocalizations)!;
  }

  static const LocalizationsDelegate<StatisticsLocalizations> delegate =
      _StatisticsLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en')];

  /// No description provided for @moreEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get moreEntryTitle;

  /// No description provided for @moreEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Habits, waste and trends, with one shared filter'**
  String get moreEntrySubtitle;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String periodLabel(String from, String to);

  /// No description provided for @period30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get period30Days;

  /// No description provided for @period3Months.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get period3Months;

  /// No description provided for @period12Months.
  ///
  /// In en, this message translates to:
  /// **'12 months'**
  String get period12Months;

  /// No description provided for @periodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAllTime;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get periodCustom;

  /// No description provided for @filtersButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Filters} other{Filters · {count}}}'**
  String filtersButton(int count);

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @kpiEaten.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get kpiEaten;

  /// No description provided for @kpiAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get kpiAdded;

  /// No description provided for @kpiWasted.
  ///
  /// In en, this message translates to:
  /// **'Thrown away'**
  String get kpiWasted;

  /// No description provided for @kpiStored.
  ///
  /// In en, this message translates to:
  /// **'Avg. days stored'**
  String get kpiStored;

  /// No description provided for @deltaUp.
  ///
  /// In en, this message translates to:
  /// **'▲ {value} vs before'**
  String deltaUp(String value);

  /// No description provided for @deltaDown.
  ///
  /// In en, this message translates to:
  /// **'▼ {value} vs before'**
  String deltaDown(String value);

  /// No description provided for @deltaSame.
  ///
  /// In en, this message translates to:
  /// **'= same as before'**
  String get deltaSame;

  /// No description provided for @deltaNone.
  ///
  /// In en, this message translates to:
  /// **'no comparison'**
  String get deltaNone;

  /// No description provided for @trendTitle.
  ///
  /// In en, this message translates to:
  /// **'Used vs added'**
  String get trendTitle;

  /// No description provided for @trendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag across the chart to zoom in'**
  String get trendSubtitle;

  /// No description provided for @trendSubtitleWithComparison.
  ///
  /// In en, this message translates to:
  /// **'Dashed: used in the comparison period · drag to zoom'**
  String get trendSubtitleWithComparison;

  /// No description provided for @seriesEaten.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get seriesEaten;

  /// No description provided for @seriesAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get seriesAdded;

  /// No description provided for @seriesComparison.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get seriesComparison;

  /// No description provided for @stackedTitle.
  ///
  /// In en, this message translates to:
  /// **'{activity} by category'**
  String stackedTitle(String activity);

  /// No description provided for @donutTitle.
  ///
  /// In en, this message translates to:
  /// **'Category share'**
  String get donutTitle;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @topProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top products'**
  String get topProductsTitle;

  /// No description provided for @wasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Thrown away, by reason'**
  String get wasteTitle;

  /// No description provided for @wasteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Number of items'**
  String get wasteSubtitle;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters.'**
  String get noData;

  /// No description provided for @thinData.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Only 1 item taken out in this period; trends need more data.} other{Only {count} items taken out in this period; trends need more data.}}'**
  String thinData(int count);

  /// No description provided for @noHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noHistoryTitle;

  /// No description provided for @noHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Insights appear once you put items away and take them out.'**
  String get noHistoryMessage;

  /// No description provided for @activityConsumed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get activityConsumed;

  /// No description provided for @activityAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get activityAdded;

  /// No description provided for @activityDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Thrown away'**
  String get activityDiscarded;

  /// No description provided for @activityMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get activityMoved;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filtersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies to every chart'**
  String get filtersSubtitle;

  /// No description provided for @filterPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get filterPeriod;

  /// No description provided for @filterFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filterFrom;

  /// No description provided for @filterTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filterTo;

  /// No description provided for @filterCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare with'**
  String get filterCompare;

  /// No description provided for @compareOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get compareOff;

  /// No description provided for @comparePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get comparePrevious;

  /// No description provided for @compareLastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get compareLastYear;

  /// No description provided for @filterGranularity.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get filterGranularity;

  /// No description provided for @granularityAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get granularityAuto;

  /// No description provided for @granularityDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get granularityDay;

  /// No description provided for @granularityWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get granularityWeek;

  /// No description provided for @granularityMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get granularityMonth;

  /// No description provided for @filterMeasure.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get filterMeasure;

  /// No description provided for @measureWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get measureWeight;

  /// No description provided for @measureVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get measureVolume;

  /// No description provided for @measurePieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get measurePieces;

  /// No description provided for @measureCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get measureCount;

  /// No description provided for @measureHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product uses another unit and is left out.} other{{count} products use other units and are left out.}}'**
  String measureHiddenHint(int count);

  /// No description provided for @measureAllHint.
  ///
  /// In en, this message translates to:
  /// **'Counts every item, whatever its unit.'**
  String get measureAllHint;

  /// No description provided for @filterActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get filterActivity;

  /// No description provided for @filterCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get filterCategories;

  /// No description provided for @filterDrawers.
  ///
  /// In en, this message translates to:
  /// **'Compartments'**
  String get filterDrawers;

  /// No description provided for @filterStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get filterStorage;

  /// No description provided for @filterProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get filterProducts;

  /// No description provided for @filterWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get filterWeekdays;

  /// No description provided for @productSearch.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get productSearch;

  /// No description provided for @showAllProducts.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAllProducts;

  /// No description provided for @otherCategories.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategories;

  /// No description provided for @reasonTooOld.
  ///
  /// In en, this message translates to:
  /// **'Stored too long'**
  String get reasonTooOld;

  /// No description provided for @reasonFreezerBurn.
  ///
  /// In en, this message translates to:
  /// **'Freezer burn'**
  String get reasonFreezerBurn;

  /// No description provided for @reasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Past its date'**
  String get reasonExpired;

  /// No description provided for @reasonSpoiled.
  ///
  /// In en, this message translates to:
  /// **'Gone off'**
  String get reasonSpoiled;

  /// No description provided for @reasonUnwanted.
  ///
  /// In en, this message translates to:
  /// **'Nobody wanted it'**
  String get reasonUnwanted;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @reasonNotGiven.
  ///
  /// In en, this message translates to:
  /// **'No reason given'**
  String get reasonNotGiven;

  /// No description provided for @countValue.
  ///
  /// In en, this message translates to:
  /// **'{count}×'**
  String countValue(String count);

  /// No description provided for @daysValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysValue(int count);

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights · details'**
  String get detailsTitle;

  /// No description provided for @detailsButton.
  ///
  /// In en, this message translates to:
  /// **'More insights'**
  String get detailsButton;

  /// No description provided for @detailsButtonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Busy days, weekdays, storage time and the storage map'**
  String get detailsButtonSubtitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Busy days'**
  String get calendarTitle;

  /// No description provided for @calendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Number of {activityItems} per day'**
  String calendarSubtitle(String activityItems);

  /// No description provided for @calendarSelectedDay.
  ///
  /// In en, this message translates to:
  /// **'{day}: {count}'**
  String calendarSelectedDay(String day, int count);

  /// No description provided for @activityItemsConsumed.
  ///
  /// In en, this message translates to:
  /// **'items used'**
  String get activityItemsConsumed;

  /// No description provided for @activityItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'items added'**
  String get activityItemsAdded;

  /// No description provided for @activityItemsDiscarded.
  ///
  /// In en, this message translates to:
  /// **'items thrown away'**
  String get activityItemsDiscarded;

  /// No description provided for @activityItemsMoved.
  ///
  /// In en, this message translates to:
  /// **'items moved'**
  String get activityItemsMoved;

  /// No description provided for @weekdayTitle.
  ///
  /// In en, this message translates to:
  /// **'By weekday'**
  String get weekdayTitle;

  /// No description provided for @durationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time stored before use'**
  String get durationTitle;

  /// No description provided for @durationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Number of items used, by storage time'**
  String get durationSubtitle;

  /// No description provided for @durationUnderOneMonth.
  ///
  /// In en, this message translates to:
  /// **'< 1 mo'**
  String get durationUnderOneMonth;

  /// No description provided for @durationOneToThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'1–3 mo'**
  String get durationOneToThreeMonths;

  /// No description provided for @durationThreeToSixMonths.
  ///
  /// In en, this message translates to:
  /// **'3–6 mo'**
  String get durationThreeToSixMonths;

  /// No description provided for @durationSixToNineMonths.
  ///
  /// In en, this message translates to:
  /// **'6–9 mo'**
  String get durationSixToNineMonths;

  /// No description provided for @durationNineToTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'9–12 mo'**
  String get durationNineToTwelveMonths;

  /// No description provided for @durationOverTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'> 12 mo'**
  String get durationOverTwelveMonths;

  /// No description provided for @durationUnderTwoDays.
  ///
  /// In en, this message translates to:
  /// **'< 2 d'**
  String get durationUnderTwoDays;

  /// No description provided for @durationTwoToThreeDays.
  ///
  /// In en, this message translates to:
  /// **'2–3 d'**
  String get durationTwoToThreeDays;

  /// No description provided for @durationFourToSevenDays.
  ///
  /// In en, this message translates to:
  /// **'4–7 d'**
  String get durationFourToSevenDays;

  /// No description provided for @durationOneToTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'1–2 wk'**
  String get durationOneToTwoWeeks;

  /// No description provided for @durationTwoToFourWeeks.
  ///
  /// In en, this message translates to:
  /// **'2–4 wk'**
  String get durationTwoToFourWeeks;

  /// No description provided for @durationOverOneMonth.
  ///
  /// In en, this message translates to:
  /// **'> 1 mo'**
  String get durationOverOneMonth;

  /// No description provided for @sixMonthMarker.
  ///
  /// In en, this message translates to:
  /// **'6 mo'**
  String get sixMonthMarker;

  /// No description provided for @storageMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage map'**
  String get storageMapTitle;

  /// No description provided for @storageMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current contents by compartment, coloured by age. Tap to filter.'**
  String get storageMapSubtitle;

  /// No description provided for @drawerItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String drawerItems(int count);

  /// No description provided for @filterSavedViews.
  ///
  /// In en, this message translates to:
  /// **'Saved views'**
  String get filterSavedViews;

  /// No description provided for @viewWeekendMeals.
  ///
  /// In en, this message translates to:
  /// **'Weekend meals'**
  String get viewWeekendMeals;

  /// No description provided for @viewWasteCheck.
  ///
  /// In en, this message translates to:
  /// **'Waste check'**
  String get viewWasteCheck;

  /// No description provided for @viewFruitSeason.
  ///
  /// In en, this message translates to:
  /// **'Fruit season'**
  String get viewFruitSeason;

  /// No description provided for @saveViewButton.
  ///
  /// In en, this message translates to:
  /// **'Save this view'**
  String get saveViewButton;

  /// No description provided for @saveViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Save view'**
  String get saveViewTitle;

  /// No description provided for @saveViewNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get saveViewNameLabel;
}

class _StatisticsLocalizationsDelegate extends LocalizationsDelegate<StatisticsLocalizations> {
  const _StatisticsLocalizationsDelegate();

  @override
  Future<StatisticsLocalizations> load(Locale locale) {
    return SynchronousFuture<StatisticsLocalizations>(lookupStatisticsLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_StatisticsLocalizationsDelegate old) => false;
}

StatisticsLocalizations lookupStatisticsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return StatisticsLocalizationsDe();
    case 'en':
      return StatisticsLocalizationsEn();
  }

  throw FlutterError(
    'StatisticsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
