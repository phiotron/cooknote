import Flutter
import UIKit

/// Delivers `.cooknote` files that the user opens with CookNote (Files app,
/// Mail, AirDrop, "Open in…") to Dart. iOS copies such a file into
/// `Documents/Inbox/` before handing over its URL (Info.plist sets
/// `LSSupportsOpeningDocumentsInPlace` to false); Dart should delete the copy
/// after importing it.
///
/// Channel `com.phiotron.cooknote/open_file`:
/// - Dart → iOS `getInitialFile`: path of the file the app was launched with,
///   or null. Cleared after the first read.
/// - iOS → Dart `fileOpened(path)`: a file opened while the app is running.
///
/// Registered before the generated plugins (AppDelegate) so it sees the scene
/// connection before receive_sharing_intent, which claims every cold start.
/// It never claims a URL that is not a file, so share-extension URLs still
/// reach receive_sharing_intent.
final class OpenFilePlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  static let channelName = "com.phiotron.cooknote/open_file"

  private var channel: FlutterMethodChannel?
  private var initialPath: String?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = OpenFilePlugin()
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addSceneDelegate(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInitialFile":
      result(initialPath)
      initialPath = nil
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Cold start: remember the file, let the other plugins see the connection too.
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    if let url = connectionOptions?.urlContexts.first(where: { $0.url.isFileURL })?.url {
      initialPath = url.path
    }
    return false
  }

  // Warm start: claim only file URLs.
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let url = URLContexts.first(where: { $0.url.isFileURL })?.url else {
      return false
    }
    if let channel = channel {
      channel.invokeMethod("fileOpened", arguments: url.path)
    } else {
      initialPath = url.path
    }
    return true
  }
}
