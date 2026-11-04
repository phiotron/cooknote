import 'ingredient_parser.dart';

/// Nhân số lượng của một dòng nguyên liệu với [factor] (AC-32). Dòng không
/// `structured` được trả về nguyên vẹn, không bao giờ nhân hay đổi.
ParsedIngredient scaleIngredient(ParsedIngredient p, double factor) {
  if (!factor.isFinite || factor <= 0) {
    throw ArgumentError.value(factor, 'factor', 'phải là số dương');
  }
  if (!p.structured || p.quantity == null) return p;
  return ParsedIngredient(
    original: p.original,
    quantity: p.quantity! * factor,
    quantityMax: p.quantityMax == null ? null : p.quantityMax! * factor,
    unit: p.unit,
    unitText: p.unitText,
    name: p.name,
    note: p.note,
    structured: true,
  );
}

// Các phân số "hợp lý" để hiện trong bếp.
const _fractions = <(int, int)>[
  (1, 8),
  (1, 6),
  (1, 4),
  (1, 3),
  (3, 8),
  (1, 2),
  (5, 8),
  (2, 3),
  (3, 4),
  (5, 6),
  (7, 8),
];
const _fractionTolerance = 0.012;

/// Hiện một số lượng gọn: "1 1/2", "1/3", "375", "12.5"; không bao giờ có
/// dạng 0.33333 hay 1.0.
///
/// [fractions]=false dùng thập phân (cho g/ml/kg/l): 2 chữ số khi dưới 10,
/// 1 chữ số khi dưới 100, số nguyên khi từ 100. [decimalComma] dùng dấu
/// phẩy thập phân.
String formatQuantity(
  double v, {
  bool fractions = true,
  bool decimalComma = false,
}) {
  if (v.isNaN || v.isInfinite) return '0';
  if (v < 0) {
    return '-${formatQuantity(-v, fractions: fractions, decimalComma: decimalComma)}';
  }
  if (!fractions || v >= 10) return _decimal(v, decimalComma);

  final whole = v.floor();
  final frac = v - whole;
  var bestDiff = frac; // so với 0
  var bestNum = 0;
  var bestDen = 1;
  if (1 - frac < bestDiff) {
    bestDiff = 1 - frac;
    bestNum = 1;
    bestDen = 1;
  }
  for (final (n, d) in _fractions) {
    final diff = (frac - n / d).abs();
    if (diff < bestDiff) {
      bestDiff = diff;
      bestNum = n;
      bestDen = d;
    }
  }
  if (bestDiff > _fractionTolerance) return _decimal(v, decimalComma);
  if (bestNum == 0) return '$whole';
  if (bestNum == 1 && bestDen == 1) return '${whole + 1}';
  return whole == 0 ? '$bestNum/$bestDen' : '$whole $bestNum/$bestDen';
}

String _decimal(double v, bool comma) {
  final digits = v >= 100 ? 0 : (v >= 10 ? 1 : 2);
  var s = v.toStringAsFixed(digits);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  if (s.isEmpty || s == '-0') s = '0';
  return comma ? s.replaceFirst('.', ',') : s;
}

const _metricMeasures = {
  IngredientUnit.g,
  IngredientUnit.kg,
  IngredientUnit.mg,
  IngredientUnit.ml,
  IngredientUnit.l,
};

/// Ghép lại một dòng nguyên liệu: "1 1/2 cup sugar", "375 g bột",
/// "2 tbsp butter, melted". Dòng không `structured` trả về chữ gốc.
String formatIngredient(ParsedIngredient p, {bool decimalComma = false}) {
  if (!p.structured || p.quantity == null) return p.name;
  final fractions = !_metricMeasures.contains(p.unit);
  String f(double v) =>
      formatQuantity(v, fractions: fractions, decimalComma: decimalComma);
  final qty = p.isRange
      ? '${f(p.quantity!)}-${f(p.quantityMax!)}'
      : f(p.quantity!);
  final parts = [qty, if (p.unitText.isNotEmpty) p.unitText, p.name];
  final text = parts.join(' ');
  return p.note.isEmpty ? text : '$text, ${p.note}';
}
