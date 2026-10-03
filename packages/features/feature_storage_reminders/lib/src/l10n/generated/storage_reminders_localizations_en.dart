// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'storage_reminders_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class StorageRemindersLocalizationsEn extends StorageRemindersLocalizations {
  StorageRemindersLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get configSectionTitle => 'Reminders';

  @override
  String get eatSoonTitle => 'Eat soon';

  @override
  String get eatSoonEmpty => 'Nothing urgent. Well done!';

  @override
  String get eatSoonScreenEmptyTitle => 'Nothing to eat soon';

  @override
  String get eatSoonScreenEmptyMessage => 'Everything in your freezer keeps for a while yet.';

  @override
  String get eatSoonScreenExplanation =>
      'Food shows up here once 60 % of its storage time has passed. Tap an item to take some out.';

  @override
  String get digestTitle => 'Eat soon';

  @override
  String digestBodyWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in your freezer should be eaten soon.',
      one: '1 item in your freezer should be eaten soon.',
    );
    return '$_temp0';
  }

  @override
  String get productNameSeparator => ', ';

  @override
  String productNamesWithMore(String names, int count) {
    return '$names and $count more';
  }

  @override
  String get dailyDigestSwitch => 'Daily reminder';

  @override
  String get dailyDigestDetail => 'One notification on the days something should be eaten soon';

  @override
  String get digestTimeLabel => 'Time';

  @override
  String get showNamesSwitch => 'Show food names in notifications';

  @override
  String get showNamesDetail => 'Names may then be readable on the lock screen.';

  @override
  String get notificationsOffMessage =>
      'Notifications are switched off for this app, so reminders cannot appear.';

  @override
  String get allowNotificationsButton => 'Allow';

  @override
  String get storageLimitsRow => 'Storage limits';

  @override
  String get storageLimitsDetail => 'How long each category keeps in the freezer';

  @override
  String get storageLimitsTitle => 'Storage limits';

  @override
  String get storageLimitsExplanation =>
      'Food is marked “eat soon” once 85 % of its storage time has passed. A product can have its own time in the product editor.';

  @override
  String storageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get storageMonthsLabel => 'Keep for at most, in months';

  @override
  String storageMonthsInvalid(int maximum) {
    return 'Enter a number from 1 to $maximum.';
  }
}
