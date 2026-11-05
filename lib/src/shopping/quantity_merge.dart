import '../cooking/ingredient_parser.dart';
import '../cooking/scaling.dart';

/// Số lượng của một món đi chợ: [value] null là không ghi số lượng; [unit]
/// null là đếm không đơn vị ("3 quả trứng" tách ra đơn vị quả; "3 trứng" thì
/// không đơn vị). [text] là chữ đơn vị người dùng viết ("muỗng canh").
class Quantity {
  const Quantity(this.value, this.unit, [this.text]);

  final double? value;
  final IngredientUnit? unit;
  final String? text;

  @override
  bool operator ==(Object other) =>
      other is Quantity &&
      other.value == value &&
      other.unit == unit &&
      other.text == text;

  @override
  int get hashCode => Object.hash(value, unit, text);

  @override
  String toString() => 'Quantity($value $unit "${text ?? ''}")';
}

/// Loại đơn vị: hai số lượng cùng loại thì cộng được (AC-35).
enum UnitClass { mass, volume, count }

/// Khóa loại đơn vị: khối lượng, thể tích, hoặc riêng từng đơn vị đếm
/// (củ, quả, chén, thìa...); không đơn vị là một loại riêng.
Object unitClassOf(IngredientUnit? unit) {
  if (unit == null) return UnitClass.count;
  if (_gPer.containsKey(unit)) return UnitClass.mass;
  if (_mlPer.containsKey(unit)) return UnitClass.volume;
  return unit;
}

const _gPer = <IngredientUnit, double>{
  IngredientUnit.mg: 0.001,
  IngredientUnit.g: 1,
  IngredientUnit.kg: 1000,
  IngredientUnit.oz: 28.349523125,
  IngredientUnit.lb: 453.59237,
};
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
const _metric = {
  IngredientUnit.mg,
  IngredientUnit.g,
  IngredientUnit.kg,
  IngredientUnit.ml,
  IngredientUnit.l,
};

double _base(double v, IngredientUnit u) => v * (_gPer[u] ?? _mlPer[u]!);
double _fromBase(double v, IngredientUnit u) => v / (_gPer[u] ?? _mlPer[u]!);

/// Hai số lượng có gộp được thành một dòng không (AC-35).
bool canMerge(Quantity a, Quantity b) =>
    a.value == null ||
    b.value == null ||
    unitClassOf(a.unit) == unitClassOf(b.unit);

/// Cộng hai số lượng của cùng một món (AC-35); null nếu khác loại đơn vị
/// (khi đó để hai dòng). Không số lượng gộp với bất kỳ: giữ số lượng có sẵn.
///
/// Cùng đơn vị: cộng, giữ chữ đơn vị người dùng viết; g lên kg, ml lên l khi
/// từ 1000. Khác đơn vị cùng loại: đổi sang đơn vị lớn hơn trong hai đơn vị
/// (1 kg + 500 g = 1,5 kg; 1 lb + 8 oz = 1,5 lb); trộn hệ mét với hệ Mỹ thì
/// ra hệ mét.
Quantity? mergeQuantities(Quantity a, Quantity b) {
  if (a.value == null) return b;
  if (b.value == null) return a;
  if (!canMerge(a, b)) return null;
  final ua = a.unit;
  final ub = b.unit;
  if (ua == ub) {
    final sum = a.value! + b.value!;
    if (ua == IngredientUnit.g && sum >= 1000) {
      return Quantity(sum / 1000, IngredientUnit.kg, 'kg');
    }
    if (ua == IngredientUnit.ml && sum >= 1000) {
      return Quantity(sum / 1000, IngredientUnit.l, 'l');
    }
    return Quantity(sum, ua, a.text ?? b.text);
  }
  // Khác đơn vị nhưng cùng khối lượng hoặc thể tích.
  final total = _base(a.value!, ua!) + _base(b.value!, ub!);
  final IngredientUnit target;
  if (_metric.contains(ua) != _metric.contains(ub)) {
    final mass = _gPer.containsKey(ua);
    target = total >= 1000
        ? (mass ? IngredientUnit.kg : IngredientUnit.l)
        : (mass ? IngredientUnit.g : IngredientUnit.ml);
  } else {
    target = _base(1, ua) >= _base(1, ub) ? ua : ub;
  }
  return Quantity(_fromBase(total, target), target, unitLabel(target));
}

/// Chữ số lượng gọn: "500 g", "1 1/2 cup", "1,2 kg", "5 củ", "5"; không số
/// lượng thì chuỗi rỗng.
String formatQuantityText(Quantity q, {bool decimalComma = false}) {
  final v = q.value;
  if (v == null) return '';
  final number = formatQuantity(
    v,
    fractions: !_metric.contains(q.unit),
    decimalComma: decimalComma,
  );
  final label = (q.text?.trim().isNotEmpty ?? false)
      ? q.text!.trim()
      : (q.unit == null ? '' : unitLabel(q.unit!));
  return label.isEmpty ? number : '$number $label';
}
