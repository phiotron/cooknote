import 'dart:typed_data';

import '../data/recipe_repository.dart';
import '../data/text_normalize.dart';

/// Ảnh đọc từ file của app khác: tên gốc và byte JPEG/PNG đã kiểm chữ ký.
class ImportedPhoto {
  const ImportedPhoto(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}

/// Một công thức đọc từ file của app khác, chưa ghi vào cơ sở dữ liệu.
/// [draft.photos] để trống: việc lưu ảnh vào ImageStore và gán tên file do
/// bước ghép làm sau; [photos] giữ byte gốc.
class ImportedRecipe {
  const ImportedRecipe({
    required this.draft,
    required this.photos,
    required this.categoryNames,
    required this.dedupeKey,
    this.sourceUid,
    this.createdAt,
  });

  final RecipeDraft draft;
  final List<ImportedPhoto> photos;

  /// Tên danh mục ở app nguồn; bước ghép tự tìm hoặc tạo danh mục tương ứng.
  final List<String> categoryNames;

  /// Mã công thức ở app nguồn, nếu có.
  final String? sourceUid;
  final DateTime? createdAt;

  /// Khóa ổn định để nhập lại cùng một file không tạo bản trùng (AC-44):
  /// `<định dạng>:uid:<uid>` nếu có uid, không thì `<định dạng>:h:<băm>` của
  /// tên chuẩn hóa + nguồn.
  final String dedupeKey;
}

/// Kết quả nhập: số công thức nhập được, số bị bỏ và lý do (kể cả cảnh báo
/// như ảnh hỏng, công thức vẫn nhập).
class ImportReport {
  const ImportReport({
    required this.imported,
    required this.skipped,
    required this.reasons,
  });

  final int imported;
  final int skipped;
  final List<String> reasons;
}

class ImportResult {
  const ImportResult(this.recipes, this.report);

  final List<ImportedRecipe> recipes;
  final ImportReport report;
}

/// Cả file không đọc được (không phải zip, JSON hỏng, thiếu tệp chính).
class ImportFormatException implements Exception {
  const ImportFormatException(this.message);

  final String message;

  @override
  String toString() => 'ImportFormatException($message)';
}

/// Gom kết quả và lý do trong lúc đọc.
class ImportCollector {
  final recipes = <ImportedRecipe>[];
  final reasons = <String>[];
  var skipped = 0;

  void skip(String reason) {
    skipped++;
    reasons.add(reason);
  }

  void warn(String reason) => reasons.add(reason);

  ImportResult build() => ImportResult(
    recipes,
    ImportReport(
      imported: recipes.length,
      skipped: skipped,
      reasons: List.unmodifiable(reasons),
    ),
  );
}

/// Khóa nhập lại (xem [ImportedRecipe.dedupeKey]).
String buildDedupeKey(
  String format, {
  required String name,
  String? source,
  String? uid,
}) {
  final id = uid?.trim();
  if (id != null && id.isNotEmpty) return '$format:uid:$id';
  final text = '${normalizeText(name)}\u0001${normalizeText(source ?? '')}';
  return '$format:h:${_fnv(text, 0x811C9DC5)}${_fnv(text, 0x01000193 ^ 0x5bd1e995)}';
}

// FNV-1a 32 bit với hai hạt giống khác nhau, ghép lại thành 16 chữ số hex.
String _fnv(String text, int seed) {
  var h = seed & 0xFFFFFFFF;
  for (final unit in text.codeUnits) {
    h ^= unit;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h.toRadixString(16).padLeft(8, '0');
}

final _iso = RegExp(
  r'^P(?:(\d+)D)?(?:T(?:(\d+(?:[.,]\d+)?)H)?(?:(\d+(?:[.,]\d+)?)M)?(?:\d+(?:[.,]\d+)?S)?)?$',
  caseSensitive: false,
);
final _hours = RegExp(
  r'(\d+(?:[.,]\d+)?)\s*(?:h|hr|hrs|hour|hours|giờ|tiếng)',
  caseSensitive: false,
);
final _mins = RegExp(
  r'(\d+(?:[.,]\d+)?)\s*(?:m|min|mins|minute|minutes|phút)',
  caseSensitive: false,
);
final _hourMinute = RegExp(r'^\s*(\d+)\s*h\s*(\d+)\s*$', caseSensitive: false);

double _num(String s) => double.parse(s.replaceAll(',', '.'));

/// Đọc thời gian dạng "1 hr 15 min", "45", "1h30", "PT1H30M" ra số phút;
/// không hiểu thì null.
int? parseMinutes(String? text) {
  final t = text?.trim() ?? '';
  if (t.isEmpty) return null;
  final iso = _iso.firstMatch(t);
  if (iso != null && t.length > 1) {
    final d = iso.group(1) == null ? 0 : int.parse(iso.group(1)!);
    final h = iso.group(2) == null ? 0.0 : _num(iso.group(2)!);
    final m = iso.group(3) == null ? 0.0 : _num(iso.group(3)!);
    final total = (d * 1440 + h * 60 + m).round();
    return total > 0 ? total : null;
  }
  final hm = _hourMinute.firstMatch(t);
  if (hm != null) return int.parse(hm.group(1)!) * 60 + int.parse(hm.group(2)!);
  if (RegExp(r'^\d+(?:[.,]\d+)?$').hasMatch(t)) {
    final v = _num(t).round();
    return v > 0 ? v : null;
  }
  final h = _hours.firstMatch(t);
  final m = _mins.firstMatch(t);
  if (h == null && m == null) return null;
  final total =
      ((h == null ? 0 : _num(h.group(1)!) * 60) +
              (m == null ? 0 : _num(m.group(1)!)))
          .round();
  return total > 0 ? total : null;
}

/// Số phút -> ISO 8601 ("PT1H30M"); null hoặc <= 0 thì null.
String? formatIsoDuration(int? minutes) {
  if (minutes == null || minutes <= 0) return null;
  final h = minutes ~/ 60, m = minutes % 60;
  return 'PT${h > 0 ? '${h}H' : ''}${m > 0 ? '${m}M' : ''}';
}

final _firstNumber = RegExp(r'\d+(?:[.,]\d+)?');
final _unitTail = RegExp(r'([^\W\d_][^\d]*)$', unicode: true);

/// Tách "4 phần", "Serves 4-6 people", "2,5" thành (số đầu tiên, đơn vị).
/// Đơn vị là phần chữ ở cuối, null nếu không có.
(double?, String?) parseServings(String? text) {
  final t = text?.trim() ?? '';
  final n = _firstNumber.firstMatch(t);
  if (n == null) return (null, null);
  final value = _num(n.group(0)!);
  if (value <= 0) return (null, null);
  final tail = _unitTail.firstMatch(t.substring(n.end));
  final unit = tail?.group(1)?.trim();
  return (value, unit == null || unit.isEmpty ? null : unit);
}

/// JPEG hoặc PNG theo chữ ký đầu file.
bool looksLikeImage(List<int> b) {
  if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
    return true;
  }
  const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  if (b.length < png.length) return false;
  for (var i = 0; i < png.length; i++) {
    if (b[i] != png[i]) return false;
  }
  return true;
}

/// Chuỗi trống hoặc toàn khoảng trắng thành null.
String? blankToNull(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}
