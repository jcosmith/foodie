// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'storage_reminders_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class StorageRemindersLocalizationsDe extends StorageRemindersLocalizations {
  StorageRemindersLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get configSectionTitle => 'Erinnerungen';

  @override
  String get eatSoonTitle => 'Bald essen';

  @override
  String get eatSoonEmpty => 'Nichts Dringendes. Gut gemacht!';

  @override
  String get eatSoonScreenEmptyTitle => 'Nichts muss bald weg';

  @override
  String get eatSoonScreenEmptyMessage => 'Alles im Gefrierschrank hält sich noch eine Weile.';

  @override
  String get eatSoonScreenExplanation =>
      'Hier erscheint, was 60 % seiner Lagerzeit hinter sich hat. Tippe auf einen Eintrag, um etwas zu entnehmen.';

  @override
  String get digestTitle => 'Bald essen';

  @override
  String digestBodyWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte im Gefrierschrank sollten bald gegessen werden.',
      one: '1 Produkt im Gefrierschrank sollte bald gegessen werden.',
    );
    return '$_temp0';
  }

  @override
  String get productNameSeparator => ', ';

  @override
  String productNamesWithMore(String names, int count) {
    return '$names und $count weitere';
  }

  @override
  String get dailyDigestSwitch => 'Tägliche Erinnerung';

  @override
  String get dailyDigestDetail =>
      'Eine Mitteilung an den Tagen, an denen etwas bald gegessen werden sollte';

  @override
  String get digestTimeLabel => 'Uhrzeit';

  @override
  String get showNamesSwitch => 'Namen in Mitteilungen zeigen';

  @override
  String get showNamesDetail => 'Die Namen können dann auf dem Sperrbildschirm lesbar sein.';

  @override
  String get notificationsOffMessage =>
      'Mitteilungen sind für diese App ausgeschaltet, daher können keine Erinnerungen erscheinen.';

  @override
  String get allowNotificationsButton => 'Erlauben';

  @override
  String get storageLimitsRow => 'Lagerzeiten';

  @override
  String get storageLimitsDetail => 'Wie lange sich jede Kategorie im Gefrierschrank hält';

  @override
  String get storageLimitsTitle => 'Lagerzeiten';

  @override
  String get storageLimitsExplanation =>
      'Lebensmittel gelten als „bald essen“, sobald 85 % ihrer Lagerzeit vorbei sind. Ein Produkt kann im Produkteditor eine eigene Zeit haben.';

  @override
  String storageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate',
      one: '1 Monat',
    );
    return '$_temp0';
  }

  @override
  String get storageMonthsLabel => 'Höchstens aufbewahren, in Monaten';

  @override
  String storageMonthsInvalid(int maximum) {
    return 'Gib eine Zahl von 1 bis $maximum ein.';
  }
}
