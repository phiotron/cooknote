import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: show cooking-timer alerts while the app is
    // in the foreground too (AC-28).
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Before the generated plugins: see OpenFilePlugin.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CookNoteOpenFilePlugin") {
      OpenFilePlugin.register(with: registrar)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
