import '../data/text_normalize.dart';
import '../shopping/item_text.dart';
import '../shopping/name_match.dart';

/// Nguyên liệu của một công thức, mỗi dòng một chuỗi (không gồm tiêu đề nhóm).
class RecipeIngredients {
  const RecipeIngredients({
    required this.id,
    required this.name,
    required this.lines,
  });

  final int id;
  final String name;
  final List<String> lines;
}

/// Một công thức trong "Nấu được gì?" (AC-43).
class CookableRecipe {
  const CookableRecipe({
    required this.id,
    required this.name,
    required this.have,
    required this.total,
    required this.missing,
  });

  final int id;
  final String name;

  /// Số nguyên liệu đang có trong Tủ bếp.
  final int have;

  /// Số nguyên liệu được tính (đã bỏ gia vị cơ bản nếu bật tùy chọn).
  final int total;

  /// Tên các nguyên liệu còn thiếu, theo thứ tự trong công thức.
  final List<String> missing;

  int get missingCount => missing.length;
  double get ratio => total == 0 ? 0 : have / total;
}

// Gia vị cơ bản (AC-43): muối, đường, nước, tiêu, dầu ăn, nước mắm và các
// cách gọi thường gặp. So như [namesMatch]: không dấu khi tên gõ không dấu,
// có dấu khi tên có dấu (để "đậu" không bị coi là "dầu").
const _basicNames = [
  'muối',
  'muối ăn',
  'đường',
  'đường trắng',
  'nước',
  'nước lọc',
  'tiêu',
  'hạt tiêu',
  'tiêu xay',
  'dầu ăn',
  'dầu',
  'nước mắm',
  'salt',
  'table salt',
  'kosher salt',
  'sea salt',
  'sugar',
  'white sugar',
  'granulated sugar',
  'water',
  'pepper',
  'black pepper',
  'ground black pepper',
  'salt and pepper',
  'oil',
  'vegetable oil',
  'cooking oil',
  'canola oil',
  'fish sauce',
];
final Set<String> _basicsFolded = {for (final s in _basicNames) foldKey(s)};
final Set<String> _basicsAccented = {for (final s in _basicNames) accentKey(s)};

/// Có phải gia vị cơ bản không (AC-43).
bool isBasicStaple(String name) {
  final accented = accentKey(name);
  final folded = foldKey(name);
  return accented == folded
      ? _basicsFolded.contains(folded)
      : _basicsAccented.contains(accented);
}

/// Tên nguyên liệu của một dòng ("500 g thịt bò" → "thịt bò", "muối vừa
/// ăn" → "muối").
String ingredientName(String line) => parseItemText(line).name;

/// Xếp các công thức theo tỉ lệ nguyên liệu đang có trong Tủ bếp (AC-43):
/// tỉ lệ cao trước, rồi ít thiếu hơn, rồi theo tên. Bỏ công thức không có
/// nguyên liệu nào trong tủ. [ignoreBasics]: gia vị cơ bản không tính là
/// thiếu và không tính vào tổng.
List<CookableRecipe> rankCookable({
  required List<RecipeIngredients> recipes,
  required List<String> pantryNames,
  required bool ignoreBasics,
}) {
  final pantry = [
    for (final n in pantryNames)
      if (n.trim().isNotEmpty) n,
  ];
  final out = <CookableRecipe>[];
  for (final r in recipes) {
    var have = 0;
    var total = 0;
    final missing = <String>[];
    for (final line in r.lines) {
      final name = ingredientName(line);
      if (name.isEmpty) continue;
      final owned = pantry.any((p) => pantryCovers(p, name));
      if (!owned && ignoreBasics && isBasicStaple(name)) continue;
      total++;
      if (owned) {
        have++;
      } else {
        missing.add(name);
      }
    }
    if (have == 0) continue;
    out.add(
      CookableRecipe(
        id: r.id,
        name: r.name,
        have: have,
        total: total,
        missing: missing,
      ),
    );
  }
  out.sort((a, b) {
    final c = b.ratio.compareTo(a.ratio);
    if (c != 0) return c;
    final m = a.missingCount.compareTo(b.missingCount);
    if (m != 0) return m;
    return normalizeText(a.name).compareTo(normalizeText(b.name));
  });
  return out;
}
