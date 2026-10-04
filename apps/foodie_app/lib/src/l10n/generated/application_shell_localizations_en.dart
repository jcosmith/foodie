// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'application_shell_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ApplicationShellLocalizationsEn extends ApplicationShellLocalizations {
  ApplicationShellLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get applicationTitle => 'Foodie';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationLists => 'Lists';

  @override
  String get navigationMore => 'More';

  @override
  String get listsTitle => 'Lists';

  @override
  String get moreTitle => 'More';

  @override
  String get privacyPromise => 'Your data never leaves this phone.';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeDashboardEmptyTitle => 'Your household at a glance';

  @override
  String get homeDashboardEmptyMessage =>
      'What to use first and what is running low will appear here.';

  @override
  String get quickActionsMenuTitle => 'Add';

  @override
  String get startupLoadingLabel => 'Opening Foodie';

  @override
  String get startupFailureTitle => 'The app could not start';

  @override
  String get startupFailureMessage =>
      'Something went wrong while opening your data. Your data has not been changed.';

  @override
  String get startupKeyLostTitle => 'Your data cannot be unlocked';

  @override
  String get startupKeyLostMessage =>
      'The key that protects your Foodie data on this phone is gone, for example after the phone\'s secure storage was reset. Restoring a backup will be possible from here.';

  @override
  String get notificationChannelStorageRemindersName => 'Storage reminders';

  @override
  String get notificationChannelStorageRemindersDescription =>
      'A daily summary of items to use soon';

  @override
  String get notificationChannelBackupRemindersName => 'Backup reminders';

  @override
  String get notificationChannelBackupRemindersDescription =>
      'An occasional reminder to save a backup of your data';
}
