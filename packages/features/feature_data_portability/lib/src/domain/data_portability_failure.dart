import 'package:core_foundation/core_foundation.dart';

sealed class DataPortabilityFailure extends Failure {
  const DataPortabilityFailure();
}

final class BackupPasswordTooShort extends DataPortabilityFailure {
  const BackupPasswordTooShort();

  @override
  String get debugDescription => 'The backup password is too short';
}

final class BackupPasswordsDoNotMatch extends DataPortabilityFailure {
  const BackupPasswordsDoNotMatch();

  @override
  String get debugDescription => 'The repeated password differs';
}

/// The save dialog failed, for example because no app can store files.
final class BackupNotSaved extends DataPortabilityFailure {
  const BackupNotSaved();

  @override
  String get debugDescription => 'The save dialog reported an error';
}

/// Wrong password, or a file that is not an encrypted backup at all.
final class BackupNotReadable extends DataPortabilityFailure {
  const BackupNotReadable();

  @override
  String get debugDescription => 'The backup cannot be opened with this password';
}

final class NotABackupOfThisApp extends DataPortabilityFailure {
  const NotABackupOfThisApp();

  @override
  String get debugDescription => 'The file is an encrypted database, but not a freezer backup';
}

/// Made by a newer app version; restoring would lose data it knows about.
final class BackupNeedsNewerApp extends DataPortabilityFailure {
  const BackupNeedsNewerApp(this.applicationVersion);

  final String applicationVersion;

  @override
  String get debugDescription => 'Backup from app version $applicationVersion';
}
