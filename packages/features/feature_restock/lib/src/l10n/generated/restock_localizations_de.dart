// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'restock_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class RestockLocalizationsDe extends RestockLocalizations {
  RestockLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navigationLabel => 'Liste';

  @override
  String get shoppingListTitle => 'Einkaufsliste';

  @override
  String get shoppingListSubtitle => 'Knappe Produkte werden automatisch ergänzt';

  @override
  String get originRestock => 'Wird knapp';

  @override
  String get originManual => 'Von dir ergänzt';

  @override
  String putTickedInFreezer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abgehakte Einträge einfrieren',
      one: '1 abgehakten Eintrag einfrieren',
    );
    return '$_temp0';
  }

  @override
  String get nothingTicked => 'Hake ab, was du gekauft hast';

  @override
  String itemsPutInFreezer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte sind jetzt im Gefrierschrank',
      one: '1 Produkt ist jetzt im Gefrierschrank',
      zero: 'Abgehakte Einträge von der Liste entfernt',
    );
    return '$_temp0';
  }

  @override
  String get addToListButton => 'Hinzufügen';

  @override
  String get emptyListTitle => 'Deine Einkaufsliste ist leer';

  @override
  String get emptyListMessage =>
      'Produkte mit Mindestmenge erscheinen hier, wenn sie knapp werden. Alles andere fügst du mit dem Knopf unten hinzu.';

  @override
  String get entryRemoved => 'Von der Liste entfernt';

  @override
  String get runningLowTitle => 'Wird knapp';

  @override
  String get shoppingListLink => 'Einkaufsliste';

  @override
  String get runningLowEmpty => 'Alles ist vorrätig.';

  @override
  String get configSectionTitle => 'Nachkaufen';

  @override
  String get configSectionExplanation =>
      'Lege eine Mindestmenge für Lebensmittel fest, die du immer zu Hause haben möchtest. Ist weniger im Gefrierschrank, kommen sie auf die Einkaufsliste.';

  @override
  String get minimumQuantitiesRow => 'Mindestmengen';

  @override
  String ruleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '1 Produkt',
      zero: 'Noch keine',
    );
    return '$_temp0';
  }

  @override
  String get rulesEmptyTitle => 'Noch keine Mindestmengen';

  @override
  String get rulesEmptyMessage => 'Füge ein Produkt hinzu, das immer im Gefrierschrank sein soll.';

  @override
  String get addRuleButton => 'Produkt hinzufügen';

  @override
  String ruleSummary(String minimum, String stock) {
    return 'Mindestens $minimum · $stock im Gefrierschrank';
  }

  @override
  String ruleSummaryWithTarget(String minimum, String target, String stock) {
    return 'Mindestens $minimum, auffüllen auf $target · $stock im Gefrierschrank';
  }

  @override
  String get minimumLabel => 'Mindestens vorrätig';

  @override
  String get targetLabel => 'Auffüllen auf (optional)';

  @override
  String get minimumNotPositive => 'Gib eine Menge über null ein.';

  @override
  String get targetBelowMinimum => 'Das muss mindestens die Mindestmenge sein.';

  @override
  String get noFreezerForBoughtItems =>
      'Richte zuerst deinen Gefrierschrank ein, dann kannst du die Einkäufe einräumen.';

  @override
  String get automaticEntryCannotBeRemoved =>
      'Dieser Eintrag folgt seiner Mindestmenge. Ändere die Mindestmenge, um ihn von der Liste zu nehmen.';

  @override
  String get genericFailure => 'Das hat nicht geklappt. Bitte versuche es noch einmal.';

  @override
  String get forecastTitle => 'Reicht noch';

  @override
  String get forecastSubtitle => 'Aus den letzten 60 Tagen';

  @override
  String forecastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '≈ $count Tage',
      one: '≈ 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get forecastNever => 'zuletzt nicht genutzt';

  @override
  String get forecastEmpty =>
      'Lege eine Mindestmenge für ein Produkt fest, um zu sehen, wann es ausgeht.';

  @override
  String get forecastNoMatch => 'Kein Produkt mit Mindestmenge passt zu diesen Filtern.';

  @override
  String get forecastTableProduct => 'Produkt';

  @override
  String get forecastTableStock => 'Im Gefrierschrank';

  @override
  String get forecastTableDays => 'Tage übrig';

  @override
  String forecastAddedToList(String productName) {
    return '$productName steht auf der Einkaufsliste';
  }
}
