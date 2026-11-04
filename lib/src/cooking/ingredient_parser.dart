import '../data/text_normalize.dart';

/// Đơn vị chuẩn của một dòng nguyên liệu (AC-31). Đơn vị đếm và đơn vị chỉ có
/// trong tiếng Việt (chén, bát, củ, quả...) không đổi được sang hệ khác.
enum IngredientUnit {
  g,
  kg,
  mg,
  ml,
  l,
  tbsp,
  tsp,

  /// "thìa"/"muỗng" đứng một mình: không biết canh hay cà phê, không đổi được.
  spoon,
  cup,
  chen,
  bat,
  oz,
  lb,
  flOz,
  pint,
  quart,
  cu,
  qua,
  trai,
  tep,
  nhanh,
  lat,
  mieng,
  goi,
  lon,
  hop,
  nhum,
  chut,
  nam,
  bo,
}

/// Nhãn gọn của đơn vị chuẩn, dùng khi đổi đơn vị.
String unitLabel(IngredientUnit u) => switch (u) {
  IngredientUnit.g => 'g',
  IngredientUnit.kg => 'kg',
  IngredientUnit.mg => 'mg',
  IngredientUnit.ml => 'ml',
  IngredientUnit.l => 'l',
  IngredientUnit.tbsp => 'tbsp',
  IngredientUnit.tsp => 'tsp',
  IngredientUnit.spoon => 'thìa',
  IngredientUnit.cup => 'cup',
  IngredientUnit.chen => 'chén',
  IngredientUnit.bat => 'bát',
  IngredientUnit.oz => 'oz',
  IngredientUnit.lb => 'lb',
  IngredientUnit.flOz => 'fl oz',
  IngredientUnit.pint => 'pint',
  IngredientUnit.quart => 'quart',
  IngredientUnit.cu => 'củ',
  IngredientUnit.qua => 'quả',
  IngredientUnit.trai => 'trái',
  IngredientUnit.tep => 'tép',
  IngredientUnit.nhanh => 'nhánh',
  IngredientUnit.lat => 'lát',
  IngredientUnit.mieng => 'miếng',
  IngredientUnit.goi => 'gói',
  IngredientUnit.lon => 'lon',
  IngredientUnit.hop => 'hộp',
  IngredientUnit.nhum => 'nhúm',
  IngredientUnit.chut => 'chút',
  IngredientUnit.nam => 'nắm',
  IngredientUnit.bo => 'bó',
};

/// Kết quả tách một dòng nguyên liệu. [structured]=false nghĩa là không tách
/// được số lượng: [name] giữ nguyên chữ gốc và dòng không được nhân hay đổi
/// đơn vị.
class ParsedIngredient {
  const ParsedIngredient({
    required this.original,
    this.quantity,
    this.quantityMax,
    this.unit,
    this.unitText = '',
    required this.name,
    this.note = '',
    required this.structured,
  });

  /// Dòng không tách được: giữ nguyên chữ.
  factory ParsedIngredient.plain(String line) {
    final t = line.trim();
    return ParsedIngredient(original: line, name: t, structured: false);
  }

  final String original;

  /// Số lượng (đầu nhỏ của khoảng); null nếu không structured.
  final double? quantity;

  /// Đầu lớn của khoảng "2-3"; null nếu chỉ có một số.
  final double? quantityMax;
  final IngredientUnit? unit;

  /// Chữ đơn vị như người dùng viết ("cups", "Tbsp", "muỗng canh").
  final String unitText;
  final String name;

  /// Phần sau dấu phẩy hoặc trong ngoặc.
  final String note;
  final bool structured;

  bool get isRange => quantityMax != null && quantityMax != quantity;

  ParsedIngredient copyWith({
    double? quantity,
    double? quantityMax,
    IngredientUnit? unit,
    String? unitText,
  }) => ParsedIngredient(
    original: original,
    quantity: quantity ?? this.quantity,
    quantityMax: quantityMax ?? this.quantityMax,
    unit: unit ?? this.unit,
    unitText: unitText ?? this.unitText,
    name: name,
    note: note,
    structured: structured,
  );

  @override
  String toString() =>
      'ParsedIngredient($quantity${quantityMax != null ? '-$quantityMax' : ''} '
      '$unit "$name" note="$note" structured=$structured)';
}

// Bảng đơn vị: khóa là cụm từ đã bỏ dấu, chữ thường, cách nhau một dấu cách.
// Số nhiều tiếng Anh tự bỏ "s" cuối khi tra.
const _unitTable = <String, IngredientUnit>{
  'g': IngredientUnit.g,
  'gr': IngredientUnit.g,
  'gram': IngredientUnit.g,
  'gam': IngredientUnit.g,
  'kg': IngredientUnit.kg,
  'kilogram': IngredientUnit.kg,
  'kilo': IngredientUnit.kg,
  'ky': IngredientUnit.kg,
  'ki': IngredientUnit.kg,
  'mg': IngredientUnit.mg,
  'ml': IngredientUnit.ml,
  'milliliter': IngredientUnit.ml,
  'millilitre': IngredientUnit.ml,
  'l': IngredientUnit.l,
  'lit': IngredientUnit.l,
  'liter': IngredientUnit.l,
  'litre': IngredientUnit.l,
  'muong canh': IngredientUnit.tbsp,
  'thia canh': IngredientUnit.tbsp,
  'tbsp': IngredientUnit.tbsp,
  'tbs': IngredientUnit.tbsp,
  'tbl': IngredientUnit.tbsp,
  'tablespoon': IngredientUnit.tbsp,
  'muong ca phe': IngredientUnit.tsp,
  'thia ca phe': IngredientUnit.tsp,
  'muong cafe': IngredientUnit.tsp,
  'thia cafe': IngredientUnit.tsp,
  'tsp': IngredientUnit.tsp,
  'teaspoon': IngredientUnit.tsp,
  'muong': IngredientUnit.spoon,
  'thia': IngredientUnit.spoon,
  'chen': IngredientUnit.chen,
  'bat': IngredientUnit.bat,
  'cup': IngredientUnit.cup,
  'oz': IngredientUnit.oz,
  'ounce': IngredientUnit.oz,
  'lb': IngredientUnit.lb,
  'pound': IngredientUnit.lb,
  'fl oz': IngredientUnit.flOz,
  'fluid ounce': IngredientUnit.flOz,
  'pint': IngredientUnit.pint,
  'pt': IngredientUnit.pint,
  'quart': IngredientUnit.quart,
  'qt': IngredientUnit.quart,
  'cu': IngredientUnit.cu,
  'qua': IngredientUnit.qua,
  'trai': IngredientUnit.trai,
  'tep': IngredientUnit.tep,
  'clove': IngredientUnit.tep,
  'nhanh': IngredientUnit.nhanh,
  'sprig': IngredientUnit.nhanh,
  'lat': IngredientUnit.lat,
  'slice': IngredientUnit.lat,
  'mieng': IngredientUnit.mieng,
  'piece': IngredientUnit.mieng,
  'goi': IngredientUnit.goi,
  'package': IngredientUnit.goi,
  'pkg': IngredientUnit.goi,
  'pack': IngredientUnit.goi,
  'packet': IngredientUnit.goi,
  'lon': IngredientUnit.lon,
  'can': IngredientUnit.lon,
  'hop': IngredientUnit.hop,
  'jar': IngredientUnit.hop,
  'box': IngredientUnit.hop,
  'nhum': IngredientUnit.nhum,
  'pinch': IngredientUnit.nhum,
  'chut': IngredientUnit.chut,
  'dash': IngredientUnit.chut,
  'nam': IngredientUnit.nam,
  'bo': IngredientUnit.bo,
  'bunch': IngredientUnit.bo,
};

const _vulgar = {
  '½': 0.5,
  '¼': 0.25,
  '¾': 0.75,
  '⅓': 1 / 3,
  '⅔': 2 / 3,
  '⅛': 0.125,
  '⅜': 0.375,
  '⅝': 0.625,
  '⅞': 0.875,
};
const _vulgarChars = '½¼¾⅓⅔⅛⅜⅝⅞';

// Một số lượng: hỗn số, số + ký tự phân số, phân số, thập phân, ký tự phân số.
const _numPattern =
    r'(?:\d+[\s\-]+\d+/\d+|\d+\s*[' +
    _vulgarChars +
    r']|\d+/\d+|\d+(?:[.,]\d+)?|[' +
    _vulgarChars +
    r'])';

final _leadingQty = RegExp(
  '^($_numPattern)(?:\\s*(?:-|–|—|to|đến|hoặc|hay|or)\\s*($_numPattern))?',
  caseSensitive: false,
);
final _trailingQty = RegExp(
  '^(.+?)(?:\\s*[:：]\\s*|\\s+)($_numPattern)\\s+'
  r'(\p{L}+(?:\s+\p{L}+){0,2})\.?$',
  unicode: true,
);
final _digitBeforeLetter = RegExp(
  '(?<=[\\d$_vulgarChars])(?=\\p{L})',
  unicode: true,
);
final _approxPrefix = RegExp(
  r'^(?:(?:about|approximately|approx\.?|around|khoảng|tầm|chừng)\s+|~\s*)',
  caseSensitive: false,
);
final _spaces = RegExp(r'\s+');
final _edgePunct = RegExp(r'^[.,;:]+|[.,;:]+$');

/// Giá trị của một chuỗi số đã khớp [_numPattern]; null nếu không hợp lệ.
double? _parseNumber(String raw) {
  final t = raw.trim();
  var m = RegExp(r'^(\d+)[\s\-]+(\d+)/(\d+)$').firstMatch(t);
  if (m != null) {
    final d = int.parse(m[3]!);
    if (d == 0) return null;
    return int.parse(m[1]!) + int.parse(m[2]!) / d;
  }
  m = RegExp('^(\\d+)\\s*([$_vulgarChars])\$').firstMatch(t);
  if (m != null) return int.parse(m[1]!) + _vulgar[m[2]]!;
  m = RegExp(r'^(\d+)/(\d+)$').firstMatch(t);
  if (m != null) {
    final d = int.parse(m[2]!);
    if (d == 0) return null;
    return int.parse(m[1]!) / d;
  }
  if (_vulgar.containsKey(t)) return _vulgar[t];
  return double.tryParse(t.replaceFirst(',', '.'));
}

String _normToken(String token) =>
    normalizeText(token).replaceAll(_edgePunct, '');

IngredientUnit? _lookupUnit(String phrase) {
  final direct = _unitTable[phrase];
  if (direct != null) return direct;
  if (phrase.length > 1 && phrase.endsWith('s')) {
    return _unitTable[phrase.substring(0, phrase.length - 1)];
  }
  if (phrase.endsWith('es')) {
    return _unitTable[phrase.substring(0, phrase.length - 2)];
  }
  return null;
}

/// Tìm đơn vị bắt đầu ở [tokens][start], ưu tiên cụm dài nhất.
({IngredientUnit unit, int count})? _matchUnit(List<String> tokens, int start) {
  for (var n = 3; n >= 1; n--) {
    if (start + n > tokens.length) continue;
    final phrase = tokens.sublist(start, start + n).map(_normToken).join(' ');
    final u = _lookupUnit(phrase);
    if (u != null) return (unit: u, count: n);
  }
  return null;
}

const _vague = {'it', 'vai', 'few', 'little', 'some'};

/// Tách phần ghi chú (trong ngoặc, sau dấu phẩy) khỏi phần chính.
({String main, String note}) _splitNote(String line) {
  final main = StringBuffer();
  final parts = <String>[];
  final paren = StringBuffer();
  var depth = 0;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '(') {
      depth++;
      if (depth == 1) {
        main.write(' ');
        continue;
      }
    } else if (ch == ')' && depth > 0) {
      depth--;
      if (depth == 0) {
        final t = paren.toString().trim();
        if (t.isNotEmpty) parts.add(t);
        paren.clear();
        main.write(' ');
        continue;
      }
    }
    if (depth > 0) {
      paren.write(ch);
      continue;
    }
    if (ch == ',') {
      final prevDigit = i > 0 && RegExp(r'\d').hasMatch(line[i - 1]);
      final nextDigit =
          i + 1 < line.length && RegExp(r'\d').hasMatch(line[i + 1]);
      if (!(prevDigit && nextDigit)) {
        final tail = line.substring(i + 1).trim();
        if (tail.isNotEmpty) parts.add(tail);
        break;
      }
    }
    main.write(ch);
  }
  return (main: main.toString(), note: parts.join(', '));
}

String _joinName(List<String> tokens, int from) {
  var start = from;
  if (start < tokens.length && _normToken(tokens[start]) == 'of') start++;
  return tokens.sublist(start).join(' ').trim();
}

String _unitDisplay(List<String> tokens, int start, int count) =>
    tokens.sublist(start, start + count).join(' ').replaceAll(_edgePunct, '');

/// Tách một dòng nguyên liệu thành số lượng, đơn vị, tên và ghi chú (AC-31).
///
/// Không tách được số lượng ("1 ít hành", "muối vừa ăn") thì trả về dòng
/// nguyên văn với `structured=false`.
ParsedIngredient parseIngredient(String line) {
  final plain = ParsedIngredient.plain(line);
  final split = _splitNote(line.trim());
  var main = split.main
      .replaceAll(_spaces, ' ')
      .trim()
      .replaceFirst(_approxPrefix, '')
      .replaceAll(_digitBeforeLetter, ' ');
  main = main.trim();
  if (main.isEmpty) return plain;

  ParsedIngredient build(
    double q,
    double? qMax,
    List<String> tokens,
    int unitStart,
    ({IngredientUnit unit, int count})? unit,
    int nameFrom,
  ) {
    final name = _joinName(tokens, nameFrom);
    if (name.isEmpty) return plain;
    return ParsedIngredient(
      original: line,
      quantity: q,
      quantityMax: qMax != null && qMax != q ? qMax : null,
      unit: unit?.unit,
      unitText: unit == null ? '' : _unitDisplay(tokens, unitStart, unit.count),
      name: name,
      note: split.note,
      structured: true,
    );
  }

  // 1. Số lượng ở đầu: "2 muỗng canh nước mắm", "2-3 tép tỏi".
  final lead = _leadingQty.firstMatch(main);
  if (lead != null) {
    final q1 = _parseNumber(lead[1]!);
    final q2 = lead[2] == null ? null : _parseNumber(lead[2]!);
    if (q1 == null || (lead[2] != null && q2 == null)) return plain;
    final rest = main
        .substring(lead.end)
        .trim()
        .replaceFirst(RegExp(r'^\.'), '');
    final tokens = rest.split(' ').where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return plain;
    if (_vague.contains(_normToken(tokens.first))) return plain;
    final unit = _matchUnit(tokens, 0);
    if (unit == null) return build(q1, q2, tokens, 0, null, 0);
    return build(q1, q2, tokens, 0, unit, unit.count);
  }

  final tokens = main.split(' ').where((t) => t.isNotEmpty).toList();

  // 2. "a pinch of salt", "một nhúm muối": mạo từ + đơn vị = 1.
  if (tokens.length > 1 &&
      const {'a', 'an', 'mot'}.contains(_normToken(tokens.first))) {
    final unit = _matchUnit(tokens, 1);
    if (unit != null) {
      return build(1, null, tokens, 1, unit, 1 + unit.count);
    }
  }

  // 3. Số lượng ở cuối, đơn vị phải biết rõ: "nước mắm 2 thìa", "hành lá: 1 nắm".
  final trail = _trailingQty.firstMatch(main);
  if (trail != null) {
    final q = _parseNumber(trail[2]!);
    final unitTokens = trail[3]!.split(_spaces);
    final unit = _matchUnit(unitTokens, 0);
    final name = trail[1]!.trim().replaceAll(_edgePunct, '').trim();
    if (q != null &&
        unit != null &&
        unit.count == unitTokens.length &&
        name.isNotEmpty) {
      return ParsedIngredient(
        original: line,
        quantity: q,
        unit: unit.unit,
        unitText: unitTokens.join(' '),
        name: name,
        note: split.note,
        structured: true,
      );
    }
  }
  return plain;
}
