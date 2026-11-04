/// Một khoảng thời gian tìm thấy trong chữ của bước (AC-27).
class StepTimer {
  const StepTimer({
    required this.start,
    required this.end,
    required this.seconds,
    required this.label,
  });

  /// Vị trí trong chuỗi: [start, end).
  final int start;
  final int end;

  /// Số giây; khoảng "10-15 phút" lấy số lớn.
  final int seconds;

  /// Chữ gốc, ví dụ "1 tiếng 30 phút".
  final String label;

  @override
  String toString() => 'StepTimer($start-$end, ${seconds}s, "$label")';
}

const _num = r'(\d+/\d+|\d+(?:[.,]\d+)*)';
const _units =
    r'(?:(giờ|gio|tiếng|tieng|hours?|hrs?|h)|(phút|phut|minutes?|mins?)|(giây|giay|seconds?|secs?))';
const _core = '$_num(?:\\s*[-–]\\s*$_num)?\\s*$_units(?!\\p{L})';

// Số không được dính chữ, dính số khác ("0912 345 678 phút", "1.500 phút").
final _first = RegExp(
  '(?<![\\p{L}\\d.,/]|\\d[-–]|\\d\\s)$_core',
  caseSensitive: false,
  unicode: true,
);
final _next = RegExp(
  '\\s*(?:,|and|và)?\\s*$_core',
  caseSensitive: false,
  unicode: true,
);
final _gluedMinutes = RegExp(r'(\d{1,2})(?![\d\p{L}])', unicode: true);

/// Giá trị của một số ("1,5", "1/2", "15"); null nếu trông như số lớn có dấu
/// phân cách hàng nghìn, số điện thoại...
double? _value(String raw) {
  if (raw.contains('/')) {
    final p = raw.split('/');
    final d = int.parse(p[1]);
    return d == 0 ? null : int.parse(p[0]) / d;
  }
  final parts = raw.split(RegExp(r'[.,]'));
  if (parts.length > 2) return null;
  if (parts.length == 2 && parts[1].length == 3) return null; // 1.500
  if (parts[0].length > 4) return null;
  return double.tryParse(raw.replaceFirst(',', '.'));
}

// 0 giờ, 1 phút, 2 giây.
int? _kind(Match m, int g) {
  for (var i = 0; i < 3; i++) {
    if (m[g + i] != null) return i;
  }
  return null;
}

const _mult = [3600, 60, 1];

/// Giá trị đã nhân số giây của một lần khớp, lấy số lớn nếu là khoảng.
double? _seconds(Match m, int kind) {
  final a = _value(m[1]!);
  final b = m[2] == null ? a : _value(m[2]!);
  if (a == null || b == null) return null;
  return (a > b ? a : b) * _mult[kind];
}

/// Nhận ra thời gian trong chữ của bước: "nấu 15 phút", "1 tiếng 30 phút",
/// "10-15 phút", "30 giây", "bake for 25 minutes", "1h30". Theo thứ tự xuất
/// hiện, không chồng nhau.
List<StepTimer> findTimers(String stepText) {
  final result = <StepTimer>[];
  var pos = 0;
  while (pos < stepText.length) {
    Match? m;
    for (final x in _first.allMatches(stepText, pos)) {
      m = x;
      break;
    }
    if (m == null) break;
    final kind = _kind(m, 3)!;
    final secs = _seconds(m, kind);
    if (secs == null) {
      pos = m.end;
      continue;
    }
    var total = secs;
    var end = m.end;
    var lastKind = kind;
    final unitText = m[3] ?? m[4] ?? m[5]!;
    var glueOk = unitText.toLowerCase() == 'h';
    while (lastKind < 2) {
      final n = _next.matchAsPrefix(stepText, end);
      if (n != null) {
        final k = _kind(n, 3)!;
        final s = _seconds(n, k);
        if (k > lastKind && s != null) {
          total += s;
          end = n.end;
          lastKind = k;
          glueOk = false;
          continue;
        }
      }
      if (glueOk) {
        final g = _gluedMinutes.matchAsPrefix(stepText, end);
        if (g != null && int.parse(g[1]!) < 60) {
          total += int.parse(g[1]!) * 60;
          end = g.end;
        }
      }
      break;
    }
    result.add(
      StepTimer(
        start: m.start,
        end: end,
        seconds: total.round(),
        label: stepText.substring(m.start, end),
      ),
    );
    pos = end;
  }
  return result;
}
