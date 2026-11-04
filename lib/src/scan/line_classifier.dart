import '../data/text_normalize.dart';

/// Vai trò của một dòng chữ nhận được từ ảnh công thức.
enum LineRole { title, ingredient, step, heading, note, noise }

/// Một dòng đã được gợi ý vai trò. [text] là chữ đã làm sạch (bỏ ký tự rác,
/// gạch đầu dòng, số thứ tự của bước, sửa l/O trong số lượng); [confidence]
/// từ 0 đến 1 để màn gán dòng tô nhạt những dòng đáng ngờ. Người dùng sẽ sửa
/// tay, nên đây chỉ là gợi ý ban đầu.
class ClassifiedLine {
  const ClassifiedLine(this.text, this.role, this.confidence);

  final String text;
  final LineRole role;
  final double confidence;

  @override
  String toString() => 'ClassifiedLine(${role.name}, $text, $confidence)';
}

enum _Section { none, ingredient, step, note }

// Ký tự giữ lại; mọi ký tự khác (| _ ~ « » © ...) là rác do OCR.
final _junk = RegExp(
  r'''[^\p{L}\p{N}\p{M}\s.,;:!?()/%°'"\-–•*·&+]''',
  unicode: true,
);
final _spaces = RegExp(r'\s+');
final _leadBullet = RegExp(r'^[\s\-–•*·]+');
final _pageNumber = RegExp(
  r'^(?:(?:trang|page|p)\.?\s*)?\d{1,3}(?:\s*/\s*\d{1,3})?$',
  caseSensitive: false,
);
// "Bước 2:" "Step 3" hoặc "1." "2)" "l." ở đầu bước. Chữ số trần phải có
// dấu chấm/ngoặc và không dính chữ số sau (để "1.5 kg" không bị nuốt).
final _stepPrefix = RegExp(
  r'^(?:(b[^\s\d]{1,5}c|step)\s*(\d+|[lI])\s*[.):\-]?|(\d+|[lI])\s*[.)](?!\d))\s*',
  caseSensitive: false,
  unicode: true,
);
final _quantity = RegExp(
  r'^(?:\d+\s+\d/\d|\d+(?:[.,]\d+)?(?:\s*/\s*\d+)?|[½¼¾⅓⅔⅛])'
  r'(?:\s*[-–]\s*\d+(?:[.,]\d+)?)?',
);
final _numberToken = RegExp(r'^[0-9OolI,./]*\d[0-9OolI,./]*$');
final _letterToken = RegExp(r'^[OolI]{1,3}$');
final _firstWord = RegExp(r'^\p{L}+', unicode: true);
final _meta = RegExp(
  r'^(?:serves|servings|serving|yield|yields|prep time|cook time|total time|'
  r'prep|thoi gian|khau phan|so nguoi|phuc vu)\b',
);

// Đơn vị và từ chỉ lượng, viết không dấu (so sánh qua normalizeText).
const _units = {
  'g',
  'gr',
  'gram',
  'grams',
  'kg',
  'mg',
  'ml',
  'l',
  'lit',
  'cl',
  'dl',
  'muong',
  'thia',
  'chen',
  'bat',
  'cu',
  'qua',
  'trai',
  'tep',
  'nhanh',
  'lat',
  'mieng',
  'cong',
  'bo',
  'con',
  'cai',
  'hop',
  'goi',
  'it',
  'chut',
  'nam',
  'tsp',
  'tbsp',
  'cup',
  'cups',
  'tablespoon',
  'tablespoons',
  'teaspoon',
  'teaspoons',
  'oz',
  'lb',
  'lbs',
  'pound',
  'pounds',
  'ounce',
  'ounces',
  'pinch',
  'clove',
  'cloves',
  'can',
  'cans',
  'slice',
  'slices',
  'stick',
  'sticks',
  'piece',
  'pieces',
  'pkg',
  'package',
  'dash',
  'bunch',
};

// Tiêu đề nhóm, đã qua _foldKey (không dấu, l/1 thành i, 0 thành o).
final _ingredientHeads = _foldAll([
  'nguyen lieu',
  'thanh phan',
  'ingredients',
  'ingredient',
]);
final _stepHeads = _foldAll([
  'cach lam',
  'cac buoc',
  'cac buoc thuc hien',
  'buoc thuc hien',
  'thuc hien',
  'huong dan',
  'huong dan thuc hien',
  'cach thuc hien',
  'directions',
  'direction',
  'method',
  'instructions',
  'instruction',
  'steps',
  'preparation',
]);
final _noteHeads = _foldAll([
  'ghi chu',
  'luu y',
  'meo',
  'meo nho',
  'notes',
  'note',
  'tips',
  'tip',
]);

Set<String> _foldAll(List<String> keys) => keys.map(_foldKey).toSet();

/// Không dấu, chữ thường, và gộp các cặp OCR hay nhầm (l, 1 thành i; 0 thành
/// o) để "Nguyên Iiệu" và "Ingredlents" vẫn khớp.
String _foldKey(String text) =>
    normalizeText(text).replaceAll(RegExp('[l1|]'), 'i').replaceAll('0', 'o');

int _distance(String a, String b) {
  var prev = List<int>.generate(b.length + 1, (j) => j);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      cur[j] = [
        prev[j] + 1,
        cur[j - 1] + 1,
        prev[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return prev[b.length];
}

bool _matchesHead(String key, Set<String> heads) {
  if (heads.contains(key)) return true;
  // Cho sai một ký tự, nhưng chỉ với tiêu đề đủ dài để khỏi nhầm từ ngắn.
  return key.length >= 6 && heads.any((h) => _distance(key, h) <= 1);
}

/// Vai trò của tiêu đề nhóm nếu [line] là tiêu đề, ngược lại null.
_Section? _headingSection(String line) {
  final stripped = line
      .replaceAll(RegExp(r'\(.*?\)'), ' ')
      .replaceAll(RegExp(r'[:.\s]+$'), '')
      .trim();
  if (stripped.isEmpty || stripped.length > 40) return null;
  if (stripped.split(' ').length > 5) return null;
  final key = _foldKey(stripped);
  if (_matchesHead(key, _ingredientHeads)) return _Section.ingredient;
  if (_matchesHead(key, _stepHeads)) return _Section.step;
  if (_matchesHead(key, _noteHeads)) return _Section.note;
  return null;
}

bool _isUnit(String word) => _units.contains(normalizeText(word));

/// Sửa l/I/O thành 1/0 ở token số lượng đầu dòng: "O,5" thành "0,5", "l củ"
/// thành "1 củ" (chỉ khi token kế là đơn vị, để khỏi đổi chữ thật).
String _fixQuantity(String text) {
  final m = RegExp(r'^(\S+)(\s+)?(\S+)?').firstMatch(text);
  if (m == null) return text;
  final token = m.group(1)!;
  final fixed = token
      .replaceAll(RegExp('[Oo]'), '0')
      .replaceAll(RegExp('[lI]'), '1');
  if (_numberToken.hasMatch(token)) {
    return fixed + text.substring(token.length);
  }
  final next = m.group(3);
  if (_letterToken.hasMatch(token) && next != null && _isUnit(_trimEnd(next))) {
    return fixed + text.substring(token.length);
  }
  return text;
}

String _trimEnd(String word) => word.replaceAll(RegExp(r'[.,;:]+$'), '');

/// 0 = không phải dòng nguyên liệu, 1 = có số lượng, 2 = số lượng và đơn vị.
int _quantityLevel(String text) {
  final m = _quantity.firstMatch(text);
  if (m == null) return 0;
  final rest = text.substring(m.end).trimLeft();
  final word = _firstWord.firstMatch(rest)?.group(0);
  if (word != null && _isUnit(word)) return 2;
  final words = text.split(' ').length;
  return words <= 8 && !text.endsWith('.') ? 1 : 0;
}

bool _titleLike(String text) =>
    text.length <= 60 &&
    text.split(' ').length <= 10 &&
    !RegExp(r'[.,;]$').hasMatch(text);

/// Gợi ý vai trò cho từng dòng chữ OCR, theo thứ tự đầu vào. Dòng trống bị
/// bỏ. Quy tắc đơn giản, đoán được (vi và en):
/// - dòng rác, chỉ có số trang: [LineRole.noise];
/// - "Nguyên liệu/Ingredients", "Cách làm/Directions", "Ghi chú/Notes":
///   [LineRole.heading] và đổi nhóm cho các dòng sau;
/// - trước mọi tiêu đề nhóm: dòng ngắn đầu tiên là tên; dòng bắt đầu bằng số
///   lượng là nguyên liệu; dòng có số thứ tự là bước;
/// - sau tiêu đề nhóm: dòng thuộc nhóm đó; dòng có số thứ tự hoặc "Bước N"
///   chuyển sang bước (phòng khi OCR bỏ sót tiêu đề "Cách làm").
List<ClassifiedLine> classifyRecipeLines(List<String> ocrLines) {
  final out = <ClassifiedLine>[];
  var section = _Section.none;
  var seenTitle = false;
  var seenContent = false;

  for (final raw in ocrLines) {
    final original = raw.trim();
    if (original.isEmpty) continue;

    final cleaned = original.replaceAll(_junk, ' ').replaceAll(_spaces, ' ');
    final body = cleaned.replaceFirst(_leadBullet, '').trim();

    // Rác: không còn chữ/số, quá ít chữ so với ký tự lạ, hoặc số trang.
    final alnum = RegExp(r'[\p{L}\p{N}]', unicode: true);
    final kept = alnum.allMatches(original).length;
    final visible = original.replaceAll(_spaces, '').length;
    if (body.isEmpty ||
        alnum.allMatches(body).length < 2 && !body.contains(RegExp(r'\d')) ||
        kept / visible < 0.5 ||
        _pageNumber.hasMatch(body)) {
      out.add(ClassifiedLine(original, LineRole.noise, 0.9));
      continue;
    }

    final head = _headingSection(body);
    if (head != null) {
      section = head;
      seenContent = true;
      out.add(
        ClassifiedLine(
          body.replaceAll(RegExp(r'[:.\s]+$'), ''),
          LineRole.heading,
          0.95,
        ),
      );
      continue;
    }

    if ((section == _Section.none || section == _Section.ingredient) &&
        _meta.hasMatch(normalizeText(body))) {
      out.add(ClassifiedLine(body, LineRole.note, 0.7));
      continue;
    }

    // Số thứ tự: bước, hoặc nguyên liệu đánh số ("1. 200 g bột").
    final sp = _stepPrefix.firstMatch(body);
    if (sp != null) {
      final rest = body.substring(sp.end).trim();
      final fixed = _fixQuantity(rest);
      final isBuoc = sp.group(1) != null;
      final listing =
          section == _Section.none || section == _Section.ingredient;
      if (!isBuoc && listing && _quantityLevel(fixed) > 0) {
        out.add(ClassifiedLine(fixed, LineRole.ingredient, 0.8));
      } else if (rest.isNotEmpty) {
        final sure = section == _Section.step;
        section = _Section.step;
        seenContent = true;
        out.add(ClassifiedLine(rest, LineRole.step, sure ? 0.9 : 0.7));
      } else {
        out.add(ClassifiedLine(original, LineRole.noise, 0.6));
      }
      continue;
    }

    switch (section) {
      case _Section.ingredient:
        final fixed = _fixQuantity(body);
        final level = _quantityLevel(fixed);
        if (level == 0 && body.endsWith('.') && body.split(' ').length > 10) {
          out.add(ClassifiedLine(body, LineRole.step, 0.5));
        } else {
          out.add(
            ClassifiedLine(
              fixed,
              LineRole.ingredient,
              level == 2 ? 0.9 : (level == 1 ? 0.8 : 0.7),
            ),
          );
        }
      case _Section.step:
        out.add(ClassifiedLine(body, LineRole.step, 0.75));
      case _Section.note:
        out.add(ClassifiedLine(body, LineRole.note, 0.7));
      case _Section.none:
        final fixed = _fixQuantity(body);
        final level = _quantityLevel(fixed);
        if (level > 0) {
          seenContent = true;
          out.add(
            ClassifiedLine(fixed, LineRole.ingredient, level == 2 ? 0.7 : 0.6),
          );
        } else if (!seenTitle && !seenContent && _titleLike(body)) {
          seenTitle = true;
          out.add(
            ClassifiedLine(body, LineRole.title, out.isEmpty ? 0.8 : 0.6),
          );
        } else {
          out.add(ClassifiedLine(body, LineRole.note, 0.4));
        }
    }
  }
  return out;
}
