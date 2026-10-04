import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludePrivateDataFromDeviceBackups()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// The encrypted database and picture files live in Application Support.
  /// iCloud device backups would copy that folder off the phone by default,
  /// so it is excluded on every launch before Flutter starts (architecture
  /// document, section 11). Data only leaves the device through the app's own
  /// encrypted backup export.
  private func excludePrivateDataFromDeviceBackups() {
    let fileManager = FileManager.default
    guard
      var applicationSupportDirectory = fileManager.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
      ).first
    else { return }
    do {
      try fileManager.createDirectory(
        at: applicationSupportDirectory, withIntermediateDirectories: true)
      var resourceValues = URLResourceValues()
      resourceValues.isExcludedFromBackup = true
      try applicationSupportDirectory.setResourceValues(resourceValues)
    } catch {
      NSLog("Could not exclude Application Support from backups: \(error)")
    }
  }
}
