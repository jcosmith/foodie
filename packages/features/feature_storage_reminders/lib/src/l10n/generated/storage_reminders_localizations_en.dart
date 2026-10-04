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
  String get eatSoonTitle => 'Use soon';

  @override
  String get eatSoonEmpty => 'Nothing urgent. Well done!';

  @override
  String get eatSoonScreenEmptyTitle => 'Nothing to use soon';

  @override
  String get eatSoonScreenEmptyMessage => 'Everything at home keeps for a while yet.';

  @override
  String get eatSoonScreenExplanation =>
      'Food shows up here once 60 % of its storage time has passed. Tap an item to take some out.';

  @override
  String get digestTitle => 'Use soon';

  @override
  String digestBodyWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items should be used soon.',
      one: '1 item should be used soon.',
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
  String get dailyDigestDetail => 'One notification on the days something should be used soon';

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
  String get storageLimitsDetail => 'How long each category keeps';

  @override
  String get storageLimitsTitle => 'Storage limits';

  @override
  String get storageLimitsExplanation =>
      'Things are marked “use soon” once 85 % of their storage time has passed. A product can have its own time in the product editor.';

  @override
  String get shelfLifeLabel => 'Keeps for';
}
