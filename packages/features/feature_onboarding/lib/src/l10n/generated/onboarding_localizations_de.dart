// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'onboarding_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class OnboardingLocalizationsDe extends OnboardingLocalizations {
  OnboardingLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String stepOfSteps(int step, int stepCount) {
    return 'Schritt $step von $stepCount';
  }

  @override
  String get welcomeTitle => 'Willkommen';

  @override
  String get welcomeMessage =>
      'Behalte im Blick, was in Tiefkühler, Kühlschrank und Vorrat ist, verbrauche es, bevor es verdirbt, und wisse, was du kaufen musst.';

  @override
  String get chooseLanguagePrompt => 'In welcher Sprache soll die App sein?';

  @override
  String get continueButton => 'Weiter';

  @override
  String get backButton => 'Zurück';

  @override
  String get storagePlaceTitle => 'Dein Gefrierschrank';

  @override
  String get storagePlacePrompt =>
      'Welcher kommt deinem am nächsten? Fächer kannst du später in den Optionen umbenennen, hinzufügen und entfernen.';

  @override
  String get privacyTitle => 'Deine Daten bleiben hier';

  @override
  String get privacyMessage =>
      'Die App hat keinen Internetzugang und kein Konto. Alles, was du eingibst, bleibt verschlüsselt auf diesem Telefon.';

  @override
  String get backupHint =>
      'Weil nichts online gespeichert wird, sichere ab und zu deine Daten. Die App erinnert dich daran.';

  @override
  String get remindersTitle => 'Erinnerungen';

  @override
  String get remindersMessage =>
      'Erlaube Mitteilungen, damit dir die App einmal am Tag sagt, was bald verbraucht werden sollte. Produktnamen bleiben auf dem Sperrbildschirm verborgen.';

  @override
  String get allowNotificationsButton => 'Mitteilungen erlauben';

  @override
  String get notNowButton => 'Jetzt nicht';

  @override
  String get startButton => 'Los geht\'s';
}
