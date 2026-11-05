/// Một hẹn giờ đang chạy (AC-28).
class CookTimer {
  const CookTimer({
    required this.id,
    required this.name,
    required this.recipeId,
    required this.recipeName,
    required this.startedAt,
    required this.endsAt,
  });

  /// Số nguyên dương, cũng là mã thông báo đã lên lịch.
  final int id;

  /// Tên theo bước, ví dụ "Bước 3 · 15 phút".
  final String name;
  final int recipeId;
  final String recipeName;
  final DateTime startedAt;
  final DateTime endsAt;

  Duration remaining(DateTime now) {
    final d = endsAt.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  Duration get total => endsAt.difference(startedAt);
}

/// Bộ đếm nhiều hẹn giờ cùng lúc, KHÔNG phụ thuộc giao diện và đồng hồ thật:
/// người gọi đưa giờ hiện tại vào [start] và [tick] (test dùng đồng hồ giả).
class TimerEngine {
  final List<CookTimer> _running = [];
  int _nextId = 1;

  List<CookTimer> get running => List.unmodifiable(_running);

  bool get isEmpty => _running.isEmpty;

  /// Bắt đầu một hẹn giờ [seconds] giây kể từ [now].
  CookTimer start({
    required String name,
    required int recipeId,
    required String recipeName,
    required int seconds,
    required DateTime now,
  }) {
    if (seconds <= 0) throw ArgumentError.value(seconds, 'seconds');
    final t = CookTimer(
      id: _nextId++,
      name: name,
      recipeId: recipeId,
      recipeName: recipeName,
      startedAt: now,
      endsAt: now.add(Duration(seconds: seconds)),
    );
    _running.add(t);
    return t;
  }

  /// Hủy một hẹn giờ; false nếu không còn.
  bool cancel(int id) {
    final n = _running.length;
    _running.removeWhere((t) => t.id == id);
    return _running.length != n;
  }

  /// Gỡ và trả về các hẹn giờ đã tới hạn tại [now], theo thứ tự hết giờ.
  List<CookTimer> tick(DateTime now) {
    final done = [
      for (final t in _running)
        if (!t.endsAt.isAfter(now)) t,
    ]..sort((a, b) => a.endsAt.compareTo(b.endsAt));
    if (done.isNotEmpty) {
      _running.removeWhere((t) => !t.endsAt.isAfter(now));
    }
    return done;
  }
}

/// "05:00", "1:30:00".
String formatRemaining(Duration d) {
  final s = d.inSeconds + (d.inMilliseconds % 1000 > 0 ? 1 : 0);
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}
