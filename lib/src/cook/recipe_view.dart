import '../cooking/ingredient_parser.dart';
import '../cooking/scaling.dart';
import '../cooking/unit_conversion.dart';
import '../data/recipe_lines.dart';
import '../data/recipe_repository.dart';

/// Cách đang XEM một công thức: hệ số nhân và hệ đơn vị (AC-32, AC-33).
/// Chỉ để xem; công thức gốc không đổi trừ khi người dùng bấm "Lưu theo
/// khẩu phần này".
class RecipeView {
  const RecipeView({this.factor = 1, this.units});

  final double factor;

  /// null là giữ đơn vị gốc.
  final UnitSystem? units;

  static const original = RecipeView();

  bool get isOriginal => factor == 1 && units == null;
  bool get isScaled => factor != 1;

  RecipeView withFactor(double f) => RecipeView(factor: f, units: units);
  RecipeView withUnits(UnitSystem? u) => RecipeView(factor: factor, units: u);

  @override
  bool operator ==(Object other) =>
      other is RecipeView && other.factor == factor && other.units == units;

  @override
  int get hashCode => Object.hash(factor, units);
}

/// Một dòng nguyên liệu để hiện.
class ViewLine {
  const ViewLine(this.text, {this.isHeading = false, this.cannotScale = false});

  final String text;
  final bool isHeading;

  /// Đang nhân khác 1 mà dòng không có cấu trúc: giữ nguyên và báo.
  final bool cannotScale;
}

List<ViewLine> ingredientsView(List<RecipeLine> lines, RecipeView view) {
  return [
    for (final line in lines)
      if (line.isHeading)
        ViewLine(line.text, isHeading: true)
      else if (view.isOriginal)
        ViewLine(line.text)
      else
        _transform(line.text, view),
  ];
}

ViewLine _transform(String text, RecipeView view) {
  final p = parseIngredient(text);
  if (!p.structured) {
    return ViewLine(text, cannotScale: view.isScaled);
  }
  var q = p;
  if (view.isScaled) q = scaleIngredient(q, view.factor);
  if (view.units != null) q = convertIngredient(q, view.units!);
  if (identical(q, p)) return ViewLine(text); // không có gì đổi
  return ViewLine(formatIngredient(q));
}

/// Các bước, nhiệt độ đổi theo hệ đơn vị đang chọn (AC-33).
List<RecipeLine> stepsView(List<RecipeLine> steps, RecipeView view) {
  final u = view.units;
  if (u == null) return steps;
  final to = u == UnitSystem.metric
      ? TemperatureSystem.celsius
      : TemperatureSystem.fahrenheit;
  return [
    for (final s in steps)
      s.isHeading
          ? s
          : RecipeLine(convertTemperaturesInText(s.text, to)),
  ];
}

/// Hệ số để từ [from] khẩu phần ra [to] khẩu phần; null nếu không hợp lệ.
double? factorFromServings(double? from, double to) {
  if (from == null || from <= 0 || !to.isFinite || to <= 0) return null;
  return to / from;
}

/// Đọc một hệ số người dùng gõ: "2", "1,5", "1/2", "1 1/2", "½". Dương và
/// không quá 100, nếu không thì null.
double? parseFactor(String input) {
  var t = input.trim().replaceAll('×', '').replaceAll('x', '').trim();
  if (t.isEmpty) return null;
  const vulgar = {'½': 0.5, '⅓': 1 / 3, '⅔': 2 / 3, '¼': 0.25, '¾': 0.75};
  double? v;
  if (vulgar.containsKey(t)) {
    v = vulgar[t];
  } else {
    final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(t);
    final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(t);
    if (mixed != null) {
      final d = int.parse(mixed[3]!);
      v = d == 0 ? null : int.parse(mixed[1]!) + int.parse(mixed[2]!) / d;
    } else if (frac != null) {
      final d = int.parse(frac[2]!);
      v = d == 0 ? null : int.parse(frac[1]!) / d;
    } else {
      v = double.tryParse(t.replaceFirst(',', '.'));
    }
  }
  if (v == null || !v.isFinite || v <= 0 || v > 100) return null;
  return v;
}

/// Bản nháp để lưu theo cách đang xem: nguyên liệu và khẩu phần đã nhân, bước
/// đổi nhiệt độ nếu đã chọn hệ đơn vị. Các phần khác giữ nguyên.
RecipeDraft scaledDraft(RecipeDraft d, RecipeView view) {
  final shown = ingredientsView(d.ingredients, view);
  final ingredients = [
    for (final (i, line) in d.ingredients.indexed)
      line.isHeading ? line : RecipeLine(shown[i].text),
  ];
  return RecipeDraft(
    name: d.name,
    servings: d.servings == null ? null : d.servings! * view.factor,
    servingsUnit: d.servingsUnit,
    prepMinutes: d.prepMinutes,
    cookMinutes: d.cookMinutes,
    totalMinutes: d.totalMinutes,
    source: d.source,
    sourceUrl: d.sourceUrl,
    notes: d.notes,
    nutrition: d.nutrition,
    difficulty: d.difficulty,
    rating: d.rating,
    favorite: d.favorite,
    ingredients: ingredients,
    steps: stepsView(d.steps, view),
    photos: d.photos,
    categoryIds: d.categoryIds,
    tags: d.tags,
  );
}
