import '../../../l10n/app_localizations.dart';

/// Thời gian gọn cho danh sách/chi tiết: 45 phút, 3 giờ, 3 giờ 30 phút.
String formatMinutes(AppLocalizations l, int minutes) {
  if (minutes < 60) return l.minutesShort(minutes);
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? l.durationHours(hours) : l.durationHM(hours, rest);
}

/// Số khẩu phần gọn: 4 thay vì 4.0.
String formatNumber(double value) =>
    value == value.roundToDouble() ? '${value.toInt()}' : '$value';

/// Hệ số gọn: ½×, 2×, 1,5×.
String formatFactor(double factor) {
  if (factor == 0.5) return '½×';
  if (factor == 1 / 3) return '⅓×';
  if (factor == 2 / 3) return '⅔×';
  if (factor == 0.25) return '¼×';
  if (factor == 0.75) return '¾×';
  return '${formatNumber(factor)}×';
}
