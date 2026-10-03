// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'application_shell_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ApplicationShellLocalizationsEn extends ApplicationShellLocalizations {
  ApplicationShellLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get applicationTitle => 'Freezer';

  @override
  String get navigationHome => 'Home';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeDashboardEmptyTitle => 'Your freezer at a glance';

  @override
  String get homeDashboardEmptyMessage =>
      'What to eat first and what is running low will appear here.';

  @override
  String get quickActionsMenuTitle => 'Add';

  @override
  String get startupLoadingLabel => 'Opening your freezer';

  @override
  String get startupFailureTitle => 'The app could not start';

  @override
  String get startupFailureMessage =>
      'Something went wrong while opening your data. Your data has not been changed.';

  @override
  String get startupKeyLostTitle => 'Your data cannot be unlocked';

  @override
  String get startupKeyLostMessage =>
      'The key that protects your freezer data on this phone is gone, for example after the phone\'s secure storage was reset. Restoring a backup will be possible from here.';

  @override
  String get notificationChannelStorageRemindersName => 'Storage reminders';

  @override
  String get notificationChannelStorageRemindersDescription =>
      'A daily summary of items that have been in the freezer for a long time';

  @override
  String get notificationChannelBackupRemindersName => 'Backup reminders';

  @override
  String get notificationChannelBackupRemindersDescription =>
      'An occasional reminder to save a backup of your data';
}
