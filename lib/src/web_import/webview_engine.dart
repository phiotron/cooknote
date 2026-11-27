import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'browser_engine.dart';

/// Xóa cookie, bộ nhớ đệm và bộ nhớ cục bộ của WebView (AC-64, D-010).
/// Dùng khi người dùng xóa toàn bộ dữ liệu: lần mở sau không còn đăng nhập
/// hay cookie của trang nào.
Future<void> clearBrowserData() async {
  final controller = WebViewController();
  await controller.clearCache();
  await controller.clearLocalStorage();
  await WebViewCookieManager().clearCookies();
}

/// Trình duyệt thật dựa trên webview_flutter (Android WebView). KHÔNG test
/// được bằng `flutter test`: CHƯA kiểm chứng trên máy thật.
class WebViewEngine implements BrowserEngine {
  WebViewEngine() {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Chỉ http(s); chặn intent://, market://... mở app khác.
          onNavigationRequest: (request) {
            final s = Uri.tryParse(request.url)?.scheme ?? '';
            return s == 'http' || s == 'https' || s == 'about'
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onPageStarted: (url) {
            final u = Uri.tryParse(url);
            _mainFrame = u;
            _events?.onPageStarted(u);
          },
          onPageFinished: (url) => _events?.onPageFinished(Uri.tryParse(url)),
          onUrlChange: (change) {
            final u = Uri.tryParse(change.url ?? '');
            if (u != null) _events?.onUrlChanged(u);
          },
          onWebResourceError: (error) {
            // Tài nguyên con (ảnh, quảng cáo, favicon...) lỗi không có nghĩa
            // là cả trang lỗi. Android điền `isForMainFrame`; iOS không điền
            // nên phải so địa chỉ lỗi với địa chỉ trang chính.
            if (!isMainFrameFailure(
              pageUrl: _mainFrame,
              failedUrl: error.url == null ? null : Uri.tryParse(error.url!),
              isForMainFrame: error.isForMainFrame,
            )) {
              return;
            }
            _events?.onFailure(LoadFailure(_kind(error)));
          },
          onHttpError: (error) {
            final code = error.response?.statusCode;
            if (code == null || code < 400) return;
            if (!isMainFrameFailure(
              pageUrl: _mainFrame,
              failedUrl: error.request?.uri,
              isForMainFrame: null,
            )) {
              return;
            }
            _events?.onFailure(
              LoadFailure(LoadFailureKind.http, httpCode: code),
            );
          },
        ),
      );
  }

  final WebViewController _controller = WebViewController();
  BrowserEvents? _events;

  /// Địa chỉ trang chính đang tải (cập nhật ở `onPageStarted`/`load`).
  Uri? _mainFrame;

  // Mã lỗi Android WebViewClient: -2 HOST_LOOKUP, -6 CONNECT, -7 IO, -8 TIMEOUT.
  static LoadFailureKind _kind(WebResourceError e) {
    switch (e.errorType) {
      case WebResourceErrorType.hostLookup:
      case WebResourceErrorType.connect:
      case WebResourceErrorType.io:
        return LoadFailureKind.network;
      case WebResourceErrorType.timeout:
        return LoadFailureKind.timeout;
      default:
        return LoadFailureKind.other;
    }
  }

  @override
  void attach(BrowserEvents events) => _events = events;

  @override
  Future<void> load(Uri url) {
    _mainFrame = url;
    return _controller.loadRequest(url);
  }

  @override
  Future<void> reload() => _controller.reload();

  @override
  Future<void> goBack() => _controller.goBack();

  @override
  Future<void> goForward() => _controller.goForward();

  @override
  Future<bool> canGoBack() => _controller.canGoBack();

  @override
  Future<bool> canGoForward() => _controller.canGoForward();

  @override
  Future<Uri?> currentUrl() async {
    final u = await _controller.currentUrl();
    return u == null ? null : Uri.tryParse(u);
  }

  @override
  Future<String?> title() => _controller.getTitle();

  /// Android trả chuỗi JavaScript đã mã hóa JSON (có ngoặc kép); iOS trả chuỗi
  /// thô. Hàm này chấp nhận cả hai.
  static String decodeJsString(Object result) {
    final s = result.toString();
    if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
      try {
        final v = jsonDecode(s);
        if (v is String) return v;
      } catch (_) {
        // Rơi xuống trả chuỗi thô.
      }
    }
    return s == 'null' ? '' : s;
  }

  @override
  Future<String> outerHtml() async => decodeJsString(
    await _controller.runJavaScriptReturningResult(
      'document.documentElement.outerHTML',
    ),
  );

  @override
  Future<String> selectedText() async => decodeJsString(
    await _controller.runJavaScriptReturningResult(
      'window.getSelection().toString()',
    ),
  );

  @override
  Widget buildView(BuildContext context) =>
      WebViewWidget(controller: _controller);

  @override
  void dispose() {}
}
