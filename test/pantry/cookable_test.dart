import 'package:cooknote/src/pantry/cookable.dart';
import 'package:flutter_test/flutter_test.dart';

RecipeIngredients r(int id, String name, List<String> lines) =>
    RecipeIngredients(id: id, name: name, lines: lines);

void main() {
  test('gia vị cơ bản nhận ra cả hai ngôn ngữ', () {
    for (final s in [
      'muối',
      'Đường',
      'nước',
      'tiêu',
      'dầu ăn',
      'nước mắm',
      'salt',
      'Sugar',
      'water',
      'black pepper',
      'oil',
      'vegetable oil',
      'fish sauce',
    ]) {
      expect(isBasicStaple(s), isTrue, reason: s);
    }
    for (final s in ['thịt bò', 'hành tây', 'nước dừa', 'sugar snap peas']) {
      expect(isBasicStaple(s), isFalse, reason: s);
    }
  });

  test('xếp theo tỉ lệ nguyên liệu có, kèm số món còn thiếu', () {
    final out = rankCookable(
      recipes: [
        r(1, 'Phở', [
          '500 g thịt bò',
          '2 củ hành tây',
          '1 gói gia vị phở',
          'bánh phở',
        ]),
        r(2, 'Bò xào', ['300 g thịt bò', '1 củ hành tây']),
        r(3, 'Chè', ['100 g đường', '200 ml nước dừa']),
      ],
      pantryNames: ['Thịt bò', 'hành tây'],
      ignoreBasics: false,
    );
    expect(out.map((c) => c.id), [2, 1]);
    expect(out[0].total, 2);
    expect(out[0].have, 2);
    expect(out[0].missingCount, 0);
    expect(out[1].have, 2);
    expect(out[1].total, 4);
    expect(out[1].missingCount, 2);
    expect(out[1].missing, ['gia vị phở', 'bánh phở']);
    expect(out[1].ratio, 0.5);
  });

  test('khớp không dấu và số ít/số nhiều tiếng Anh', () {
    final out = rankCookable(
      recipes: [
        r(1, 'Salad', ['2 tomatoes', '1 cucumber', '3 eggs']),
      ],
      pantryNames: ['TOMATO', 'Cucumbers', 'egg'],
      ignoreBasics: false,
    );
    expect(out.single.have, 3);
    expect(out.single.missingCount, 0);
  });

  test('gia vị cơ bản chỉ không tính thiếu khi bật tùy chọn', () {
    final recipes = [
      r(1, 'Thịt kho', [
        '500 g thịt heo',
        'nước mắm',
        '2 muỗng canh đường',
        'tiêu',
      ]),
    ];
    final off = rankCookable(
      recipes: recipes,
      pantryNames: ['thịt heo'],
      ignoreBasics: false,
    );
    expect(off.single.missingCount, 3);
    final on = rankCookable(
      recipes: recipes,
      pantryNames: ['thịt heo'],
      ignoreBasics: true,
    );
    expect(on.single.missingCount, 0);
    expect(on.single.ratio, 1);
  });

  test('bỏ công thức không có nguyên liệu nào trùng, và công thức rỗng', () {
    final out = rankCookable(
      recipes: [
        r(1, 'A', ['1 củ hành']),
        r(2, 'Rỗng', []),
      ],
      pantryNames: ['thịt bò'],
      ignoreBasics: false,
    );
    expect(out, isEmpty);
  });

  test('cùng tỉ lệ thì ít thiếu hơn, rồi theo tên', () {
    final out = rankCookable(
      recipes: [
        r(1, 'B', ['a', 'b', 'x', 'y']),
        r(2, 'A', ['a', 'x']),
        r(3, 'C', ['a', 'b']),
      ],
      pantryNames: ['a', 'b'],
      ignoreBasics: false,
    );
    // C = 100%; A = 50% (thiếu 1); B = 50% (thiếu 2).
    expect(out.map((c) => c.id), [3, 2, 1]);
  });
}
