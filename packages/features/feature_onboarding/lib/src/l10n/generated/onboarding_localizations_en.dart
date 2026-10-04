// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'onboarding_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class OnboardingLocalizationsEn extends OnboardingLocalizations {
  OnboardingLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String stepOfSteps(int step, int stepCount) {
    return 'Step $step of $stepCount';
  }

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeMessage =>
      'Keep track of what is in your freezer, fridge and pantry, use things before they go off, and know what to buy.';

  @override
  String get chooseLanguagePrompt => 'Which language should the app use?';

  @override
  String get continueButton => 'Continue';

  @override
  String get backButton => 'Back';

  @override
  String get storagePlaceTitle => 'Your freezer';

  @override
  String get storagePlacePrompt =>
      'Which one is closest to yours? You can rename, add and remove compartments later in Options.';

  @override
  String get privacyTitle => 'Your data stays here';

  @override
  String get privacyMessage =>
      'The app has no internet access and no account. Everything you enter stays on this phone, encrypted.';

  @override
  String get backupHint =>
      'Because nothing is stored online, save a backup now and then. The app will remind you.';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersMessage =>
      'Allow notifications so the app can tell you once a day what should be used soon. Item names stay hidden on the lock screen.';

  @override
  String get allowNotificationsButton => 'Allow notifications';

  @override
  String get notNowButton => 'Not now';

  @override
  String get startButton => 'Start';
}
