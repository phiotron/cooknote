import 'package:flutter_test/flutter_test.dart';

import 'package:cooknote/src/web_import/browser_engine.dart';

/// Lỗi tài nguyên con (favicon, ảnh, quảng cáo) không được coi là lỗi cả
/// trang: trước đây mọi phản hồi HTTP ≥ 400 đều hiện màn "Trang báo lỗi 404"
/// dù trang chính tải bình thường.
void main() {
  final page = Uri.parse('https://duckduckgo.com/?q=pho+bo');

  group('isMainFrameFailure', () {
    test('tài nguyên con khác đường dẫn không phải lỗi cả trang', () {
      expect(
        isMainFrameFailure(
          pageUrl: page,
          failedUrl: Uri.parse('https://duckduckgo.com/favicon.ico'),
          isForMainFrame: null,
        ),
        isFalse,
      );
    });

    test('tài nguyên con khác máy chủ không phải lỗi cả trang', () {
      expect(
        isMainFrameFailure(
          pageUrl: page,
          failedUrl: Uri.parse('https://ads.example.com/pixel.gif'),
          isForMainFrame: null,
        ),
        isFalse,
      );
    });

    test('trang chính cùng đường dẫn là lỗi cả trang', () {
      expect(
        isMainFrameFailure(
          pageUrl: page,
          failedUrl: Uri.parse('https://duckduckgo.com/?q=pho+bo&ia=web'),
          isForMainFrame: null,
        ),
        isTrue,
      );
    });

    test('dấu / cuối khác nhau vẫn là cùng trang', () {
      expect(
        isMainFrameFailure(
          pageUrl: Uri.parse('https://example.com'),
          failedUrl: Uri.parse('https://example.com/'),
          isForMainFrame: null,
        ),
        isTrue,
      );
    });

    test('nền tảng báo rõ main frame thì tin theo nền tảng', () {
      expect(
        isMainFrameFailure(
          pageUrl: page,
          failedUrl: Uri.parse('https://duckduckgo.com/favicon.ico'),
          isForMainFrame: true,
        ),
        isTrue,
      );
      expect(
        isMainFrameFailure(
          pageUrl: page,
          failedUrl: page,
          isForMainFrame: false,
        ),
        isFalse,
      );
    });

    test('không rõ địa chỉ thì không chặn cả trang', () {
      expect(
        isMainFrameFailure(
          pageUrl: page,
          failedUrl: null,
          isForMainFrame: null,
        ),
        isFalse,
      );
    });
  });
}
