import 'package:cooknote/src/cooking/ingredient_parser.dart';
import 'package:cooknote/src/cooking/scaling.dart';
import 'package:flutter_test/flutter_test.dart';

String _scale(String line, double f) =>
    formatIngredient(scaleIngredient(parseIngredient(line), f));

void main() {
  group('formatQuantity', () {
    test('phân số gọn', () {
      expect(formatQuantity(0.5), '1/2');
      expect(formatQuantity(0.125), '1/8');
      expect(formatQuantity(0.25), '1/4');
      expect(formatQuantity(1 / 3), '1/3');
      expect(formatQuantity(0.3333333), '1/3');
      expect(formatQuantity(2 / 3), '2/3');
      expect(formatQuantity(0.75), '3/4');
      expect(formatQuantity(1.5), '1 1/2');
      expect(formatQuantity(2.25), '2 1/4');
      expect(formatQuantity(2 + 1 / 3), '2 1/3');
    });

    test('số nguyên không có ".0"', () {
      expect(formatQuantity(1.0), '1');
      expect(formatQuantity(1.9999999), '2');
      expect(formatQuantity(0.9999999), '1');
      expect(formatQuantity(150.0), '150');
      expect(formatQuantity(0), '0');
    });

    test('số lớn và số lẻ không đẹp dùng thập phân gọn', () {
      expect(formatQuantity(12.5), '12.5');
      expect(formatQuantity(375.0004), '375');
      expect(formatQuantity(0.7), '0.7');
      expect(formatQuantity(2.45), '2.45');
      expect(formatQuantity(0.7, decimalComma: true), '0,7');
    });

    test('chế độ thập phân cho g/ml', () {
      expect(formatQuantity(33.3333, fractions: false), '33.3');
      expect(formatQuantity(0.5, fractions: false), '0.5');
      expect(formatQuantity(1.3333, fractions: false), '1.33');
      expect(formatQuantity(1500.4, fractions: false), '1500');
    });

    test('không bao giờ có dạng 0.33333 hoặc kết thúc .0', () {
      for (var i = 1; i <= 400; i++) {
        final v = i / 24.0;
        for (final fr in [true, false]) {
          final s = formatQuantity(v, fractions: fr);
          expect(s.contains(RegExp(r'\d{3,}\d*\.\d{3,}')), isFalse, reason: s);
          expect(RegExp(r'\.\d{3,}').hasMatch(s), isFalse, reason: '$v -> $s');
          expect(s.endsWith('.0'), isFalse, reason: s);
          expect(s.contains('.00'), isFalse, reason: s);
        }
      }
    });
  });

  group('scaleIngredient + formatIngredient', () {
    test('nhân 0.5', () {
      expect(_scale('1 cup sugar', 0.5), '1/2 cup sugar');
      expect(_scale('3 tép tỏi', 0.5), '1 1/2 tép tỏi');
      expect(_scale('250 g bột', 0.5), '125 g bột');
    });

    test('nhân 2', () {
      expect(_scale('1 1/2 cups flour', 2), '3 cups flour');
      expect(_scale('2-3 tbsp oil', 2), '4-6 tbsp oil');
      expect(_scale('1/2 tsp salt', 2), '1 tsp salt');
    });

    test('nhân 3', () {
      expect(_scale('250 g bột', 3), '750 g bột');
      expect(_scale('1 1/2 cups flour', 3), '4 1/2 cups flour');
    });

    test('nhân 1.5', () {
      expect(_scale('1 1/2 cup rice', 1.5), '2 1/4 cup rice');
      expect(_scale('2 củ hành', 1.5), '3 củ hành');
      expect(_scale('100 ml nước', 1.5), '150 ml nước');
    });

    test('nhân 1/3', () {
      expect(_scale('1 tsp salt', 1 / 3), '1/3 tsp salt');
      expect(_scale('1 cup oil', 1 / 3), '1/3 cup oil');
      expect(_scale('375 g flour', 1 / 3), '125 g flour');
      expect(_scale('1/2 cup oil', 1 / 3), '1/6 cup oil');
      expect(_scale('100 g sugar', 1 / 3), '33.3 g sugar');
    });

    test('giữ ghi chú', () {
      expect(_scale('2 tbsp butter, melted', 2), '4 tbsp butter, melted');
    });

    test('dòng không structured giữ nguyên', () {
      expect(_scale('muối vừa ăn', 3), 'muối vừa ăn');
      expect(_scale('1 ít hành', 2), '1 ít hành');
      final p = parseIngredient('salt to taste');
      expect(
        identical(scaleIngredient(p, 2), p) ||
            scaleIngredient(p, 2).structured == false,
        isTrue,
      );
    });

    test('hệ số không hợp lệ', () {
      final p = parseIngredient('1 cup oil');
      expect(() => scaleIngredient(p, 0), throwsArgumentError);
      expect(() => scaleIngredient(p, -1), throwsArgumentError);
    });

    test('formatIngredient không đổi gì khi chưa nhân', () {
      expect(
        formatIngredient(parseIngredient('1 1/2 cups sugar')),
        '1 1/2 cups sugar',
      );
      expect(formatIngredient(parseIngredient('500g thịt')), '500 g thịt');
    });
  });
}
