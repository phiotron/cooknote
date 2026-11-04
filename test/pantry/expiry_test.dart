import 'package:cooknote/src/pantry/expiry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 4, 15, 30);

  test('không hạn dùng thì không đánh dấu', () {
    expect(expiryStatus(null, now), ExpiryStatus.none);
  });

  test('còn 3 ngày trở xuống là sắp hết hạn, kể cả hôm nay', () {
    expect(expiryStatus(DateTime(2026, 11, 7), now), ExpiryStatus.soon);
    expect(expiryStatus(DateTime(2026, 11, 5), now), ExpiryStatus.soon);
    expect(expiryStatus(DateTime(2026, 11, 4), now), ExpiryStatus.soon);
  });

  test('còn hơn 3 ngày là còn hạn', () {
    expect(expiryStatus(DateTime(2026, 11, 8), now), ExpiryStatus.fresh);
  });

  test('quá hạn từ ngày hôm qua', () {
    expect(expiryStatus(DateTime(2026, 11, 3), now), ExpiryStatus.expired);
    expect(expiryStatus(DateTime(2025, 1, 1), now), ExpiryStatus.expired);
  });

  test('giờ trong ngày không ảnh hưởng', () {
    expect(
      expiryStatus(DateTime(2026, 11, 7, 23, 59), now),
      ExpiryStatus.soon,
    );
    expect(
      expiryStatus(DateTime(2026, 11, 3, 23, 59), now),
      ExpiryStatus.expired,
    );
  });

  test('daysLeft', () {
    expect(daysLeft(DateTime(2026, 11, 7), now), 3);
    expect(daysLeft(DateTime(2026, 11, 3), now), -1);
  });
}
