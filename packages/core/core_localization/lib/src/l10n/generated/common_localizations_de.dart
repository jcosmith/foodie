// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'common_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class CommonLocalizationsDe extends CommonLocalizations {
  CommonLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionRemove => 'Entfernen';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionSeeAll => 'Alle';

  @override
  String quantityGrams(String amount) {
    return '$amount g';
  }

  @override
  String quantityKilograms(String amount) {
    return '$amount kg';
  }

  @override
  String quantityMilliliters(String amount) {
    return '$amount ml';
  }

  @override
  String quantityLiters(String amount) {
    return '$amount l';
  }

  @override
  String quantityPieces(String amount) {
    return '$amount Stück';
  }

  @override
  String quantityPortions(String amount, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Portionen',
      one: 'Portion',
    );
    return '$amount $_temp0';
  }

  @override
  String get unitGram => 'Gramm';

  @override
  String get unitMilliliter => 'Milliliter';

  @override
  String get unitPiece => 'Stück';

  @override
  String get unitPortion => 'Portionen';

  @override
  String get unitSymbolGram => 'g';

  @override
  String get unitSymbolMilliliter => 'ml';

  @override
  String get unitSymbolPiece => 'Stück';

  @override
  String get unitSymbolPortion => 'Portionen';

  @override
  String get relativeAgeToday => 'heute';

  @override
  String get relativeAgeYesterday => 'gestern';

  @override
  String relativeAgeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String relativeAgeWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Wochen',
      one: 'vor 1 Woche',
    );
    return '$_temp0';
  }

  @override
  String relativeAgeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Monaten',
      one: 'vor 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String relativeAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Jahren',
      one: 'vor 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wochen',
      one: '1 Woche',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate',
      one: '1 Monat',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeAboutWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'etwa $count Wochen',
      one: 'etwa 1 Woche',
    );
    return '$_temp0';
  }

  @override
  String shelfLifeAboutMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'etwa $count Monate',
      one: 'etwa 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String get shelfLifeUnitDays => 'Tage';

  @override
  String get shelfLifeUnitWeeks => 'Wochen';

  @override
  String get shelfLifeUnitMonths => 'Monate';

  @override
  String get shelfLifeUnitLabel => 'Einheit';

  @override
  String get shelfLifeOutOfRange => 'Gib 1 Tag bis 36 Monate ein.';

  @override
  String get storageAgeFresh => 'Frisch';

  @override
  String get storageAgeAging => 'Bald verbrauchen';

  @override
  String get storageAgeUrgent => 'Jetzt essen';

  @override
  String get storageAgeOverdue => 'Überfällig';

  @override
  String get emptyStateNothingHereYet => 'Noch nichts da';

  @override
  String get privacyPromise => 'Deine Daten verlassen nie dieses Telefon';

  @override
  String get chartShowTable => 'Tabelle';

  @override
  String get chartShowChart => 'Diagramm';
}
