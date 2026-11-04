/// Tham số chỉ dùng để theo dõi, không đổi nội dung trang (AC-20).
const _trackingParams = {
  'fbclid',
  'gclid',
  'gbraid',
  'wbraid',
  'dclid',
  'msclkid',
  'yclid',
  'igshid',
  'mc_cid',
  'mc_eid',
  'ref',
  'ref_src',
  'ref_url',
  'referrer',
  '_ga',
  '_gl',
  'cmpid',
};

bool _isTracking(String key) {
  final k = key.toLowerCase();
  return k.startsWith('utm_') || _trackingParams.contains(k);
}

/// Chuẩn hóa địa chỉ nguồn để phát hiện công thức đã nhập trước đó (AC-20):
/// hạ chữ thường scheme và host, bỏ `www.`, thông tin đăng nhập, fragment,
/// tham số theo dõi (utm_*, fbclid, gclid, ref...), dấu `/` cuối, cổng mặc định;
/// sắp xếp tham số còn lại. `http` và `https` coi là một (đều thành `https`).
/// Thiếu scheme thì coi là https. Không phân tích được thì trả chuỗi đã trim.
String normalizeSourceUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';
  final withScheme = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(withScheme);
  if (uri == null || uri.host.isEmpty) return trimmed;

  var scheme = uri.scheme.toLowerCase();
  var host = uri.host.toLowerCase();
  if (host.startsWith('www.')) host = host.substring(4);
  final isWeb = scheme == 'http' || scheme == 'https';
  final defaultPort = scheme == 'http' ? 80 : (scheme == 'https' ? 443 : -1);
  if (isWeb) scheme = 'https';

  var path = uri.path;
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }

  final params = <String>[];
  for (final raw in uri.query.split('&')) {
    if (raw.isEmpty) continue;
    final key = raw.split('=').first;
    if (_isTracking(key)) continue;
    params.add(raw);
  }
  params.sort();

  final port = uri.hasPort && uri.port != defaultPort ? ':${uri.port}' : '';
  final query = params.isEmpty ? '' : '?${params.join('&')}';
  return '$scheme://$host$port$path$query';
}
