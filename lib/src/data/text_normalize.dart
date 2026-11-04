const _groups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵäåā',
  'e': 'èéẹẻẽêềếệểễëē',
  'i': 'ìíịỉĩîïī',
  'o': 'òóọỏõôồốộổỗơờớợởỡöøō',
  'u': 'ùúụủũưừứựửữûüū',
  'y': 'ỳýỵỷỹÿ',
  'd': 'đ',
  'c': 'ç',
  'n': 'ñ',
};

final Map<String, String> _fold = {
  for (final e in _groups.entries)
    for (final rune in e.value.runes) String.fromCharCode(rune): e.key,
};

final _combining = RegExp('[̀-ͯ]');
final _spaces = RegExp(r'\s+');

/// Hạ chữ thường, bỏ dấu (tiếng Việt và các dấu Latin thường gặp) và gộp
/// khoảng trắng, để tìm "pho bo" ra "Phở bò" (AC-12).
String normalizeText(String text) {
  final lower = text.toLowerCase().replaceAll(_combining, '');
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    out.write(_fold[ch] ?? ch);
  }
  return out.toString().replaceAll(_spaces, ' ').trim();
}

/// Các từ cần khớp khi tìm; bỏ ký tự đại diện của LIKE để không đổi nghĩa
/// câu truy vấn.
List<String> searchTerms(String text) {
  final cleaned = normalizeText(text).replaceAll(RegExp('[%_]'), ' ');
  return cleaned.split(' ').where((t) => t.isNotEmpty).toList();
}
