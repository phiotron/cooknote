import 'package:flutter/widgets.dart';

enum LoadFailureKind {
  /// Mất mạng, không phân giải được tên miền hoặc không kết nối được.
  network,

  /// Quá thời gian chờ (AC-21).
  timeout,

  /// Máy chủ trả mã lỗi HTTP.
  http,

  /// Lỗi trang khác (SSL, địa chỉ sai...) hoặc không đọc được nội dung trang.
  other,
}

/// Lý do một lần tải trang thất bại (AC-21).
class LoadFailure {
  const LoadFailure(this.kind, {this.httpCode});

  final LoadFailureKind kind;
  final int? httpCode;

  @override
  bool operator ==(Object other) =>
      other is LoadFailure && other.kind == kind && other.httpCode == httpCode;

  @override
  int get hashCode => Object.hash(kind, httpCode);

  @override
  String toString() => 'LoadFailure($kind, $httpCode)';
}

/// Sự kiện từ trình duyệt thật gửi lên `BrowserSession`.
abstract class BrowserEvents {
  void onPageStarted(Uri? url);
  void onPageFinished(Uri? url);
  void onFailure(LoadFailure failure);
  void onUrlChanged(Uri url);
}

/// Cầu nối tới WebView thật, tách riêng để test bằng bản giả (F-03). Bản thật
/// là `WebViewEngine`; chỉ chỗ đó dùng gói webview_flutter.
abstract class BrowserEngine {
  void attach(BrowserEvents events);

  Future<void> load(Uri url);
  Future<void> reload();
  Future<void> goBack();
  Future<void> goForward();
  Future<bool> canGoBack();
  Future<bool> canGoForward();
  Future<Uri?> currentUrl();
  Future<String?> title();

  /// HTML của trang hiện tại (`document.documentElement.outerHTML`).
  Future<String> outerHtml();

  /// Chữ người dùng đang bôi đen trên trang (`window.getSelection()`).
  Future<String> selectedText();

  Widget buildView(BuildContext context);

  void dispose();
}
