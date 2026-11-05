import '../cooking/scaling.dart';
import '../cooking/ingredient_parser.dart';
import 'item_text.dart';
import 'name_match.dart';
import 'quantity_merge.dart';

/// Một nguyên liệu ở bước "chọn nguyên liệu thêm vào đi chợ" (AC-35, AC-40).
/// [selected] mặc định true, trừ món đang có trong Tủ bếp ([inPantry]).
class ShoppingCandidate {
  const ShoppingCandidate({
    required this.name,
    this.quantity = const Quantity(null, null),
    this.amountText,
    this.note,
    this.recipeId,
    this.recipeName,
    this.selected = true,
    this.inPantry = false,
  });

  final String name;
  final Quantity quantity;
  final String? amountText;
  final String? note;

  /// Công thức nguồn (AC-35); null với món gõ tay.
  final int? recipeId;
  final String? recipeName;
  final bool selected;
  final bool inPantry;

  ShoppingCandidate copyWith({bool? selected, Quantity? quantity}) =>
      ShoppingCandidate(
        name: name,
        quantity: quantity ?? this.quantity,
        amountText: amountText,
        note: note,
        recipeId: recipeId,
        recipeName: recipeName,
        selected: selected ?? this.selected,
        inPantry: inPantry,
      );

  String label({bool decimalComma = false}) => itemLabel(
    name: name,
    quantity: quantity,
    amountText: amountText,
    note: note,
    decimalComma: decimalComma,
  );

  @override
  String toString() =>
      'ShoppingCandidate($name, $quantity, selected=$selected, '
      'recipe=$recipeId)';
}

/// Hệ số nhân khẩu phần: [wanted] / [base] khi cả hai dương, không thì 1.
double servingsFactor(double? wanted, double? base) =>
    wanted != null && base != null && wanted > 0 && base > 0
    ? wanted / base
    : 1;

/// Các nguyên liệu của một công thức để chọn thêm vào đi chợ (AC-35):
/// nhân theo [factor] (khẩu phần đang chọn), bỏ tiêu đề nhóm và dòng trống,
/// bỏ chọn món đang có trong Tủ bếp ([pantryNames]). Ghi chú cách sơ chế
/// ("thái mỏng") không đi theo.
List<ShoppingCandidate> candidatesFromLines({
  required List<String> lines,
  int? recipeId,
  String? recipeName,
  double factor = 1,
  List<String> pantryNames = const [],
}) {
  final out = <ShoppingCandidate>[];
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    final item = parseItemText(line, keepNote: false);
    if (item.name.isEmpty) continue;
    var quantity = item.quantity;
    if (quantity.value != null && factor != 1) {
      final scaled = scaleIngredient(
        ParsedIngredient(
          original: line,
          quantity: quantity.value,
          unit: quantity.unit,
          name: item.name,
          structured: true,
        ),
        factor,
      );
      quantity = Quantity(scaled.quantity, quantity.unit, quantity.text);
    }
    final owned = pantryNames.any((p) => pantryCovers(p, item.name));
    out.add(
      ShoppingCandidate(
        name: item.name,
        quantity: quantity,
        amountText: item.amountText,
        recipeId: recipeId,
        recipeName: recipeName,
        selected: !owned,
        inPantry: owned,
      ),
    );
  }
  return out;
}

/// Gộp sẵn các ứng viên trùng tên, cùng loại đơn vị (để xem trước AC-40
/// gọn hơn). Thứ tự giữ theo lần xuất hiện đầu. Nguồn công thức của món gộp
/// là của món đầu; khi thêm vào danh sách, kho đi chợ ghi đủ mọi nguồn.
List<ShoppingCandidate> mergeCandidates(List<ShoppingCandidate> list) {
  final out = <ShoppingCandidate>[];
  for (final c in list) {
    final i = out.indexWhere(
      (o) =>
          namesMatch(o.name, c.name) &&
          canMerge(o.quantity, c.quantity) &&
          o.recipeId == c.recipeId,
    );
    if (i < 0) {
      out.add(c);
      continue;
    }
    final merged = mergeQuantities(out[i].quantity, c.quantity)!;
    out[i] = out[i].copyWith(
      quantity: merged,
      selected: out[i].selected || c.selected,
    );
  }
  return out;
}
