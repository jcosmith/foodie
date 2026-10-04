import 'dart:io';

import 'package:core_database/core_database.dart';
import 'package:core_database/testing.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:feature_onboarding/feature_onboarding.dart';
import 'package:foodie_app/src/startup/application_platform_services.dart';

/// Platform services for widget tests: an in-memory database, picture store
/// and fake notifications.
final class InMemoryPlatformServices implements ApplicationPlatformServices {
  InMemoryPlatformServices({
    this.databaseOpeningError,
    this.isOnboardingCompleted = true,
    this.perAppLanguageCode,
    this.databaseDirectory,
  });

  final Object? databaseOpeningError;

  /// When set, the database is an encrypted file in this folder, as on a
  /// phone, and keeps its data across restarts; restoring a backup needs
  /// one.
  final Directory? databaseDirectory;
  final DatabaseEncryptionKeyStore _databaseKeyStore = InMemoryDatabaseEncryptionKeyStore();

  /// Most tests start on Home; onboarding tests start fresh.
  final bool isOnboardingCompleted;

  /// What the system's per-app language setting holds; `null` where the
  /// platform has none.
  String? perAppLanguageCode;
  final FakeNotificationServices notificationServices = FakeNotificationServices();

  @override
  Future<ApplicationDatabase> openDatabase({
    required Clock clock,
    required String applicationVersion,
  }) async {
    final error = databaseOpeningError;
    if (error != null) throw error;
    final directory = databaseDirectory;
    final database = directory == null
        ? createInMemoryApplicationDatabase(clock: clock)
        : await EncryptedDatabaseOpener(
            keyStore: _databaseKeyStore,
            clock: clock,
            applicationVersion: applicationVersion,
            privateDirectoryProvider: () async => directory,
          ).open();
    if (isOnboardingCompleted &&
        await database.preferencesDao.readEncodedValue(
              OnboardingPreferenceKeys.isCompleted.storageKey,
            ) ==
            null) {
      await database.preferencesDao.writeEncodedValue(
        preferenceKey: OnboardingPreferenceKeys.isCompleted.storageKey,
        encodedValue: 'true',
        updatedAt: clock.nowUtc(),
      );
    }
    return database;
  }

  /// Picture files of this run, unencrypted.
  final InMemoryMediaFileStore mediaFileStore = InMemoryMediaFileStore();

  @override
  MediaFileStore createMediaFileStore() => mediaFileStore;

  /// Receipt page images of this run, unencrypted.
  final InMemoryMediaFileStore receiptMediaFileStore = InMemoryMediaFileStore();

  @override
  MediaFileStore createReceiptMediaFileStore() => receiptMediaFileStore;

  @override
  Future<String?> readPerAppLanguageCode() async => perAppLanguageCode;

  @override
  Future<void> writePerAppLanguageCode(String languageCode) async {
    if (perAppLanguageCode != null) perAppLanguageCode = languageCode;
  }

  @override
  Future<NotificationServices> initializeNotificationServices(
    NotificationChannelTexts channelTexts,
  ) async => (
    scheduler: notificationServices,
    permissionService: notificationServices,
    tapRouter: notificationServices,
  );
}
