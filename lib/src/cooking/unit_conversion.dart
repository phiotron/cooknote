import 'ingredient_parser.dart';

/// Hệ đơn vị đích khi đổi nguyên liệu (AC-33).
enum UnitSystem { metric, us }

/// Hệ nhiệt độ đích.
enum TemperatureSystem { celsius, fahrenheit }

/// Một số lượng kèm đơn vị chuẩn.
class UnitValue {
  const UnitValue(this.value, this.unit);
  final double value;
  final IngredientUnit unit;

  @override
  String toString() => 'UnitValue($value $unit)';
}

// Quy ra mililit (thể tích) hoặc gam (khối lượng), hệ Mỹ theo đơn vị US.
const _mlPer = <IngredientUnit, double>{
  IngredientUnit.ml: 1,
  IngredientUnit.l: 1000,
  IngredientUnit.tsp: 4.92892159375,
  IngredientUnit.tbsp: 14.78676478125,
  IngredientUnit.flOz: 29.5735295625,
  IngredientUnit.cup: 236.5882365,
  IngredientUnit.pint: 473.176473,
  IngredientUnit.quart: 946.352946,
};
const _gPer = <IngredientUnit, double>{
  IngredientUnit.mg: 0.001,
  IngredientUnit.g: 1,
  IngredientUnit.kg: 1000,
  IngredientUnit.oz: 28.349523125,
  IngredientUnit.lb: 453.59237,
};
const _metricUnits = {
  IngredientUnit.ml,
  IngredientUnit.l,
  IngredientUnit.g,
  IngredientUnit.kg,
  IngredientUnit.mg,
};

/// Đổi một số lượng sang hệ [to]; chọn đơn vị đích hợp lý theo độ lớn.
/// Thể tích chỉ đổi sang thể tích, khối lượng sang khối lượng. Trả null nếu
/// đơn vị không đổi được (chén, bát, củ, quả...); đã đúng hệ thì giữ nguyên.
UnitValue? convertUnit(double value, IngredientUnit unit, UnitSystem to) {
  final isMetric = _metricUnits.contains(unit);
  final sameSystem = (to == UnitSystem.metric) == isMetric;
  if (_mlPer.containsKey(unit)) {
    if (sameSystem) return UnitValue(value, unit);
    final ml = value * _mlPer[unit]!;
    if (to == UnitSystem.metric) {
      return ml >= 1000
          ? UnitValue(ml / 1000, IngredientUnit.l)
          : UnitValue(ml, IngredientUnit.ml);
    }
    final target = ml < _mlPer[IngredientUnit.tbsp]!
        ? IngredientUnit.tsp
        : ml < _mlPer[IngredientUnit.cup]! / 4
        ? IngredientUnit.tbsp
        : ml < 1000
        ? IngredientUnit.cup
        : IngredientUnit.quart;
    return UnitValue(ml / _mlPer[target]!, target);
  }
  if (_gPer.containsKey(unit)) {
    if (sameSystem) return UnitValue(value, unit);
    final g = value * _gPer[unit]!;
    if (to == UnitSystem.metric) {
      return g >= 1000
          ? UnitValue(g / 1000, IngredientUnit.kg)
          : UnitValue(g, IngredientUnit.g);
    }
    final target = g < _gPer[IngredientUnit.lb]!
        ? IngredientUnit.oz
        : IngredientUnit.lb;
    return UnitValue(g / _gPer[target]!, target);
  }
  return null;
}

double _roundTo(double v, double step) {
  final r = (v / step).round() * step;
  return r == 0 ? v : r;
}

/// Làm tròn kiểu nhà bếp (5 ml thay vì 4.93 ml); không dùng cho convertUnit.
double _kitchenRound(double v, IngredientUnit u) => switch (u) {
  IngredientUnit.ml ||
  IngredientUnit.g => v < 15 ? _roundTo(v, 0.5) : v.roundToDouble(),
  IngredientUnit.l || IngredientUnit.kg => _roundTo(v, 0.01),
  IngredientUnit.tsp => _roundTo(v, 0.125),
  IngredientUnit.cup => _roundTo(v, 0.125),
  IngredientUnit.mg => v.roundToDouble(),
  _ => _roundTo(v, 0.25),
};

/// Đổi một dòng nguyên liệu sang hệ [to]. Dòng không `structured`, đơn vị
/// không đổi được hoặc đã đúng hệ thì trả về nguyên vẹn.
ParsedIngredient convertIngredient(ParsedIngredient p, UnitSystem to) {
  final unit = p.unit;
  if (!p.structured || unit == null || p.quantity == null) return p;
  final high = p.quantityMax ?? p.quantity!;
  final ref = convertUnit(high, unit, to);
  if (ref == null || ref.unit == unit) return p;
  final factor =
      (_mlPer[unit] ?? _gPer[unit]!) / (_mlPer[ref.unit] ?? _gPer[ref.unit]!);
  double conv(double v) => _kitchenRound(v * factor, ref.unit);
  return ParsedIngredient(
    original: p.original,
    quantity: conv(p.quantity!),
    quantityMax: p.quantityMax == null ? null : conv(p.quantityMax!),
    unit: ref.unit,
    unitText: unitLabel(ref.unit),
    name: p.name,
    note: p.note,
    structured: true,
  );
}

final _temperature = RegExp(
  r'(?<![\d.,])(\d+(?:[.,]\d+)?)(?:\s*[-–]\s*(\d+(?:[.,]\d+)?))?'
  r'\s*(?:°|º|˚|độ|do|degrees?|deg)\s*([CF])(?![A-Za-z])',
  caseSensitive: false,
);

/// Đổi nhiệt độ trong chữ của bước sang [to]: "nướng 180°C", "350 °F",
/// "180 độ C" (AC-33). Nhiệt độ đã đúng hệ giữ nguyên. Kết quả từ 100 trở lên
/// làm tròn tới 5 độ (nhiệt độ lò), dưới 100 làm tròn số nguyên.
String convertTemperaturesInText(String text, TemperatureSystem to) {
  return text.replaceAllMapped(_temperature, (m) {
    final from = m[3]!.toUpperCase() == 'C'
        ? TemperatureSystem.celsius
        : TemperatureSystem.fahrenheit;
    if (from == to) return m[0]!;
    String conv(String raw) {
      final v = double.parse(raw.replaceFirst(',', '.'));
      final r = to == TemperatureSystem.fahrenheit
          ? v * 9 / 5 + 32
          : (v - 32) * 5 / 9;
      final rounded = r.abs() >= 100 ? (r / 5).round() * 5 : r.round();
      return '$rounded';
    }

    final sym = to == TemperatureSystem.fahrenheit ? '°F' : '°C';
    final low = conv(m[1]!);
    return m[2] == null ? '$low$sym' : '$low-${conv(m[2]!)}$sym';
  });
}
