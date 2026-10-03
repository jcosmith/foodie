// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'data_portability_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class DataPortabilityLocalizationsEn extends DataPortabilityLocalizations {
  DataPortabilityLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get configSectionTitle => 'Backup and export';

  @override
  String lastBackup(String date) {
    return 'Last backup $date';
  }

  @override
  String get noBackupYet => 'No backup yet';

  @override
  String get backupExplanation =>
      'Your data exists only on this phone. A backup is a password-protected file that you keep somewhere safe, for example on a computer or in your own cloud storage.';

  @override
  String get saveBackupButton => 'Save backup';

  @override
  String get restoreBackupButton => 'Restore backup';

  @override
  String get exportContentsButton => 'Export contents as CSV';

  @override
  String get exportHistoryButton => 'Export history as CSV';

  @override
  String get passwordDialogTitle => 'Protect your backup';

  @override
  String passwordDialogMessage(int count) {
    return 'Choose a password of at least $count characters. Nobody can open the backup without it, and it cannot be recovered.';
  }

  @override
  String get passwordLabel => 'Password';

  @override
  String get repeatPasswordLabel => 'Repeat password';

  @override
  String passwordTooShort(int count) {
    return 'At least $count characters.';
  }

  @override
  String get passwordsDoNotMatch => 'The passwords are different.';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get workingOnBackup => 'Working on your backup…';

  @override
  String get restorePasswordTitle => 'Open backup';

  @override
  String get restorePasswordMessage => 'Enter the password you chose when you saved this backup.';

  @override
  String get openButton => 'Open';

  @override
  String get backupNotReadable =>
      'This file cannot be opened with that password. Check the password, and that the file is a backup of this app.';

  @override
  String get notABackupOfThisApp => 'This file is not a backup of this app.';

  @override
  String backupNeedsNewerApp(String version) {
    return 'This backup was made with a newer version of the app ($version). Please update the app first.';
  }

  @override
  String get confirmRestoreTitle => 'Replace everything?';

  @override
  String confirmRestoreMessage(String date) {
    return 'The backup from $date replaces everything that is in the app now. This cannot be undone.';
  }

  @override
  String get restoreButton => 'Restore';

  @override
  String get fileSaved => 'File saved';

  @override
  String get reminderCardTitle => 'Time for a backup';

  @override
  String get reminderCardMessage =>
      'Your freezer data is only on this phone. Save a backup so that a lost or broken phone does not take it with it.';

  @override
  String get csvColumnProduct => 'Product';

  @override
  String get csvColumnCategory => 'Category';

  @override
  String get csvColumnAmount => 'Amount';

  @override
  String get csvColumnUnit => 'Unit';

  @override
  String get csvColumnFrozenOn => 'Frozen on';

  @override
  String get csvColumnDrawer => 'Drawer';

  @override
  String get csvColumnNote => 'Note';

  @override
  String get csvColumnTime => 'Time';

  @override
  String get csvColumnChange => 'Change';

  @override
  String get csvColumnReason => 'Reason';

  @override
  String get movementAdded => 'Added';

  @override
  String get movementConsumed => 'Taken';

  @override
  String get movementDiscarded => 'Thrown away';

  @override
  String get movementMoved => 'Moved';

  @override
  String get movementCorrected => 'Corrected';

  @override
  String get reasonTooOld => 'Stored too long';

  @override
  String get reasonFreezerBurn => 'Freezer burn';

  @override
  String get reasonUnwanted => 'Nobody wanted it';

  @override
  String get reasonOther => 'Other';

  @override
  String get backupNotificationTitle => 'Time for a backup';

  @override
  String get backupNotificationBody =>
      'Everything in this app exists only on this phone. Save a backup so that a lost phone does not take your freezer list with it.';

  @override
  String get includePicturesLabel => 'Include photos';

  @override
  String includePicturesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos, about 300 KB each. Leave them out for a smaller file.',
      one: '1 photo, about 300 KB. Leave it out for a smaller file.',
    );
    return '$_temp0';
  }

  @override
  String restoreIncludesPictures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It contains $count photos.',
      one: 'It contains 1 photo.',
      zero: 'It contains no photos.',
    );
    return '$_temp0';
  }
}
