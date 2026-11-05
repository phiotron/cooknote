import 'package:cooknote/src/shopping/name_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('foldKey bỏ dấu, hạ chữ thường', () {
    expect(foldKey('Thịt  Bò'), 'thit bo');
  });

  test('foldKey gộp số ít và số nhiều tiếng Anh', () {
    const pairs = [
      ['Tomatoes', 'tomato'],
      ['potatoes', 'Potato'],
      ['eggs', 'egg'],
      ['cookies', 'cookie'],
      ['berries', 'berry'],
      ['cheeses', 'cheese'],
      ['peaches', 'peach'],
      ['cloves', 'clove'],
      ['green onions', 'green onion'],
    ];
    for (final p in pairs) {
      expect(foldKey(p[0]), foldKey(p[1]), reason: '${p[0]} vs ${p[1]}');
    }
  });

  test('foldKey không làm hỏng từ không phải số nhiều', () {
    expect(foldKey('glass'), 'glass');
    expect(foldKey('hummus'), 'hummus');
    expect(foldKey('gas'), 'gas');
  });

  test('foldKey khác nhau với món khác nhau', () {
    expect(foldKey('thịt bò'), isNot(foldKey('thịt bò xay')));
  });
}
