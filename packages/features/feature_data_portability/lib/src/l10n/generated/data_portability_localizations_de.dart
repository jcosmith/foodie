// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'data_portability_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class DataPortabilityLocalizationsDe extends DataPortabilityLocalizations {
  DataPortabilityLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get configSectionTitle => 'Sicherung und Export';

  @override
  String lastBackup(String date) {
    return 'Letzte Sicherung $date';
  }

  @override
  String get noBackupYet => 'Noch keine Sicherung';

  @override
  String get backupExplanation =>
      'Deine Daten gibt es nur auf diesem Telefon. Eine Sicherung ist eine passwortgeschützte Datei, die du an einem sicheren Ort aufbewahrst, zum Beispiel auf einem Computer oder in deinem eigenen Cloud-Speicher.';

  @override
  String get saveBackupButton => 'Sicherung speichern';

  @override
  String get restoreBackupButton => 'Sicherung wiederherstellen';

  @override
  String get exportContentsButton => 'Inhalt als CSV exportieren';

  @override
  String get exportHistoryButton => 'Verlauf als CSV exportieren';

  @override
  String get passwordDialogTitle => 'Sicherung schützen';

  @override
  String passwordDialogMessage(int count) {
    return 'Wähle ein Passwort mit mindestens $count Zeichen. Ohne das Passwort kann niemand die Sicherung öffnen, und es lässt sich nicht wiederherstellen.';
  }

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get repeatPasswordLabel => 'Passwort wiederholen';

  @override
  String passwordTooShort(int count) {
    return 'Mindestens $count Zeichen.';
  }

  @override
  String get passwordsDoNotMatch => 'Die Passwörter sind verschieden.';

  @override
  String get backupSaved => 'Sicherung gespeichert';

  @override
  String get backupNotSaved => 'Die Sicherung konnte nicht gespeichert werden.';

  @override
  String get workingOnBackup => 'Sicherung wird bearbeitet …';

  @override
  String get restorePasswordTitle => 'Sicherung öffnen';

  @override
  String get restorePasswordMessage =>
      'Gib das Passwort ein, das du beim Speichern dieser Sicherung gewählt hast.';

  @override
  String get openButton => 'Öffnen';

  @override
  String get backupNotReadable =>
      'Diese Datei lässt sich mit dem Passwort nicht öffnen. Prüfe das Passwort und ob die Datei eine Sicherung dieser App ist.';

  @override
  String get notABackupOfThisApp => 'Diese Datei ist keine Sicherung dieser App.';

  @override
  String backupNeedsNewerApp(String version) {
    return 'Diese Sicherung stammt von einer neueren Version der App ($version). Bitte aktualisiere die App zuerst.';
  }

  @override
  String get confirmRestoreTitle => 'Alles ersetzen?';

  @override
  String confirmRestoreMessage(String date) {
    return 'Die Sicherung vom $date ersetzt alles, was jetzt in der App ist. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get restoreButton => 'Wiederherstellen';

  @override
  String get fileSaved => 'Datei gespeichert';

  @override
  String get reminderCardTitle => 'Zeit für eine Sicherung';

  @override
  String get reminderCardMessage =>
      'Deine Foodie-Daten sind nur auf diesem Telefon. Speichere eine Sicherung, damit ein verlorenes oder kaputtes Telefon sie nicht mitnimmt.';

  @override
  String get csvColumnProduct => 'Produkt';

  @override
  String get csvColumnCategory => 'Kategorie';

  @override
  String get csvColumnAmount => 'Menge';

  @override
  String get csvColumnUnit => 'Einheit';

  @override
  String get csvColumnStoredOn => 'Eingelagert am';

  @override
  String get csvColumnDrawer => 'Fach';

  @override
  String get csvColumnNote => 'Notiz';

  @override
  String get csvColumnTime => 'Zeit';

  @override
  String get csvColumnChange => 'Änderung';

  @override
  String get csvColumnReason => 'Grund';

  @override
  String get movementAdded => 'Eingelagert';

  @override
  String get movementConsumed => 'Entnommen';

  @override
  String get movementDiscarded => 'Weggeworfen';

  @override
  String get movementMoved => 'Umgelagert';

  @override
  String get movementCorrected => 'Korrigiert';

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
  String get backupNotificationTitle => 'Zeit für eine Sicherung';

  @override
  String get backupNotificationBody =>
      'Alles in dieser App gibt es nur auf diesem Telefon. Speichere eine Sicherung, damit ein verlorenes Telefon deine Listen nicht mitnimmt.';

  @override
  String get includePicturesLabel => 'Fotos einschließen';

  @override
  String includePicturesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos, je etwa 300 KB. Ohne wird die Datei kleiner.',
      one: '1 Foto, etwa 300 KB. Ohne wird die Datei kleiner.',
    );
    return '$_temp0';
  }

  @override
  String restoreIncludesPictures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sie enthält $count Fotos.',
      one: 'Sie enthält 1 Foto.',
      zero: 'Sie enthält keine Fotos.',
    );
    return '$_temp0';
  }
}
