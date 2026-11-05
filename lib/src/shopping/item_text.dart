import '../cooking/ingredient_parser.dart';
import 'quantity_merge.dart';

/// Một món đi chợ hoặc trong Tủ bếp tách từ chữ người dùng gõ hoặc từ dòng
/// nguyên liệu: tên, số lượng có cấu trúc, hoặc số lượng dạng chữ.
class ItemText {
  const ItemText({
    required this.name,
    this.quantity = const Quantity(null, null),
    this.amountText,
    this.note,
  });

  final String name;
  final Quantity quantity;

  /// Số lượng không tách được ("1 bó nhỏ"); null khi có [quantity] hoặc
  /// không ghi.
  final String? amountText;
  final String? note;
}

final _vagueLead = RegExp(
  r'^(?:một ít|1 ít|ít|một chút|chút|a pinch of|pinch of|a little|some|a few)\s+',
  caseSensitive: false,
);
final _vagueTail = RegExp(
  r'\s+(?:vừa ăn|tùy khẩu vị|tuỳ khẩu vị|tùy thích|tuỳ thích|to taste|as needed|optional)$',
  caseSensitive: false,
);
final _spaces = RegExp(r'\s+');

/// Tên món gọn từ phần tên của một dòng: bỏ phần sau dấu phẩy, trong ngoặc,
/// và các cụm không phải tên ("vừa ăn", "một ít", "to taste").
String cleanItemName(String raw) {
  var s = raw.trim();
  final cut = s.indexOf(RegExp(r'[,(;]'));
  if (cut > 0) s = s.substring(0, cut);
  s = s.replaceAll(_spaces, ' ').trim();
  s = s.replaceFirst(_vagueLead, '').replaceFirst(_vagueTail, '').trim();
  return s.isEmpty ? raw.trim() : s;
}

/// Tách một dòng ("500 g thịt bò", "2-3 củ hành", "muối vừa ăn") thành món.
/// Khoảng "2-3" lấy số lớn (mua đủ). Không tách được số lượng thì cả dòng là
/// tên, đã làm gọn bằng [cleanItemName].
ItemText parseItemText(String line, {bool keepNote = true}) {
  final p = parseIngredient(line.trim());
  if (!p.structured || p.quantity == null || p.name.trim().isEmpty) {
    final raw = line.trim();
    final cut = raw.indexOf(RegExp(r'[,(]'));
    final note = cut > 0
        ? raw.substring(cut + 1).replaceAll(RegExp(r'[)]'), '').trim()
        : '';
    return ItemText(
      name: cleanItemName(raw),
      note: keepNote && note.isNotEmpty ? note : null,
    );
  }
  return ItemText(
    name: cleanItemName(p.name),
    quantity: Quantity(
      p.quantityMax ?? p.quantity,
      p.unit,
      p.unitText.isEmpty ? null : p.unitText,
    ),
    note: keepNote && p.note.isNotEmpty ? p.note : null,
  );
}

/// Tách riêng ô số lượng người dùng gõ ("500 g", "2 củ", "1 bó nhỏ"): tách
/// được thì [Quantity], không thì giữ chữ.
({Quantity quantity, String? amountText}) parseAmount(String? amount) {
  final t = amount?.trim() ?? '';
  if (t.isEmpty) {
    return (quantity: const Quantity(null, null), amountText: null);
  }
  final p = parseIngredient('$t x');
  if (p.structured && p.quantity != null && p.name.trim() == 'x') {
    return (
      quantity: Quantity(
        p.quantityMax ?? p.quantity,
        p.unit,
        p.unitText.isEmpty ? null : p.unitText,
      ),
      amountText: null,
    );
  }
  return (quantity: const Quantity(null, null), amountText: t);
}

/// Chữ số lượng để hiện: số lượng có cấu trúc, không thì chữ tự do.
String amountLabel(
  Quantity quantity,
  String? amountText, {
  bool decimalComma = false,
}) {
  final q = formatQuantityText(quantity, decimalComma: decimalComma);
  if (q.isNotEmpty) return q;
  return amountText?.trim() ?? '';
}

/// Một dòng hiện cho người dùng và khi chia sẻ: "500 g thịt bò",
/// "1 bó nhỏ rau muống", "sữa (không đường)".
String itemLabel({
  required String name,
  Quantity quantity = const Quantity(null, null),
  String? amountText,
  String? note,
  bool decimalComma = false,
}) {
  final amount = amountLabel(quantity, amountText, decimalComma: decimalComma);
  final base = amount.isEmpty ? name : '$amount $name';
  return (note?.trim().isNotEmpty ?? false) ? '$base (${note!.trim()})' : base;
}

/// Lưu [IngredientUnit] bằng tên để thứ tự enum đổi cũng không hỏng dữ liệu.
String? unitToDb(IngredientUnit? u) => u?.name;

IngredientUnit? unitFromDb(String? name) =>
    name == null ? null : IngredientUnit.values.asNameMap()[name];
