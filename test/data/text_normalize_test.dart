import 'package:cooknote/src/data/text_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeText (AC-12)', () {
    test('bỏ dấu tiếng Việt và hạ chữ thường', () {
      expect(normalizeText('Phở bò'), 'pho bo');
      expect(normalizeText('ĐÀ NẴNG'), 'da nang');
      expect(normalizeText('Bánh xèo, Bún chả'), 'banh xeo, bun cha');
      expect(
        normalizeText('ươ ơ ư ê ô â ă ế ề ể ễ ệ'),
        'uo o u e o a a e e e e e',
      );
    });

    test('chữ không dấu và ký tự khác giữ nguyên', () {
      expect(normalizeText('Pasta 2 cups'), 'pasta 2 cups');
      expect(normalizeText('Crème brûlée'), 'creme brulee');
      expect(normalizeText(''), '');
    });

    test('gộp khoảng trắng thừa', () {
      expect(normalizeText('  phở   bò \n '), 'pho bo');
    });
  });

  group('searchTerms', () {
    test('tách theo khoảng trắng, mỗi từ đã chuẩn hóa', () {
      expect(searchTerms('  Phở  BÒ '), ['pho', 'bo']);
      expect(searchTerms('   '), isEmpty);
    });

    test('bỏ ký tự đại diện của LIKE', () {
      expect(searchTerms('100% a_b'), ['100', 'a', 'b']);
    });
  });
}
