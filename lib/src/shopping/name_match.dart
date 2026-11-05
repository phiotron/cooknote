import '../data/text_normalize.dart';

final _spaces = RegExp(r'\s+');
final _punct = RegExp(r'''[.,;:!?()\[\]{}"'*]''');

/// Vài số nhiều bất quy tắc hay gặp trong bếp.
const _irregular = {
  'leaves': 'leaf',
  'loaves': 'loaf',
  'halves': 'half',
  'knives': 'knife',
  'potatoes': 'potato',
  'tomatoes': 'tomato',
};

/// Đưa một từ tiếng Anh về số ít theo quy tắc đơn giản, đủ cho tên nguyên
/// liệu: "tomatoes" → "tomato", "berries" → "berry", "peaches" → "peach",
/// "cheeses" → "cheese", "eggs" → "egg". Từ ngắn (≤ 3 chữ) và từ tận cùng
/// bằng "ss", "us", "is" giữ nguyên ("glass", "hummus", "gas").
///
/// "ie" ở cuối cũng thành "y" để "cookie" và "cookies" cùng một khóa (khóa chỉ
/// dùng để so, không hiện cho người dùng).
String singularWord(String w) {
  final irregular = _irregular[w];
  if (irregular != null) return irregular;
  if (w.length <= 3) return w;
  if (w.endsWith('ies')) return '${w.substring(0, w.length - 3)}y';
  if (w.endsWith('ie')) return '${w.substring(0, w.length - 2)}y';
  if (!w.endsWith('s')) return w;
  if (w.endsWith('ss') || w.endsWith('us') || w.endsWith('is')) return w;
  for (final suffix in const ['ches', 'shes', 'xes', 'zes', 'oes']) {
    if (w.endsWith(suffix)) return w.substring(0, w.length - 2);
  }
  if (w.endsWith('sses')) return w.substring(0, w.length - 2);
  return w.substring(0, w.length - 1);
}

String _clean(String text) =>
    text.toLowerCase().replaceAll(_punct, ' ').replaceAll(_spaces, ' ').trim();

String _singular(String words) =>
    words.split(' ').where((w) => w.isNotEmpty).map(singularWord).join(' ');

/// Khóa so khớp tên món: bỏ dấu, chữ thường, gộp khoảng trắng, đưa từ tiếng
/// Anh về số ít (AC-35, AC-43). Lưu ở cột `nameKey` để tìm nhanh.
String foldKey(String name) => _singular(normalizeText(_clean(name)));

/// Như [foldKey] nhưng GIỮ dấu tiếng Việt, để phân biệt "cá" với "cà",
/// "bò" với "bơ" khi cả hai phía đều viết có dấu.
String accentKey(String name) => _singular(_clean(name));

bool _hasAccents(String name) {
  final c = _clean(name);
  return normalizeText(c) != c;
}

/// Hai tên có phải cùng một món không (AC-35, AC-43). Không phân biệt dấu
/// khi một phía gõ không dấu ("thit bo" = "Thịt bò"); nếu cả hai phía đều có
/// dấu thì dấu phải khớp ("cá" ≠ "cà").
bool namesMatch(String a, String b) {
  if (foldKey(a) != foldKey(b)) return false;
  if (_hasAccents(a) && _hasAccents(b)) return accentKey(a) == accentKey(b);
  return true;
}

bool _containsWords(List<String> haystack, List<String> needle) {
  if (needle.isEmpty || needle.length > haystack.length) return false;
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    var ok = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        ok = false;
        break;
      }
    }
    if (ok) return true;
  }
  return false;
}

/// Món [have] (trong Tủ bếp) có đáp ứng nguyên liệu [need] không: cùng tên
/// ([namesMatch]), hoặc [need] chứa trọn cụm từ của [have] — "trứng" đáp ứng
/// "trứng gà", "egg" đáp ứng "large eggs". Tên một từ dưới 3 chữ cái ("cá",
/// "ớt") chỉ khớp nguyên tên, để tránh "cá" khớp "cà chua" khi gõ không dấu.
bool pantryCovers(String have, String need) {
  if (namesMatch(have, need)) return true;
  final h = foldKey(have).split(' ');
  if (h.length == 1 && h.single.length < 3) return false;
  if (!_containsWords(foldKey(need).split(' '), h)) return false;
  if (_hasAccents(have) && _hasAccents(need)) {
    return _containsWords(
      accentKey(need).split(' '),
      accentKey(have).split(' '),
    );
  }
  return true;
}
