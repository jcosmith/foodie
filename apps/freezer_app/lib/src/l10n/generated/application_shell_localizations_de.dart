// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'application_shell_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ApplicationShellLocalizationsDe extends ApplicationShellLocalizations {
  ApplicationShellLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get applicationTitle => 'Gefrierschrank';

  @override
  String get navigationHome => 'Start';

  @override
  String get homeGreetingMorning => 'Guten Morgen';

  @override
  String get homeGreetingAfternoon => 'Guten Tag';

  @override
  String get homeGreetingEvening => 'Guten Abend';

  @override
  String get homeDashboardEmptyTitle => 'Dein Gefrierschrank auf einen Blick';

  @override
  String get homeDashboardEmptyMessage =>
      'Was zuerst gegessen werden sollte und was knapp wird, erscheint hier.';

  @override
  String get quickActionsMenuTitle => 'Hinzufügen';

  @override
  String get startupLoadingLabel => 'Gefrierschrank wird geöffnet';

  @override
  String get startupFailureTitle => 'Die App konnte nicht starten';

  @override
  String get startupFailureMessage =>
      'Beim Öffnen deiner Daten ist etwas schiefgegangen. Deine Daten wurden nicht verändert.';

  @override
  String get startupKeyLostTitle => 'Deine Daten können nicht entsperrt werden';

  @override
  String get startupKeyLostMessage =>
      'Der Schlüssel, der deine Gefrierschrank-Daten auf diesem Telefon schützt, fehlt, zum Beispiel nachdem der sichere Speicher des Telefons zurückgesetzt wurde. Eine Sicherung wiederherzustellen wird hier möglich sein.';

  @override
  String get notificationChannelStorageRemindersName => 'Lager-Erinnerungen';

  @override
  String get notificationChannelStorageRemindersDescription =>
      'Eine tägliche Übersicht über Produkte, die schon lange eingefroren sind';

  @override
  String get notificationChannelBackupRemindersName => 'Sicherungs-Erinnerungen';

  @override
  String get notificationChannelBackupRemindersDescription =>
      'Eine gelegentliche Erinnerung, deine Daten zu sichern';
}
