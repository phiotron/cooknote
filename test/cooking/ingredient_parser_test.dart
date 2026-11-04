import 'package:cooknote/src/cooking/ingredient_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/ingredient_lines.dart';

/// So kết quả tách với mong đợi; trả về mô tả lỗi hoặc null nếu đúng.
String? _diff(IngredientCase c) {
  final p = parseIngredient(c.line);
  final problems = <String>[];
  bool near(double? a, double? b) =>
      (a == null && b == null) ||
      (a != null && b != null && (a - b).abs() < 1e-9);
  if (p.structured != c.structured) {
    problems.add('structured ${p.structured} != ${c.structured}');
  }
  if (!near(p.quantity, c.qty)) {
    problems.add('quantity ${p.quantity} != ${c.qty}');
  }
  if (!near(p.quantityMax, c.qtyMax)) {
    problems.add('quantityMax ${p.quantityMax} != ${c.qtyMax}');
  }
  if (p.unit != c.unit) problems.add('unit ${p.unit} != ${c.unit}');
  if (p.name != c.name) problems.add('name "${p.name}" != "${c.name}"');
  if (p.note != c.note) problems.add('note "${p.note}" != "${c.note}"');
  return problems.isEmpty ? null : problems.join('; ');
}

void main() {
  group('bộ dòng nguyên liệu thật kiểu (AC-31)', () {
    test('có đủ 60 dòng Việt và 60 dòng Anh', () {
      expect(vietnameseLines.length, greaterThanOrEqualTo(60));
      expect(englishLines.length, greaterThanOrEqualTo(60));
      expect(allIngredientLines.length, greaterThanOrEqualTo(120));
    });

    test('tỉ lệ tách đúng >= 95%', () {
      var ok = 0;
      final wrong = <String>[];
      for (final c in allIngredientLines) {
        final d = _diff(c);
        if (d == null) {
          ok++;
        } else {
          wrong.add('  "${c.line}": $d');
        }
      }
      final total = allIngredientLines.length;
      final rate = ok / total;
      // ignore: avoid_print
      print('Tách đúng $ok/$total = ${(rate * 100).toStringAsFixed(1)}%');
      if (wrong.isNotEmpty) {
        // ignore: avoid_print
        print('Các dòng sai:\n${wrong.join('\n')}');
      }
      expect(rate, greaterThanOrEqualTo(0.95));
    });

    test('dòng không tách được số lượng giữ nguyên, structured=false', () {
      for (final line in [
        '1 ít hành',
        'muối vừa ăn',
        'salt to taste',
        'Juice of 1 lemon',
      ]) {
        final p = parseIngredient(line);
        expect(p.structured, isFalse, reason: line);
        expect(p.name, line);
        expect(p.quantity, isNull);
        expect(p.unit, isNull);
      }
    });
  });

  group('số lượng', () {
    test('dạng số', () {
      expect(parseIngredient('2 eggs').quantity, 2);
      expect(parseIngredient('0,5 l nước').quantity, 0.5);
      expect(parseIngredient('0.25 kg bột').quantity, 0.25);
      expect(parseIngredient('1/2 cup milk').quantity, 0.5);
      expect(parseIngredient('1 1/2 cup milk').quantity, 1.5);
      expect(parseIngredient('1½ cup milk').quantity, 1.5);
      expect(parseIngredient('¼ cup milk').quantity, 0.25);
    });

    test('khoảng', () {
      for (final s in ['2-3 củ', '2–3 củ', '2 to 3 củ', '2 hoặc 3 củ']) {
        final p = parseIngredient('$s hành');
        expect((p.quantity, p.quantityMax), (2.0, 3.0), reason: s);
        expect(p.isRange, isTrue);
      }
      expect(parseIngredient('2 củ hành').isRange, isFalse);
    });

    test('đơn vị đảo thứ tự và không dấu', () {
      final a = parseIngredient('nước mắm 2 thìa canh');
      expect(
        (a.quantity, a.unit, a.name),
        (2.0, IngredientUnit.tbsp, 'nước mắm'),
      );
      final b = parseIngredient('1 muong ca phe muoi');
      expect(b.unit, IngredientUnit.tsp);
    });

    test('biến thể viết', () {
      expect(parseIngredient('2 tbsp. oil').unit, IngredientUnit.tbsp);
      expect(parseIngredient('2 Tbsp oil').unit, IngredientUnit.tbsp);
      expect(parseIngredient('2 cups oil').unit, IngredientUnit.cup);
      expect(parseIngredient('2 CUPS oil').unit, IngredientUnit.cup);
      expect(parseIngredient('2 cups oil').unitText, 'cups');
    });
  });
}
