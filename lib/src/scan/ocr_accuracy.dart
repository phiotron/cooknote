/// Đo độ chính xác ký tự của OCR cho AC-25 (`docs/audits/OCR-RESEARCH-2026-11.md`
/// mục 5): độ chính xác = 1 − Levenshtein(chữ nhận, chữ chuẩn) / số ký tự chuẩn,
/// sau khi chuẩn hoá (dựng sẵn dấu tiếng Việt, gộp mọi khoảng trắng kể cả xuống
/// dòng thành một dấu cách). Bản [ignoreDiacritics] bỏ hết dấu để tách lỗi chữ
/// cái khỏi lỗi dấu. Phân biệt hoa thường.
library;

// Mỗi nguyên âm tiếng Việt và 6 thanh theo thứ tự: không, huyền, sắc, hỏi,
// ngã, nặng. Dart không có chuẩn hoá Unicode NFC sẵn, nên tự dựng bảng cho
// đúng các chữ tiếng Việt (chữ người dùng gõ trên máy Mac hay bộ gõ "Unicode
// tổ hợp" là dạng tách dấu, chữ Tesseract trả là dạng dựng sẵn).
const _vowels = {
  'a': ('a', 0),
  'ă': ('a', 0x0306),
  'â': ('a', 0x0302),
  'e': ('e', 0),
  'ê': ('e', 0x0302),
  'i': ('i', 0),
  'o': ('o', 0),
  'ô': ('o', 0x0302),
  'ơ': ('o', 0x031B),
  'u': ('u', 0),
  'ư': ('u', 0x031B),
  'y': ('y', 0),
};
const _toneRows = {
  'a': 'aàáảãạ',
  'ă': 'ăằắẳẵặ',
  'â': 'âầấẩẫậ',
  'e': 'eèéẻẽẹ',
  'ê': 'êềếểễệ',
  'i': 'iìíỉĩị',
  'o': 'oòóỏõọ',
  'ô': 'ôồốổỗộ',
  'ơ': 'ơờớởỡợ',
  'u': 'uùúủũụ',
  'ư': 'ưừứửữự',
  'y': 'yỳýỷỹỵ',
};
const _tones = [0, 0x0300, 0x0301, 0x0309, 0x0303, 0x0323];
const _qualityMarks = {0x0306, 0x0302, 0x031B};

// Chữ Latin có dấu khác (không thuộc tiếng Việt) khi bỏ dấu.
const _otherFold = {
  'đ': 'd', 'Đ': 'D', 'ç': 'c', 'Ç': 'C', 'ñ': 'n', 'Ñ': 'N', //
  'ä': 'a', 'Ä': 'A', 'ë': 'e', 'Ë': 'E', 'ï': 'i', 'Ï': 'I', //
  'ö': 'o', 'Ö': 'O', 'ü': 'u', 'Ü': 'U', 'ÿ': 'y', 'î': 'i', //
  'Î': 'I', 'û': 'u', 'Û': 'U', 'å': 'a', 'Å': 'A', 'ø': 'o', 'Ø': 'O',
};

typedef _Parts = ({int base, int quality, int tone});

final Map<int, _Parts> _decompose = _buildDecompose();
final Map<_Parts, int> _compose = {
  for (final e in _decompose.entries) e.value: e.key,
};

Map<int, _Parts> _buildDecompose() {
  final out = <int, _Parts>{};
  for (final upper in [false, true]) {
    for (final e in _toneRows.entries) {
      final (base, quality) = _vowels[e.key]!;
      final row = e.value.runes.toList();
      for (var t = 0; t < _tones.length; t++) {
        final ch = String.fromCharCode(row[t]);
        final b = upper ? base.toUpperCase() : base;
        final composed = upper ? ch.toUpperCase() : ch;
        if (quality == 0 && t == 0) continue; // chữ trơn: không cần bảng
        out[composed.runes.single] = (
          base: b.runes.single,
          quality: quality,
          tone: _tones[t],
        );
      }
    }
  }
  return out;
}

bool _isCombining(int rune) => rune >= 0x0300 && rune <= 0x036F;

final _spaces = RegExp(r'\s+');

/// Chuẩn hoá để so: dựng sẵn dấu tiếng Việt (mọi thứ tự dấu tách), gộp
/// khoảng trắng; [ignoreDiacritics] bỏ mọi dấu (đ thành d).
String normalizeForAccuracy(String text, {bool ignoreDiacritics = false}) {
  final out = StringBuffer();
  int? base;
  var quality = 0;
  var tone = 0;
  final extra = <int>[];

  void flush() {
    final b = base;
    if (b == null) return;
    if (ignoreDiacritics) {
      final ch = String.fromCharCode(b);
      out.write(_otherFold[ch] ?? ch);
    } else {
      final composed = extra.isEmpty
          ? (quality == 0 && tone == 0
                ? b
                : _compose[(base: b, quality: quality, tone: tone)])
          : null;
      if (composed != null) {
        out.writeCharCode(composed);
      } else {
        out.writeCharCode(b);
        if (quality != 0) out.writeCharCode(quality);
        if (tone != 0) out.writeCharCode(tone);
        extra.forEach(out.writeCharCode);
      }
    }
    base = null;
    quality = 0;
    tone = 0;
    extra.clear();
  }

  for (final rune in text.runes) {
    if (_isCombining(rune)) {
      if (base == null) {
        if (!ignoreDiacritics) out.writeCharCode(rune);
      } else if (_qualityMarks.contains(rune) && quality == 0) {
        quality = rune;
      } else if (_tones.contains(rune) && tone == 0) {
        tone = rune;
      } else {
        extra.add(rune);
      }
      continue;
    }
    flush();
    final parts = _decompose[rune];
    if (parts != null) {
      base = parts.base;
      quality = parts.quality;
      tone = parts.tone;
    } else {
      base = rune;
    }
  }
  flush();
  return out.toString().replaceAll(_spaces, ' ').trim();
}

/// Khoảng cách Levenshtein theo ký tự (rune).
int levenshtein(String a, String b) {
  final x = a.runes.toList();
  final y = b.runes.toList();
  if (x.isEmpty) return y.length;
  if (y.isEmpty) return x.length;
  var prev = List<int>.generate(y.length + 1, (j) => j);
  var cur = List<int>.filled(y.length + 1, 0);
  for (var i = 1; i <= x.length; i++) {
    cur[0] = i;
    for (var j = 1; j <= y.length; j++) {
      final sub = prev[j - 1] + (x[i - 1] == y[j - 1] ? 0 : 1);
      final del = prev[j] + 1;
      final ins = cur[j - 1] + 1;
      cur[j] = sub < del ? (sub < ins ? sub : ins) : (del < ins ? del : ins);
    }
    final t = prev;
    prev = cur;
    cur = t;
  }
  return prev[y.length];
}

/// Độ chính xác ký tự 0..1 của [recognized] so với [reference] (AC-25).
/// Âm (nhận ra nhiều rác hơn số ký tự chuẩn) được chặn về 0.
double characterAccuracy(
  String recognized,
  String reference, {
  bool ignoreDiacritics = false,
}) {
  final ref = normalizeForAccuracy(
    reference,
    ignoreDiacritics: ignoreDiacritics,
  );
  final got = normalizeForAccuracy(
    recognized,
    ignoreDiacritics: ignoreDiacritics,
  );
  final n = ref.runes.length;
  if (n == 0) return got.isEmpty ? 1 : 0;
  final acc = 1 - levenshtein(got, ref) / n;
  return acc < 0 ? 0 : acc;
}
