import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseLines (AC-03)', () {
    test('mỗi dòng thành một mục, bỏ dòng trống và khoảng trắng thừa', () {
      final lines = parseLines(
        '  500 g thịt bò \n\n2 củ hành tím\r\n   \n1 muỗng canh nước mắm',
        LineSection.ingredient,
      );
      expect(lines, const [
        RecipeLine('500 g thịt bò'),
        RecipeLine('2 củ hành tím'),
        RecipeLine('1 muỗng canh nước mắm'),
      ]);
    });

    test('dòng kết thúc bằng dấu : là tiêu đề nhóm', () {
      final lines = parseLines(
        'Phần nước dùng:\n2 lít nước\nPhần ăn kèm :\nrau thơm',
        LineSection.ingredient,
      );
      expect(lines, const [
        RecipeLine('Phần nước dùng', isHeading: true),
        RecipeLine('2 lít nước'),
        RecipeLine('Phần ăn kèm', isHeading: true),
        RecipeLine('rau thơm'),
      ]);
    });

    test('bỏ dấu đầu dòng nhưng giữ số lượng của nguyên liệu', () {
      final lines = parseLines(
        '- 2 quả trứng\n• 1/2 cup sữa\n* muối\n3. 300 g bột',
        LineSection.ingredient,
      );
      expect(lines.map((l) => l.text), [
        '2 quả trứng',
        '1/2 cup sữa',
        'muối',
        '3. 300 g bột',
      ]);
    });

    test('các bước bỏ số thứ tự có sẵn', () {
      final lines = parseLines(
        '1. Rửa sạch thịt\n2) Ướp 15 phút\nBước 3. Nấu nhỏ lửa\nStep 4: Serve',
        LineSection.step,
      );
      expect(lines.map((l) => l.text), [
        'Rửa sạch thịt',
        'Ướp 15 phút',
        'Nấu nhỏ lửa',
        'Serve',
      ]);
      expect(lines.every((l) => !l.isHeading), isTrue);
    });

    test('dòng chỉ có dấu : không thành tiêu đề rỗng', () {
      expect(parseLines(':\n  : ', LineSection.step), isEmpty);
    });
  });

  test('serializeLines rồi parseLines cho lại đúng danh sách (AC-03)', () {
    const original = [
      RecipeLine('Phần bánh', isHeading: true),
      RecipeLine('200 g bột mì'),
      RecipeLine('2 quả trứng'),
      RecipeLine('Phần kem', isHeading: true),
      RecipeLine('100 ml kem tươi'),
    ];
    final text = serializeLines(original);
    expect(
      text,
      'Phần bánh:\n200 g bột mì\n2 quả trứng\nPhần kem:\n100 ml kem tươi',
    );
    expect(parseLines(text, LineSection.ingredient), original);
  });
}
