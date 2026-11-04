import 'package:cooknote/src/cooking/ingredient_parser.dart';
import 'package:cooknote/src/cooking/scaling.dart';
import 'package:cooknote/src/cooking/unit_conversion.dart';
import 'package:flutter_test/flutter_test.dart';

const _volumes = {
  IngredientUnit.ml,
  IngredientUnit.l,
  IngredientUnit.tsp,
  IngredientUnit.tbsp,
  IngredientUnit.cup,
  IngredientUnit.flOz,
  IngredientUnit.pint,
  IngredientUnit.quart,
};
const _masses = {
  IngredientUnit.g,
  IngredientUnit.kg,
  IngredientUnit.mg,
  IngredientUnit.oz,
  IngredientUnit.lb,
};

/// Đổi ra hệ khác rồi đổi ngược về gam hoặc mililit.
double _toBase(UnitValue v) {
  final back = convertUnit(v.value, v.unit, UnitSystem.metric)!;
  return switch (back.unit) {
    IngredientUnit.kg || IngredientUnit.l => back.value * 1000,
    _ => back.value,
  };
}

void main() {
  group('convertUnit', () {
    test('thể tích mét sang Mỹ', () {
      final v = convertUnit(250, IngredientUnit.ml, UnitSystem.us)!;
      expect(v.unit, IngredientUnit.cup);
      expect(v.value, closeTo(1.0567, 0.001));
      expect(
        convertUnit(5, IngredientUnit.ml, UnitSystem.us)!.unit,
        IngredientUnit.tsp,
      );
      expect(
        convertUnit(30, IngredientUnit.ml, UnitSystem.us)!.unit,
        IngredientUnit.tbsp,
      );
    });

    test('thể tích Mỹ sang mét', () {
      final v = convertUnit(1, IngredientUnit.cup, UnitSystem.metric)!;
      expect(v.unit, IngredientUnit.ml);
      expect(v.value, closeTo(236.6, 0.1));
      expect(
        convertUnit(1, IngredientUnit.tbsp, UnitSystem.metric)!.value,
        closeTo(14.79, 0.01),
      );
      expect(
        convertUnit(1, IngredientUnit.tsp, UnitSystem.metric)!.value,
        closeTo(4.93, 0.01),
      );
      expect(
        convertUnit(1, IngredientUnit.flOz, UnitSystem.metric)!.value,
        closeTo(29.57, 0.01),
      );
      final q = convertUnit(2, IngredientUnit.quart, UnitSystem.metric)!;
      expect(q.unit, IngredientUnit.l);
      expect(q.value, closeTo(1.893, 0.001));
    });

    test('khối lượng', () {
      final oz = convertUnit(100, IngredientUnit.g, UnitSystem.us)!;
      expect(oz.unit, IngredientUnit.oz);
      expect(oz.value, closeTo(3.527, 0.001));
      final lb = convertUnit(1000, IngredientUnit.g, UnitSystem.us)!;
      expect(lb.unit, IngredientUnit.lb);
      expect(lb.value, closeTo(2.2046, 0.001));
      expect(
        convertUnit(1, IngredientUnit.kg, UnitSystem.us)!.unit,
        IngredientUnit.lb,
      );
      final g = convertUnit(1, IngredientUnit.lb, UnitSystem.metric)!;
      expect((g.unit, g.value.round()), (IngredientUnit.g, 454));
      expect(
        convertUnit(3, IngredientUnit.lb, UnitSystem.metric)!.unit,
        IngredientUnit.kg,
      );
      expect(
        convertUnit(8, IngredientUnit.oz, UnitSystem.metric)!.value,
        closeTo(226.8, 0.1),
      );
    });

    test('vòng tròn khối lượng và thể tích nằm trong sai số', () {
      for (final g in [1.0, 10.0, 100.0, 250.0, 500.0, 1234.0, 5000.0]) {
        final us = convertUnit(g, IngredientUnit.g, UnitSystem.us)!;
        expect(_masses.contains(us.unit), isTrue);
        expect(_toBase(us), closeTo(g, g * 0.001), reason: '$g g');
      }
      for (final ml in [5.0, 15.0, 60.0, 250.0, 1000.0, 3000.0]) {
        final us = convertUnit(ml, IngredientUnit.ml, UnitSystem.us)!;
        expect(_volumes.contains(us.unit), isTrue);
        expect(_toBase(us), closeTo(ml, ml * 0.001), reason: '$ml ml');
      }
    });

    test('KHÔNG đổi thể tích sang khối lượng hay ngược lại', () {
      for (final u in _volumes) {
        for (final s in UnitSystem.values) {
          final r = convertUnit(100, u, s);
          expect(_volumes.contains(r!.unit), isTrue, reason: '$u -> ${r.unit}');
        }
      }
      for (final u in _masses) {
        for (final s in UnitSystem.values) {
          final r = convertUnit(100, u, s);
          expect(_masses.contains(r!.unit), isTrue, reason: '$u -> ${r.unit}');
        }
      }
    });

    test('đơn vị không đổi được trả null', () {
      for (final u in [
        IngredientUnit.chen,
        IngredientUnit.bat,
        IngredientUnit.cu,
        IngredientUnit.qua,
        IngredientUnit.trai,
        IngredientUnit.tep,
        IngredientUnit.spoon,
        IngredientUnit.nhum,
        IngredientUnit.lon,
      ]) {
        expect(convertUnit(2, u, UnitSystem.us), isNull, reason: '$u');
        expect(convertUnit(2, u, UnitSystem.metric), isNull, reason: '$u');
      }
    });

    test('đã đúng hệ thì giữ nguyên', () {
      final v = convertUnit(100, IngredientUnit.g, UnitSystem.metric)!;
      expect((v.value, v.unit), (100.0, IngredientUnit.g));
      final w = convertUnit(2, IngredientUnit.cup, UnitSystem.us)!;
      expect((w.value, w.unit), (2.0, IngredientUnit.cup));
    });
  });

  group('convertIngredient', () {
    String conv(String line, UnitSystem to) =>
        formatIngredient(convertIngredient(parseIngredient(line), to));

    test('mét sang Mỹ làm tròn gọn', () {
      expect(conv('250 g flour', UnitSystem.us), '8 3/4 oz flour');
      expect(conv('250 ml milk', UnitSystem.us), '1 cup milk');
    });

    test('Mỹ sang mét', () {
      expect(conv('2 cups milk', UnitSystem.metric), '473 ml milk');
      expect(conv('1 tsp salt', UnitSystem.metric), '5 ml salt');
      expect(conv('1 lb beef', UnitSystem.metric), '454 g beef');
    });

    test('khoảng đổi cả hai đầu', () {
      final p = convertIngredient(
        parseIngredient('1-2 cups milk'),
        UnitSystem.metric,
      );
      expect(p.unit, IngredientUnit.ml);
      expect(p.quantity, closeTo(237, 1));
      expect(p.quantityMax, closeTo(473, 1));
    });

    test('không đổi dòng không đổi được', () {
      expect(conv('3 củ hành', UnitSystem.us), '3 củ hành');
      expect(conv('2 chén gạo', UnitSystem.metric), '2 chén gạo');
      expect(conv('muối vừa ăn', UnitSystem.us), 'muối vừa ăn');
      expect(conv('200 g bột', UnitSystem.metric), '200 g bột');
    });
  });

  group('convertTemperaturesInText', () {
    String t(String s, TemperatureSystem to) =>
        convertTemperaturesInText(s, to);

    test('C sang F', () {
      expect(t('nướng 180°C', TemperatureSystem.fahrenheit), 'nướng 355°F');
      expect(
        t('nướng ở 180 độ C trong 30 phút', TemperatureSystem.fahrenheit),
        'nướng ở 355°F trong 30 phút',
      );
      expect(t('nướng 180 °C', TemperatureSystem.fahrenheit), 'nướng 355°F');
      expect(t('180 degrees C', TemperatureSystem.fahrenheit), '355°F');
    });

    test('F sang C', () {
      expect(t('bake at 350 °F', TemperatureSystem.celsius), 'bake at 175°C');
      expect(t('internal 165°F', TemperatureSystem.celsius), 'internal 74°C');
    });

    test('khoảng và nhiều nhiệt độ', () {
      expect(t('180-200°C', TemperatureSystem.fahrenheit), '355-390°F');
      expect(
        t('120°C rồi 180°C', TemperatureSystem.fahrenheit),
        '250°F rồi 355°F',
      );
    });

    test('đã đúng hệ hoặc không có nhiệt độ thì giữ nguyên', () {
      expect(t('nướng 180°C', TemperatureSystem.celsius), 'nướng 180°C');
      expect(t('bake 350 °F', TemperatureSystem.fahrenheit), 'bake 350 °F');
      expect(
        t('nấu 15 phút, cho 2 độ', TemperatureSystem.fahrenheit),
        'nấu 15 phút, cho 2 độ',
      );
      expect(
        t('thêm 2 muỗng canh dầu', TemperatureSystem.fahrenheit),
        'thêm 2 muỗng canh dầu',
      );
    });
  });
}
