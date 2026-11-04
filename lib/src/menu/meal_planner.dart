import 'dart:math';

/// Ngày dạng `YYYY-MM-DD` theo giờ địa phương, dùng làm khóa của bữa ăn
/// (cùng quy ước với cách lưu ngày ở các bảng khác).
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Bảy ngày của tuần chứa [day], bắt đầu từ [weekStart] (`DateTime.monday`
/// mặc định hoặc `DateTime.sunday`), lúc 00:00 (AC-38).
List<DateTime> weekDates(DateTime day, {int weekStart = DateTime.monday}) {
  final midnight = DateTime(day.year, day.month, day.day);
  final back = (midnight.weekday - weekStart + 7) % 7;
  final first = DateTime(midnight.year, midnight.month, midnight.day - back);
  return [
    for (var i = 0; i < 7; i++)
      DateTime(first.year, first.month, first.day + i),
  ];
}

/// Một công thức được xếp vào một bữa.
class MealAssignment {
  const MealAssignment({
    required this.date,
    required this.slotId,
    required this.recipeId,
  });

  final String date;
  final int slotId;
  final int recipeId;
}

/// Khóa một ô (ngày, bữa) trong tập `occupied`.
String slotKey(String date, int slotId) => '$date|$slotId';

/// Điền các bữa còn trống bằng công thức chọn ngẫu nhiên (AC-41).
///
/// - [recipeIds]: các công thức thỏa bộ lọc (người gọi đã lọc).
/// - [dates] và [slotIds]: các ô cần xét, theo thứ tự ngày rồi bữa.
/// - [occupied]: các ô đã có món (khóa từ [slotKey]) thì bỏ qua.
/// - [alreadyPlanned]: công thức đã có trong tuần, được tránh trước.
///
/// Không lặp một món trong cùng đợt nếu còn món khác: lấy lần lượt từ danh
/// sách đã xáo trộn; hết món mới thì xáo lại từ đầu (khi đó lặp là bắt buộc).
List<MealAssignment> suggestMeals({
  required List<int> recipeIds,
  required List<String> dates,
  required List<int> slotIds,
  Set<String> occupied = const {},
  Set<int> alreadyPlanned = const {},
  required Random random,
}) {
  if (recipeIds.isEmpty) return const [];
  final unique = recipeIds.toSet().toList();

  /// Hàng đợi: món chưa dùng trong tuần trước, món đã có trong tuần sau.
  List<int> refill() {
    final fresh = unique.where((id) => !alreadyPlanned.contains(id)).toList()
      ..shuffle(random);
    final used = unique.where(alreadyPlanned.contains).toList()
      ..shuffle(random);
    return [...fresh, ...used];
  }

  var queue = refill();
  final out = <MealAssignment>[];
  for (final date in dates) {
    for (final slot in slotIds) {
      if (occupied.contains(slotKey(date, slot))) continue;
      if (queue.isEmpty) queue = unique.toList()..shuffle(random);
      out.add(
        MealAssignment(date: date, slotId: slot, recipeId: queue.removeAt(0)),
      );
    }
  }
  return out;
}

/// Một mục của thực đơn mẫu (AC-39): [dayOffset] là số ngày kể từ ngày bắt
/// đầu (0 là ngày đầu). Có công thức hoặc chữ tự do (ví dụ "Ăn ngoài").
class TemplateEntry {
  const TemplateEntry({
    required this.dayOffset,
    required this.slotId,
    this.recipeId,
    this.freeText,
    this.servings,
  });

  final int dayOffset;
  final int slotId;
  final int? recipeId;
  final String? freeText;
  final double? servings;
}

/// Mục thực đơn đã đặt vào một ngày cụ thể.
class PlacedEntry {
  const PlacedEntry({
    required this.date,
    required this.slotId,
    this.recipeId,
    this.freeText,
    this.servings,
  });

  final String date;
  final int slotId;
  final int? recipeId;
  final String? freeText;
  final double? servings;
}

/// Áp một thực đơn mẫu vào ngày bắt đầu [start] (một ngày hoặc một tuần),
/// bỏ mục không có cả công thức lẫn chữ (AC-39).
List<PlacedEntry> applyTemplate(List<TemplateEntry> entries, DateTime start) {
  final base = DateTime(start.year, start.month, start.day);
  return [
    for (final e in entries)
      if (e.recipeId != null || (e.freeText?.trim().isNotEmpty ?? false))
        PlacedEntry(
          date: dateKey(
            DateTime(base.year, base.month, base.day + e.dayOffset),
          ),
          slotId: e.slotId,
          recipeId: e.recipeId,
          freeText: e.freeText,
          servings: e.servings,
        ),
  ];
}

/// Bỏ các mục rơi vào ô đã có món, để áp thực đơn mẫu không ghi đè.
List<PlacedEntry> withoutOccupied(
  List<PlacedEntry> placed,
  Set<String> occupied,
) => [
  for (final p in placed)
    if (!occupied.contains(slotKey(p.date, p.slotId))) p,
];
