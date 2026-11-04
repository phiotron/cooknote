import 'dart:math';

import 'package:cooknote/src/menu/meal_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dateKey và weekDates (AC-38)', () {
    test('dateKey dạng YYYY-MM-DD', () {
      expect(dateKey(DateTime(2026, 11, 4, 23, 59)), '2026-11-04');
      expect(dateKey(DateTime(2026, 1, 2)), '2026-01-02');
    });

    test('tuần bắt đầu từ thứ Hai, hoặc Chủ Nhật theo cài đặt', () {
      // 2026-11-04 là thứ Tư.
      expect(weekDates(DateTime(2026, 11, 4)).map(dateKey), [
        '2026-11-02',
        '2026-11-03',
        '2026-11-04',
        '2026-11-05',
        '2026-11-06',
        '2026-11-07',
        '2026-11-08',
      ]);
      expect(
        weekDates(
          DateTime(2026, 11, 4),
          weekStart: DateTime.sunday,
        ).map(dateKey).first,
        '2026-11-01',
      );
      // Chính ngày bắt đầu thuộc tuần của nó.
      expect(weekDates(DateTime(2026, 11, 2)).first, DateTime(2026, 11, 2));
      expect(weekDates(DateTime(2026, 11, 8)).first, DateTime(2026, 11, 2));
    });

    test('qua tháng và năm vẫn đúng', () {
      expect(weekDates(DateTime(2026, 12, 31)).map(dateKey), [
        '2026-12-28',
        '2026-12-29',
        '2026-12-30',
        '2026-12-31',
        '2027-01-01',
        '2027-01-02',
        '2027-01-03',
      ]);
    });
  });

  group('suggestMeals (AC-41)', () {
    final dates = ['2026-11-02', '2026-11-03'];
    const slots = [1, 2, 3];

    test('điền mọi bữa trống, mỗi ô một công thức', () {
      final r = suggestMeals(
        recipeIds: [1, 2, 3, 4, 5, 6, 7, 8],
        dates: dates,
        slotIds: slots,
        random: Random(1),
      );
      expect(r.length, 6);
      expect({for (final a in r) '${a.date}|${a.slotId}'}.length, 6);
    });

    test('không lặp món trong cùng tuần khi còn đủ món khác', () {
      for (var seed = 0; seed < 50; seed++) {
        final r = suggestMeals(
          recipeIds: [1, 2, 3, 4, 5, 6, 7],
          dates: dates,
          slotIds: slots,
          random: Random(seed),
        );
        expect(
          r.map((a) => a.recipeId).toSet().length,
          6,
          reason: 'seed $seed',
        );
      }
    });

    test('bỏ qua bữa đã có món và tránh món đã xếp trong tuần', () {
      final r = suggestMeals(
        recipeIds: [1, 2, 3, 4, 5],
        dates: dates,
        slotIds: slots,
        occupied: {'2026-11-02|1', '2026-11-03|3'},
        alreadyPlanned: {1, 2},
        random: Random(3),
      );
      expect(r.length, 4);
      expect(r.any((a) => a.date == '2026-11-02' && a.slotId == 1), isFalse);
      expect(r.any((a) => a.date == '2026-11-03' && a.slotId == 3), isFalse);
      // 3 món chưa dùng (3, 4, 5) cho 4 ô: ba ô đầu phải là các món chưa dùng.
      expect(r.take(3).map((a) => a.recipeId).toSet(), {3, 4, 5});
    });

    test('ít món hơn số ô thì phải lặp nhưng vẫn điền đủ', () {
      final r = suggestMeals(
        recipeIds: [10, 20],
        dates: dates,
        slotIds: slots,
        random: Random(7),
      );
      expect(r.length, 6);
      expect(r.map((a) => a.recipeId).toSet(), {10, 20});
    });

    test('không có công thức thì không xếp gì', () {
      expect(
        suggestMeals(
          recipeIds: [],
          dates: dates,
          slotIds: slots,
          random: Random(1),
        ),
        isEmpty,
      );
    });

    test('cùng hạt giống cho cùng kết quả, khác hạt giống thường khác', () {
      List<int> run(int seed) => suggestMeals(
        recipeIds: List.generate(20, (i) => i),
        dates: dates,
        slotIds: slots,
        random: Random(seed),
      ).map((a) => a.recipeId).toList();
      expect(run(5), run(5));
      expect(run(5), isNot(run(6)));
    });

    test('thứ tự kết quả theo ngày rồi theo bữa', () {
      final r = suggestMeals(
        recipeIds: [1, 2, 3, 4, 5, 6],
        dates: dates,
        slotIds: slots,
        random: Random(2),
      );
      expect(r.map((a) => '${a.date}|${a.slotId}'), [
        '2026-11-02|1',
        '2026-11-02|2',
        '2026-11-02|3',
        '2026-11-03|1',
        '2026-11-03|2',
        '2026-11-03|3',
      ]);
    });
  });

  group('applyTemplate (AC-39)', () {
    const entries = [
      TemplateEntry(dayOffset: 0, slotId: 2, recipeId: 5, servings: 4),
      TemplateEntry(dayOffset: 0, slotId: 3, freeText: 'Ăn ngoài'),
      TemplateEntry(dayOffset: 2, slotId: 3, recipeId: 9),
    ];

    test('áp vào một ngày: dịch ngày theo ngày bắt đầu', () {
      final r = applyTemplate(entries, DateTime(2026, 11, 4));
      expect(
        r.map((e) => (e.date, e.slotId, e.recipeId, e.freeText, e.servings)),
        [
          ('2026-11-04', 2, 5, null, 4.0),
          ('2026-11-04', 3, null, 'Ăn ngoài', null),
          ('2026-11-06', 3, 9, null, null),
        ],
      );
    });

    test('qua tháng, qua năm', () {
      final r = applyTemplate(entries, DateTime(2026, 12, 30));
      expect(r.map((e) => e.date), ['2026-12-30', '2026-12-30', '2027-01-01']);
    });

    test('thực đơn rỗng cho kết quả rỗng', () {
      expect(applyTemplate(const [], DateTime(2026, 11, 4)), isEmpty);
    });

    test('mục không có cả công thức lẫn chữ bị bỏ qua', () {
      final r = applyTemplate(const [
        TemplateEntry(dayOffset: 0, slotId: 1),
      ], DateTime(2026, 11, 4));
      expect(r, isEmpty);
    });
  });

  group('dedupePlanned', () {
    test('áp mẫu không ghi đè bữa đã có món khi chọn bỏ qua ô đã có', () {
      final placed = applyTemplate(const [
        TemplateEntry(dayOffset: 0, slotId: 1, recipeId: 1),
        TemplateEntry(dayOffset: 0, slotId: 2, recipeId: 2),
      ], DateTime(2026, 11, 4));
      final free = withoutOccupied(placed, {'2026-11-04|1'});
      expect(free.map((e) => e.slotId), [2]);
    });
  });
}
