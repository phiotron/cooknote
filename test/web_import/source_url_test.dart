import 'package:cooknote/src/web_import/source_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeSourceUrl', () {
    test('hạ chữ thường host, bỏ www., giữ chữ hoa trong đường dẫn', () {
      expect(
        normalizeSourceUrl('https://WWW.Example.COM/Recipes/Pho'),
        'https://example.com/Recipes/Pho',
      );
    });

    test('bỏ fragment', () {
      expect(
        normalizeSourceUrl('https://example.com/a#comments'),
        'https://example.com/a',
      );
    });

    test('bỏ tham số theo dõi, giữ tham số có nghĩa', () {
      expect(
        normalizeSourceUrl(
          'https://example.com/r?id=7&utm_source=fb&UTM_medium=x&fbclid=abc&gclid=1&ref=home',
        ),
        'https://example.com/r?id=7',
      );
    });

    test('bỏ hết tham số thì không còn dấu ?', () {
      expect(
        normalizeSourceUrl('https://example.com/r?utm_campaign=a&fbclid=b'),
        'https://example.com/r',
      );
    });

    test('bỏ dấu / cuối, kể cả trước query', () {
      expect(
        normalizeSourceUrl('https://example.com/a/b/'),
        'https://example.com/a/b',
      );
      expect(
        normalizeSourceUrl('https://example.com/a/?p=1'),
        'https://example.com/a?p=1',
      );
      expect(normalizeSourceUrl('https://example.com/'), 'https://example.com');
      expect(normalizeSourceUrl('https://example.com'), 'https://example.com');
    });

    test('bỏ cổng mặc định, giữ cổng khác', () {
      expect(
        normalizeSourceUrl('https://example.com:443/a'),
        'https://example.com/a',
      );
      expect(
        normalizeSourceUrl('http://example.com:80/a'),
        'https://example.com/a',
      );
      expect(
        normalizeSourceUrl('https://example.com:8443/a'),
        'https://example.com:8443/a',
      );
    });

    test('http và https coi là cùng một trang', () {
      expect(
        normalizeSourceUrl('http://example.com/a'),
        normalizeSourceUrl('https://example.com/a'),
      );
    });

    test('sắp xếp tham số còn lại', () {
      expect(
        normalizeSourceUrl('https://example.com/r?b=2&a=1&a=0'),
        'https://example.com/r?a=0&a=1&b=2',
      );
    });

    test('hai URL khác nhau chỉ ở phần theo dõi thì chuẩn hóa giống nhau', () {
      expect(
        normalizeSourceUrl('https://www.example.com/pho/?utm_source=a#x'),
        normalizeSourceUrl('http://example.com/pho'),
      );
    });

    test('tham số có nghĩa khác nhau thì khác nhau', () {
      expect(
        normalizeSourceUrl('https://example.com/r?id=1'),
        isNot(normalizeSourceUrl('https://example.com/r?id=2')),
      );
    });

    test('thiếu scheme thì coi là https; khoảng trắng hai đầu bị bỏ', () {
      expect(normalizeSourceUrl('  Example.com/a/ '), 'https://example.com/a');
    });

    test(
      'chuỗi rỗng hoặc không phân tích được thì trả về nguyên (đã trim)',
      () {
        expect(normalizeSourceUrl(''), '');
        expect(normalizeSourceUrl('   '), '');
      },
    );

    test('bỏ thông tin đăng nhập trong URL', () {
      expect(
        normalizeSourceUrl('https://user:pw@example.com/a'),
        'https://example.com/a',
      );
    });
  });
}
