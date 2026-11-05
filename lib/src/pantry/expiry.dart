/// Trạng thái hạn dùng của một món trong Tủ bếp (AC-42).
enum ExpiryStatus {
  /// Không ghi hạn dùng.
  none,

  /// Còn hơn [soonDays] ngày.
  fresh,

  /// Còn [soonDays] ngày hoặc ít hơn, kể cả hôm nay là ngày hết hạn.
  soon,

  /// Đã quá hạn (hạn dùng trước hôm nay).
  expired,
}

/// Số ngày còn lại tới hạn để coi là "Sắp hết hạn" (AC-42).
const soonDays = 3;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Số ngày từ hôm nay ([now]) tới [expires], theo ngày lịch (giờ không tính);
/// âm là đã quá hạn.
int daysLeft(DateTime expires, DateTime now) {
  // Dùng UTC để ngày đổi giờ mùa hè không làm lệch một giờ.
  final a = _day(now);
  final b = _day(expires);
  return DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}

/// Trạng thái của món có hạn dùng [expires] vào lúc [now] (AC-42).
ExpiryStatus expiryStatus(DateTime? expires, DateTime now) {
  if (expires == null) return ExpiryStatus.none;
  final left = daysLeft(expires, now);
  if (left < 0) return ExpiryStatus.expired;
  if (left <= soonDays) return ExpiryStatus.soon;
  return ExpiryStatus.fresh;
}
