// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'statistics_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class StatisticsLocalizationsDe extends StatisticsLocalizations {
  StatisticsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get moreEntryTitle => 'Statistik';

  @override
  String get moreEntrySubtitle =>
      'Gewohnheiten, Verschwendung und Trends, mit einem gemeinsamen Filter';

  @override
  String get insightsTitle => 'Auswertung';

  @override
  String periodLabel(String from, String to) {
    return '$from – $to';
  }

  @override
  String get period30Days => '30 Tage';

  @override
  String get period3Months => '3 Monate';

  @override
  String get period12Months => '12 Monate';

  @override
  String get periodThisYear => 'Dieses Jahr';

  @override
  String get periodAllTime => 'Gesamt';

  @override
  String get periodCustom => 'Eigener';

  @override
  String filtersButton(int count) {
    return 'Filter · $count';
  }

  @override
  String get resetFilters => 'Zurücksetzen';

  @override
  String get kpiEaten => 'Gegessen';

  @override
  String get kpiAdded => 'Eingelagert';

  @override
  String get kpiWasted => 'Weggeworfen';

  @override
  String get kpiStored => 'Ø Tage gelagert';

  @override
  String deltaUp(String value) {
    return '▲ $value ggü. vorher';
  }

  @override
  String deltaDown(String value) {
    return '▼ $value ggü. vorher';
  }

  @override
  String get deltaSame => '= wie vorher';

  @override
  String get deltaNone => 'kein Vergleich';

  @override
  String get trendTitle => 'Gegessen vs. eingelagert';

  @override
  String get trendSubtitle => 'Über das Diagramm ziehen zum Zoomen';

  @override
  String get trendSubtitleWithComparison =>
      'Gestrichelt: gegessen im Vergleichszeitraum · ziehen zum Zoomen';

  @override
  String get seriesEaten => 'Gegessen';

  @override
  String get seriesAdded => 'Eingelagert';

  @override
  String get seriesComparison => 'Vorher';

  @override
  String stackedTitle(String activity) {
    return '$activity nach Kategorie';
  }

  @override
  String get donutTitle => 'Anteil der Kategorien';

  @override
  String get total => 'Gesamt';

  @override
  String get topProductsTitle => 'Top-Produkte';

  @override
  String get wasteTitle => 'Weggeworfen, nach Grund';

  @override
  String get wasteSubtitle => 'Anzahl Produkte';

  @override
  String get noData => 'Nichts passt zu diesen Filtern.';

  @override
  String thinData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nur $count Entnahmen in diesem Zeitraum; für Trends braucht es mehr Daten.',
      one: 'Nur 1 Entnahme in diesem Zeitraum; für Trends braucht es mehr Daten.',
    );
    return '$_temp0';
  }

  @override
  String get noHistoryTitle => 'Noch keine Aktivität';

  @override
  String get noHistoryMessage =>
      'Die Auswertung erscheint, sobald du Produkte einfrierst und entnimmst.';

  @override
  String get activityConsumed => 'Gegessen';

  @override
  String get activityAdded => 'Eingelagert';

  @override
  String get activityDiscarded => 'Weggeworfen';

  @override
  String get activityMoved => 'Umgelagert';

  @override
  String get filtersTitle => 'Filter';

  @override
  String get filtersSubtitle => 'Gilt für alle Diagramme';

  @override
  String get filterPeriod => 'Zeitraum';

  @override
  String get filterFrom => 'Von';

  @override
  String get filterTo => 'Bis';

  @override
  String get filterCompare => 'Vergleichen mit';

  @override
  String get compareOff => 'Aus';

  @override
  String get comparePrevious => 'Vorheriger Zeitraum';

  @override
  String get compareLastYear => 'Vorjahr';

  @override
  String get filterGranularity => 'Gruppieren nach';

  @override
  String get granularityAuto => 'Auto';

  @override
  String get granularityDay => 'Tag';

  @override
  String get granularityWeek => 'Woche';

  @override
  String get granularityMonth => 'Monat';

  @override
  String get filterMeasure => 'Maß';

  @override
  String get measureWeight => 'Gewicht';

  @override
  String get measureVolume => 'Volumen';

  @override
  String get measurePieces => 'Stück';

  @override
  String get measureCount => 'Anzahl';

  @override
  String measureHiddenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte haben andere Einheiten und fehlen.',
      one: '1 Produkt hat eine andere Einheit und fehlt.',
    );
    return '$_temp0';
  }

  @override
  String get measureAllHint => 'Zählt jedes Produkt, egal welche Einheit.';

  @override
  String get filterActivity => 'Aktivität';

  @override
  String get filterCategories => 'Kategorien';

  @override
  String get filterDrawers => 'Schubladen';

  @override
  String get filterProducts => 'Produkte';

  @override
  String get filterWeekdays => 'Wochentage';

  @override
  String get productSearch => 'Produkte suchen';

  @override
  String get otherCategories => 'Andere';

  @override
  String get reasonTooOld => 'Zu lange gelagert';

  @override
  String get reasonFreezerBurn => 'Gefrierbrand';

  @override
  String get reasonExpired => 'Abgelaufen';

  @override
  String get reasonSpoiled => 'Verdorben';

  @override
  String get reasonUnwanted => 'Wollte keiner';

  @override
  String get reasonOther => 'Anderes';

  @override
  String get reasonNotGiven => 'Ohne Angabe';

  @override
  String countValue(String count) {
    return '$count×';
  }

  @override
  String daysValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get detailsTitle => 'Auswertung · Details';

  @override
  String get detailsButton => 'Mehr Auswertungen';

  @override
  String get detailsButtonSubtitle =>
      'Gefrierfach-Tage, Wochentage, Lagerdauer und Gefrierfach-Karte';

  @override
  String get calendarTitle => 'Gefrierfach-Tage';

  @override
  String calendarSubtitle(String activityItems) {
    return 'Anzahl $activityItems pro Tag';
  }

  @override
  String calendarSelectedDay(String day, int count) {
    return '$day: $count';
  }

  @override
  String get activityItemsConsumed => 'gegessener Produkte';

  @override
  String get activityItemsAdded => 'eingelagerter Produkte';

  @override
  String get activityItemsDiscarded => 'weggeworfener Produkte';

  @override
  String get activityItemsMoved => 'umgelagerter Produkte';

  @override
  String get weekdayTitle => 'Nach Wochentag';

  @override
  String get durationTitle => 'Zeit im Gefrierfach vor dem Essen';

  @override
  String get durationSubtitle => 'Anzahl gegessener Produkte nach Lagerdauer';

  @override
  String get durationUnderOneMonth => '< 1 Mon.';

  @override
  String get durationOneToThreeMonths => '1–3 Mon.';

  @override
  String get durationThreeToSixMonths => '3–6 Mon.';

  @override
  String get durationSixToNineMonths => '6–9 Mon.';

  @override
  String get durationNineToTwelveMonths => '9–12 Mon.';

  @override
  String get durationOverTwelveMonths => '> 12 Mon.';

  @override
  String get sixMonthMarker => '6 Mon.';

  @override
  String get storageMapTitle => 'Gefrierfach-Karte';

  @override
  String get storageMapSubtitle =>
      'Aktueller Inhalt je Schublade, nach Alter gefärbt. Tippen zum Filtern.';

  @override
  String drawerItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '1 Produkt',
    );
    return '$_temp0';
  }

  @override
  String get filterSavedViews => 'Gespeicherte Ansichten';

  @override
  String get viewWeekendMeals => 'Wochenend-Essen';

  @override
  String get viewWasteCheck => 'Verschwendung';

  @override
  String get viewFruitSeason => 'Obstsaison';

  @override
  String get saveViewButton => 'Diese Ansicht speichern';

  @override
  String get saveViewTitle => 'Ansicht speichern';

  @override
  String get saveViewNameLabel => 'Name';
}
