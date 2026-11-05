import UIKit
import UniformTypeIdentifiers

/// Share Extension (AC-17): takes a web link or plain text shared from another
/// app and hands it to CookNote.
///
/// It does not link Flutter or any plugin. It writes the shared items in the
/// format receive_sharing_intent reads (JSON array of
/// `{path, mimeType?, type}` under `ShareKey` in the app group's
/// UserDefaults), then opens `ShareMedia-<host bundle id>:share`, which the
/// plugin in the host app picks up and forwards to Dart
/// (`ReceiveSharingIntent.instance.getInitialMedia()` / `getMediaStream()`).
@objc(ShareViewController)
final class ShareViewController: UIViewController {
  private let userDefaultsKey = "ShareKey"
  private let messageKey = "ShareMessageKey"
  private let schemePrefix = "ShareMedia"

  private struct SharedItem: Encodable {
    let path: String
    let mimeType: String?
    let type: String  // "url" or "text", as receive_sharing_intent's SharedMediaType
  }

  private var hostBundleId: String {
    // com.phiotron.cooknote.ShareExtension -> com.phiotron.cooknote
    let id = Bundle.main.bundleIdentifier ?? ""
    guard let dot = id.lastIndex(of: ".") else { return id }
    return String(id[..<dot])
  }

  private var appGroupId: String {
    Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String ?? "group.\(hostBundleId)"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task { await handleShare() }
  }

  @MainActor
  private func handleShare() async {
    let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? [])
      .flatMap { $0.attachments ?? [] }

    var items: [SharedItem] = []
    for provider in providers {
      if let url = await loadURL(provider), let scheme = url.scheme?.lowercased(),
        scheme == "https" || scheme == "http"
      {
        items.append(SharedItem(path: url.absoluteString, mimeType: nil, type: "url"))
      } else if let text = await loadText(provider),
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      {
        items.append(SharedItem(path: text, mimeType: "text/plain", type: "text"))
      }
    }

    guard !items.isEmpty, let data = try? JSONEncoder().encode(items),
      let defaults = UserDefaults(suiteName: appGroupId)
    else {
      finish()
      return
    }
    defaults.set(data, forKey: userDefaultsKey)
    defaults.removeObject(forKey: messageKey)
    openHostApp()
    finish()
  }

  private func loadURL(_ provider: NSItemProvider) async -> URL? {
    guard provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) else { return nil }
    let item = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil)
    if let url = item as? URL { return url }
    if let string = item as? String { return URL(string: string) }
    return nil
  }

  private func loadText(_ provider: NSItemProvider) async -> String? {
    guard provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) else {
      return nil
    }
    let item = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil)
    if let string = item as? String { return string }
    if let data = item as? Data { return String(data: data, encoding: .utf8) }
    return nil
  }

  /// Extensions cannot use UIApplication.shared or call `open(_:options:)`
  /// directly (unavailable in extensions). Walk the responder chain to the
  /// application object and call `openURL:options:completionHandler:` through
  /// the runtime, the same technique receive_sharing_intent uses on iOS 18+.
  private func openHostApp() {
    guard let url = NSURL(string: "\(schemePrefix)-\(hostBundleId):share") else { return }
    let selector = NSSelectorFromString("openURL:options:completionHandler:")
    typealias OpenURL = @convention(c) (AnyObject, Selector, NSURL, NSDictionary, AnyObject?) -> Void
    var responder: UIResponder? = self
    while let current = responder {
      if current is UIApplication, current.responds(to: selector) {
        let open = unsafeBitCast(current.method(for: selector), to: OpenURL.self)
        open(current, selector, url, NSDictionary(), nil)
        return
      }
      responder = current.next
    }
  }

  private func finish() {
    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }
}
