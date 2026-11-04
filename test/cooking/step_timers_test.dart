import 'package:cooknote/src/cooking/step_timers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void one(String text, int seconds, String label) {
    final r = findTimers(text);
    expect(r.length, 1, reason: '$text -> $r');
    expect(r.single.seconds, seconds, reason: text);
    expect(r.single.label, label, reason: text);
    expect(text.substring(r.single.start, r.single.end), label, reason: text);
  }

  group('nhận ra thời gian (AC-27)', () {
    test('tiếng Việt', () {
      one('Nấu 15 phút cho mềm', 900, '15 phút');
      one('Hầm 1 tiếng 30 phút', 5400, '1 tiếng 30 phút');
      one('Ủ 1 giờ', 3600, '1 giờ');
      one('Nấu 10-15 phút', 900, '10-15 phút');
      one('Xào 30 giây', 30, '30 giây');
      one('Hầm 1,5 giờ', 5400, '1,5 giờ');
      one('Hầm 1 giờ 15 phút', 4500, '1 giờ 15 phút');
      one('Ủ 20 phut', 1200, '20 phut');
    });

    test('tiếng Anh', () {
      one('bake for 25 minutes', 1500, '25 minutes');
      one('Rest 1 hour', 3600, '1 hour');
      one('Proof 1 hr 15 min', 4500, '1 hr 15 min');
      one('Chill 2-3 hours', 10800, '2-3 hours');
      one('Roast 1h30', 5400, '1h30');
      one('Roast 1h', 3600, '1h');
      one('Simmer 1.5 hours', 5400, '1.5 hours');
      one('Rest 1/2 hour', 1800, '1/2 hour');
      one('Whisk 90 seconds', 90, '90 seconds');
      one('Cook 5 mins', 300, '5 mins');
    });

    test('nhiều hẹn giờ trong một bước, theo thứ tự', () {
      final r = findTimers('Ướp 30 phút, nướng 1 giờ 15 phút');
      expect(r.map((e) => e.seconds), [1800, 4500]);
      expect(r[0].end, lessThanOrEqualTo(r[1].start));
      final e = findTimers('Simmer 5 min then rest 10 min');
      expect(e.map((x) => x.seconds), [300, 600]);
    });

    test('phản ví dụ: không phải thời gian', () {
      expect(findTimers('Mua 1.500 phút gọi'), isEmpty);
      expect(findTimers('gọi 0912 345 678 phút'), isEmpty);
      expect(findTimers('Gọi số 0912345678'), isEmpty);
      expect(findTimers('Cho 2 củ hành vào'), isEmpty);
      expect(findTimers('Thêm 2 muỗng canh dầu'), isEmpty);
      expect(findTimers('Nướng ở 180°C'), isEmpty);
      expect(findTimers('3 cups minced garlic'), isEmpty);
      expect(findTimers('Rất nhanh, vài phút'), isEmpty);
      expect(findTimers(''), isEmpty);
    });
  });
}
