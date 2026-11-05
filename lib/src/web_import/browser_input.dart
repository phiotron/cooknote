/// Công cụ tìm kiếm mặc định của trình duyệt trong app (AC-16). DuckDuckGo vì
/// không cần tài khoản và không theo dõi người dùng.
const searchUrlPrefix = 'https://duckduckgo.com/?q=';

final _scheme = RegExp(r'^https?://\S+$', caseSensitive: false);
final _bareHost = RegExp(
  r'^(?:[\p{L}\d-]+\.)+\p{L}{2,}(?::\d+)?(?:[/?#]\S*)?$',
  unicode: true,
);
final _urlInText = RegExp(r'''https?://[^\s<>"']+''', caseSensitive: false);

/// Đổi chữ người dùng gõ vào ô địa chỉ thành địa chỉ cần mở (AC-16): đã là URL
/// http(s) thì giữ nguyên; dạng `ten-mien.com/duong-dan` thì thêm `https://`;
/// còn lại là từ khóa nên tìm bằng công cụ tìm kiếm mặc định. Rỗng thì null.
Uri? resolveBrowserInput(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  if (_scheme.hasMatch(text)) {
    final uri = Uri.tryParse(text);
    if (uri != null && uri.host.isNotEmpty) return uri;
  } else if (_bareHost.hasMatch(text)) {
    final uri = Uri.tryParse('https://$text');
    if (uri != null && uri.host.isNotEmpty) return uri;
  }
  return Uri.parse('$searchUrlPrefix${Uri.encodeQueryComponent(text)}');
}

/// URL http(s) đầu tiên trong chữ được chia sẻ (AC-17), ví dụ "Xem món này
/// https://... nhé". Không có thì null.
String? firstUrlIn(String text) {
  final m = _urlInText.firstMatch(text);
  if (m == null) return null;
  var url = m.group(0)!;
  while (url.isNotEmpty && '.,;:!?)]}'.contains(url[url.length - 1])) {
    url = url.substring(0, url.length - 1);
  }
  final uri = Uri.tryParse(url);
  return uri != null && uri.host.isNotEmpty ? url : null;
}
