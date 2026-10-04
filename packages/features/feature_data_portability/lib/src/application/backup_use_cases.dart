import 'dart:io';
import 'dart:typed_data';

import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';
import 'package:path/path.dart' as path;

import '../domain/backup_policies.dart';
import '../domain/data_portability_failure.dart';
import 'backup_file_store.dart';
import 'data_portability_providers.dart';

/// Saves a password-encrypted backup wherever the user chooses.
final class CreateBackupUseCase {
  const CreateBackupUseCase({
    required DatabaseBackupGateway backupGateway,
    required BackupFileAccess pictureFiles,
    required BackupFileStore fileStore,
    required PreferencesStore preferencesStore,
    required Clock clock,
    required String applicationVersion,
  }) : _backupGateway = backupGateway,
       _pictureFiles = pictureFiles,
       _fileStore = fileStore,
       _preferencesStore = preferencesStore,
       _clock = clock,
       _applicationVersion = applicationVersion;

  static const String fileExtension = 'foodiebackup';

  final DatabaseBackupGateway _backupGateway;
  final BackupFileAccess _pictureFiles;
  final BackupFileStore _fileStore;
  final PreferencesStore _preferencesStore;
  final Clock _clock;
  final String _applicationVersion;

  /// How many pictures [execute] would include; the save dialog offers to
  /// leave them out when there are any.
  Future<int> countPictures() => _backupGateway.countPicturesForBackup();

  /// Returns whether the backup was saved (`false` when the user cancelled
  /// the save dialog). Without pictures, the file is much smaller (about
  /// 300 KB per photo, section 10.2).
  Future<Result<bool, DataPortabilityFailure>> execute({
    required String password,
    required String repeatedPassword,
    bool includesPictures = true,
  }) async {
    final preparation = await prepare(
      password: password,
      repeatedPassword: repeatedPassword,
      includesPictures: includesPictures,
    );
    return switch (preparation) {
      SuccessfulResult(value: final backup) => save(backup),
      FailedResult(:final failure) => Result.failure(failure),
    };
  }

  /// Builds the encrypted backup file; [save] then hands it to the save
  /// dialog. Two steps, so the app shows its progress while the file is
  /// built but not while the system's dialog is open (issue #4).
  Future<Result<PreparedBackup, DataPortabilityFailure>> prepare({
    required String password,
    required String repeatedPassword,
    bool includesPictures = true,
  }) async {
    final passwordProblem = BackupPasswordPolicy.check(
      password: password,
      repeatedPassword: repeatedPassword,
    );
    if (passwordProblem != null) return Result.failure(passwordProblem);

    final createdAt = _clock.nowUtc();
    final fileName =
        'foodie-backup-${CalendarDate.fromDateTime(_clock.nowLocal()).toIso8601String()}'
        '.$fileExtension';
    final scratchDirectory = await _fileStore.createScratchDirectory();
    try {
      final snapshotPath = path.join(scratchDirectory.path, fileName);
      await _backupGateway.exportEncryptedSnapshot(
        destinationPath: snapshotPath,
        password: password,
        applicationVersion: _applicationVersion,
        createdAt: createdAt,
        pictureFiles: includesPictures ? _pictureFiles : null,
      );
      return Result.success(
        PreparedBackup._(
          fileName: fileName,
          bytes: await File(snapshotPath).readAsBytes(),
          createdAt: createdAt,
        ),
      );
    } finally {
      await scratchDirectory.delete(recursive: true);
    }
  }

  /// Opens the save dialog and returns whether the backup was saved. An
  /// error of the dialog is a [BackupNotSaved] failure.
  Future<Result<bool, DataPortabilityFailure>> save(PreparedBackup backup) async {
    final bool isSaved;
    try {
      isSaved = await _fileStore.saveFile(
        fileName: backup.fileName,
        bytes: backup.bytes,
        mimeType: 'application/octet-stream',
      );
    } on Exception {
      return const Result.failure(BackupNotSaved());
    }
    if (isSaved) {
      await _preferencesStore.write(DataPortabilityPreferenceKeys.lastBackupAt, backup.createdAt);
    }
    return Result.success(isSaved);
  }
}

/// A backup file built by [CreateBackupUseCase.prepare], not saved yet.
final class PreparedBackup {
  const PreparedBackup._({required this.fileName, required this.bytes, required this.createdAt});

  final String fileName;
  final Uint8List bytes;
  final DateTime createdAt;
}

/// Replaces everything in the app with the contents of a backup.
final class RestoreBackupUseCase {
  const RestoreBackupUseCase({
    required DatabaseBackupGateway backupGateway,
    required BackupFileAccess pictureFiles,
    required ApplicationRestarter applicationRestarter,
  }) : _backupGateway = backupGateway,
       _pictureFiles = pictureFiles,
       _applicationRestarter = applicationRestarter;

  final DatabaseBackupGateway _backupGateway;
  final BackupFileAccess _pictureFiles;
  final ApplicationRestarter _applicationRestarter;

  /// Checks the password and the file, and tells when the backup was made,
  /// so the user can confirm before anything changes.
  Future<Result<BackupManifest, DataPortabilityFailure>> inspect({
    required String backupPath,
    required String password,
  }) async =>
      _translate(await _backupGateway.inspectBackup(backupPath: backupPath, password: password));

  /// Prepares the restore and restarts the app, which moves it in place.
  /// The backup's pictures are written first; the start-up sweep then
  /// removes the pictures of the data that was replaced.
  Future<Result<BackupManifest, DataPortabilityFailure>> restore({
    required String backupPath,
    required String password,
  }) async {
    final result = _translate(
      await _backupGateway.prepareRestore(
        backupPath: backupPath,
        password: password,
        pictureFiles: _pictureFiles,
      ),
    );
    if (result.isSuccess) await _applicationRestarter.restart();
    return result;
  }

  static Result<BackupManifest, DataPortabilityFailure> _translate(
    Result<BackupManifest, BackupFileFailure> result,
  ) => switch (result) {
    SuccessfulResult(:final value) => Result.success(value),
    FailedResult(failure: WrongPasswordOrUnreadableFile()) => const Result.failure(
      BackupNotReadable(),
    ),
    FailedResult(failure: NotAFoodieBackup()) => const Result.failure(NotABackupOfThisApp()),
    FailedResult(failure: BackupFromNewerVersion(:final manifest)) => Result.failure(
      BackupNeedsNewerApp(manifest.applicationVersion),
    ),
  };
}
