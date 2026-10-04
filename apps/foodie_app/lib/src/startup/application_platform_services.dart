import 'package:core_database/core_database.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_media_storage/core_media_storage.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:flutter/services.dart';

/// The notification services the shell hands to modules.
typedef NotificationServices = ({
  NotificationScheduler scheduler,
  NotificationPermissionService permissionService,
  NotificationTapRouter tapRouter,
});

/// Everything the shell needs from the device at start-up. Production uses
/// [DevicePlatformServices]; widget tests substitute in-memory versions.
abstract interface class ApplicationPlatformServices {
  Future<ApplicationDatabase> openDatabase({
    required Clock clock,
    required String applicationVersion,
  });

  Future<NotificationServices> initializeNotificationServices(
    NotificationChannelTexts channelTexts,
  );

  /// The encrypted store for picture files, next to the database.
  MediaFileStore createMediaFileStore();

  /// The encrypted store for receipt page images, in a folder of its own.
  MediaFileStore createReceiptMediaFileStore();

  /// The language chosen for this app in the system settings (Android 13
  /// and later): a language code, empty when none is set, or `null` where
  /// the platform has no such setting the app can read.
  Future<String?> readPerAppLanguageCode();

  /// Mirrors the in-app language choice into the system settings, so both
  /// places show the same choice (decision D14). Empty means "follow the
  /// phone".
  Future<void> writePerAppLanguageCode(String languageCode);
}

final class DevicePlatformServices implements ApplicationPlatformServices {
  const DevicePlatformServices();

  @override
  Future<ApplicationDatabase> openDatabase({
    required Clock clock,
    required String applicationVersion,
  }) => EncryptedDatabaseOpener(
    keyStore: SecureStorageDatabaseEncryptionKeyStore(),
    clock: clock,
    applicationVersion: applicationVersion,
  ).open();

  /// Shared by both picture stores, so a first start creates one key only.
  static final MediaEncryptionKeyStore _mediaKeyStore = SecureStorageMediaEncryptionKeyStore();

  @override
  MediaFileStore createMediaFileStore() =>
      EncryptedDirectoryMediaFileStore(keyStore: _mediaKeyStore);

  @override
  MediaFileStore createReceiptMediaFileStore() => EncryptedDirectoryMediaFileStore(
    keyStore: _mediaKeyStore,
    folderName: EncryptedDirectoryMediaFileStore.receiptFolderName,
  );

  @override
  Future<NotificationServices> initializeNotificationServices(
    NotificationChannelTexts channelTexts,
  ) async {
    final gateway = LocalNotificationsGateway();
    await gateway.initialize(channelTexts: channelTexts);
    return (scheduler: gateway, permissionService: gateway, tapRouter: gateway);
  }

  /// Implemented in MainActivity.kt with Android's LocaleManager. iOS needs
  /// nothing: its per-app language setting restarts the app in that
  /// language, which Flutter reports as the phone's locale.
  static const MethodChannel _applicationLanguageChannel = MethodChannel(
    'io.github.jcosmith.foodie/application_language',
  );

  @override
  Future<String?> readPerAppLanguageCode() async {
    try {
      return await _applicationLanguageChannel.invokeMethod<String>('readApplicationLanguage');
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<void> writePerAppLanguageCode(String languageCode) async {
    try {
      await _applicationLanguageChannel.invokeMethod<void>('writeApplicationLanguage', {
        'languageCode': languageCode,
      });
    } on MissingPluginException {
      // Not available on this platform or Android version.
    }
  }
}
