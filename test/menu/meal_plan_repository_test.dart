import 'dart:math';

import 'package:cooknote/src/data/meal_plan_repository.dart';
import 'package:cooknote/src/data/pantry_repository.dart';
import 'package:cooknote/src/data/recipe_query.dart';
import 'package:cooknote/src/data/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/v3_test_support.dart';

void main() {
  late V3Env env;
  late List<MealSlot> slots;
  // Thứ Năm 2026-11-05.
  final thu = DateTime(2026, 11, 5);
  DateTime day(int d) => DateTime(2026, 11, d);

  setUp(() async {
    env = await V3Env.create();
    slots = await env.plan.getSlots();
  });
  tearDown(() => env.dispose());

  int slot(String key) => slots.firstWhere((s) => s.key == key).id;

  group('AC-38 lịch theo ngày/tuần/tháng, bữa, món', () {
    test('bữa mặc định theo ngôn ngữ; đổi tên, thêm, bớt, sắp', () async {
      expect(slots.map((s) => s.name), ['Sáng', 'Trưa', 'Tối', 'Phụ']);
      final en = await V3Env.create(language: 'en');
      addTearDown(en.dispose);
      expect((await en.plan.getSlots()).map((s) => s.name), [
        'Breakfast',
        'Lunch',
        'Dinner',
        'Snack',
      ]);

      await env.plan.renameSlot(slot('snack'), 'Xế');
      final late = await env.plan.addSlot('Khuya');
      await env.plan.addText(thu, slot('snack'), 'Chè');
      expect(await env.plan.countSlotUses(slot('snack')), 1);
      await env.plan.deleteSlot(slot('snack'));
      await env.plan.reorderSlots([
        late,
        slot('breakfast'),
        slot('lunch'),
        slot('dinner'),
      ]);
      expect((await env.plan.getSlots()).map((s) => s.name), [
        'Khuya',
        'Sáng',
        'Trưa',
        'Tối',
      ]);
      expect(await env.plan.getRange(thu, thu), isEmpty);
      expect(() => env.plan.addSlot(' '), throwsA(isA<MealPlanException>()));
    });

    test('thêm công thức hoặc chữ tự do; xếp theo ngày, bữa, thứ tự', () async {
      final pho = await env.recipe('Phở bò', ['thịt bò'], servings: 4);
      await env.plan.addText(day(6), slot('lunch'), 'Ăn ngoài');
      await env.plan.addRecipe(thu, slot('dinner'), pho, servings: 2);
      await env.plan.addText(thu, slot('breakfast'), 'Bánh mì');
      await env.plan.addText(thu, slot('dinner'), 'Rau luộc');
      final week = await env.plan.getRange(day(2), day(8));
      expect(week.map((e) => (e.date, e.title)), [
        ('2026-11-05', 'Bánh mì'),
        ('2026-11-05', 'Phở bò'),
        ('2026-11-05', 'Rau luộc'),
        ('2026-11-06', 'Ăn ngoài'),
      ]);
      final e = week[1];
      expect((e.recipeId, e.servings, e.recipeServings), (pho, 2, 4));
      expect(await env.plan.getRange(day(6), day(6)), hasLength(1));
      expect(
        () => env.plan.addText(thu, slot('lunch'), '  '),
        throwsA(isA<MealPlanException>()),
      );
    });

    test('kéo để chuyển món sang ngày hoặc bữa khác', () async {
      final a = await env.plan.addText(thu, slot('lunch'), 'A');
      final b = await env.plan.addText(thu, slot('lunch'), 'B');
      final c = await env.plan.addText(day(6), slot('dinner'), 'C');
      await env.plan.moveEntry(
        a,
        date: day(6),
        slotId: slot('dinner'),
        index: 0,
      );
      expect((await env.plan.getRange(day(6), day(6))).map((e) => e.title), [
        'A',
        'C',
      ]);
      await env.plan.moveEntry(c, date: thu, slotId: slot('lunch'));
      expect((await env.plan.getRange(thu, thu)).map((e) => e.title), [
        'B',
        'C',
      ]);
      await env.plan.deleteEntry(b);
      expect((await env.plan.getRange(thu, thu)).single.title, 'C');
    });

    test('ngày đầu tuần theo cài đặt quyết định tuần hiển thị', () async {
      final settings = SettingsRepository(env.db);
      expect(await settings.watchWeekStart().first, DateTime.monday);
      expect(weekDates(thu).first, day(2));
      await settings.setWeekStart(DateTime.sunday);
      final start = await settings.watchWeekStart().first;
      expect(weekDates(thu, weekStart: start).first, day(1));
    });

    test('xóa hẳn công thức thì món của nó rời lịch và mẫu', () async {
      final pho = await env.recipe('Phở bò', ['thịt bò']);
      await env.plan.addRecipe(thu, slot('lunch'), pho);
      await env.plan.addText(thu, slot('lunch'), 'Rau');
      await env.plan.createTemplate('Mẫu', [
        TemplateEntry(dayOffset: 0, slotId: slot('lunch'), recipeId: pho),
      ]);
      await env.recipes.moveToTrash(pho);
      final trashed = await env.plan.getRange(thu, thu);
      expect(trashed.first.recipeInTrash, isTrue);
      await env.recipes.deleteForever(pho);
      expect((await env.plan.getRange(thu, thu)).single.title, 'Rau');
      expect((await env.plan.getTemplates()).single.entryCount, 0);
    });
  });

  group('AC-39 thực đơn mẫu', () {
    test('áp mẫu một ngày vào một ngày hoặc cả tuần', () async {
      final ca = await env.recipe('Cá kho', ['cá']);
      final canh = await env.recipe('Canh chua', ['cà chua']);
      final id = await env.plan.createTemplate('Cơm gia đình', [
        TemplateEntry(dayOffset: 0, slotId: slot('dinner'), recipeId: ca),
        TemplateEntry(
          dayOffset: 0,
          slotId: slot('dinner'),
          recipeId: canh,
          servings: 6,
        ),
        TemplateEntry(dayOffset: 0, slotId: slot('dinner'), freeText: 'Cơm'),
        TemplateEntry(dayOffset: 0, slotId: slot('lunch'), freeText: ' '),
      ]);
      final info = (await env.plan.getTemplates()).single;
      expect((info.name, info.entryCount, info.days), ('Cơm gia đình', 3, 1));

      expect(await env.plan.applyTemplate(id, [thu]), 3);
      final today = await env.plan.getRange(thu, thu);
      expect(today.map((e) => e.title), ['Cá kho', 'Canh chua', 'Cơm']);
      expect(today[1].servings, 6);

      final week = weekDates(thu);
      expect(await env.plan.applyTemplate(id, week), 21);
      expect(await env.plan.getRange(week.first, week.last), hasLength(24));
    });

    test('mẫu nhiều ngày áp từ ngày đầu tuần; bỏ bữa đã có nếu chọn', () async {
      await env.plan.addText(thu, slot('dinner'), 'Ăn ngoài');
      await env.plan.addText(day(6), slot('lunch'), 'Bún');
      final id = await env.plan.createTemplateFromRange(
        'Tuần trước',
        thu,
        day(6),
      );
      final t = (await env.plan.getTemplates()).single;
      expect((t.entryCount, t.days), (2, 2));
      expect(await env.plan.templateEntries(id), hasLength(2));

      final mon = day(9);
      expect(await env.plan.applyTemplate(id, [mon]), 2);
      expect(
        (await env.plan.getRange(mon, day(10))).map((e) => (e.date, e.title)),
        [('2026-11-09', 'Ăn ngoài'), ('2026-11-10', 'Bún')],
      );
      // Áp lần nữa với bỏ bữa đã có: không thêm gì.
      expect(
        await env.plan.applyTemplate(id, [
          mon,
        ], mode: TemplateApplyMode.skipOccupied),
        0,
      );

      await env.plan.renameTemplate(id, 'Mẫu A');
      await env.plan.setTemplateEntries(id, [
        TemplateEntry(dayOffset: 0, slotId: slot('lunch'), freeText: 'Phở'),
      ]);
      expect((await env.plan.getTemplates()).single.name, 'Mẫu A');
      expect((await env.plan.getTemplates()).single.entryCount, 1);
      await env.plan.deleteTemplate(id);
      expect(await env.plan.getTemplates(), isEmpty);
    });
  });

  group('AC-39/D-009 bữa đích đã có món: Thay thế hay Thêm vào', () {
    late int tpl;
    setUp(() async {
      final ca = await env.recipe('Cá kho', ['cá']);
      tpl = await env.plan.createTemplate('Cơm tối', [
        TemplateEntry(dayOffset: 0, slotId: slot('dinner'), recipeId: ca),
        TemplateEntry(dayOffset: 0, slotId: slot('dinner'), freeText: 'Canh'),
        TemplateEntry(dayOffset: 1, slotId: slot('lunch'), freeText: 'Bún'),
      ]);
    });

    Future<List<(String, String, String)>> titles() async => [
      for (final e in await env.plan.getRange(thu, day(7)))
        (e.date, slots.firstWhere((s) => s.id == e.slotId).key!, e.title),
    ];

    test('báo các bữa đích đã có món; trống thì rỗng', () async {
      expect(await env.plan.occupiedTargets(tpl, [thu]), isEmpty);
      await env.plan.addText(day(6), slot('lunch'), 'Phở');
      await env.plan.addText(thu, slot('dinner'), 'Ăn ngoài');
      await env.plan.addText(thu, slot('dinner'), 'Chè');
      await env.plan.addText(thu, slot('lunch'), 'Cơm văn phòng');
      expect(await env.plan.occupiedTargets(tpl, [thu]), [
        (date: '2026-11-05', slotId: slot('dinner')),
        (date: '2026-11-06', slotId: slot('lunch')),
      ]);
      expect(await env.plan.occupiedTargets(tpl, [day(7)]), isEmpty);
    });

    test('Thay thế: xóa món cũ của bữa đích rồi áp, bữa khác giữ', () async {
      await env.plan.addText(thu, slot('dinner'), 'Ăn ngoài');
      await env.plan.addText(thu, slot('lunch'), 'Cơm văn phòng');
      await env.plan.addText(day(6), slot('lunch'), 'Phở');
      expect(
        await env.plan.applyTemplate(tpl, [
          thu,
        ], mode: TemplateApplyMode.replace),
        3,
      );
      expect(await titles(), [
        ('2026-11-05', 'lunch', 'Cơm văn phòng'),
        ('2026-11-05', 'dinner', 'Cá kho'),
        ('2026-11-05', 'dinner', 'Canh'),
        ('2026-11-06', 'lunch', 'Bún'),
      ]);
    });

    test('Thêm vào: giữ món cũ, món mẫu ở cuối bữa', () async {
      await env.plan.addText(thu, slot('dinner'), 'Ăn ngoài');
      expect(await env.plan.applyTemplate(tpl, [thu]), 3);
      expect(await titles(), [
        ('2026-11-05', 'dinner', 'Ăn ngoài'),
        ('2026-11-05', 'dinner', 'Cá kho'),
        ('2026-11-05', 'dinner', 'Canh'),
        ('2026-11-06', 'lunch', 'Bún'),
      ]);
    });

    test(
      'Thay thế là một giao dịch: lỗi giữa chừng thì không mất món cũ',
      () async {
        await env.plan.addText(thu, slot('dinner'), 'Ăn ngoài');
        // Bữa của mẫu bị xóa ngầm bằng SQL thô để chèn món mẫu thất bại.
        await env.db.customStatement('PRAGMA foreign_keys = OFF');
        await env.db.customStatement(
          'UPDATE menu_template_entries SET slot_id = 999 '
          "WHERE free_text = 'Bún'",
        );
        await env.db.customStatement('PRAGMA foreign_keys = ON');
        await expectLater(
          env.plan.applyTemplate(tpl, [thu], mode: TemplateApplyMode.replace),
          throwsA(anything),
        );
        expect(await titles(), [('2026-11-05', 'dinner', 'Ăn ngoài')]);
      },
    );
  });

  group('AC-40 thêm nguyên liệu của khoảng ngày vào đi chợ', () {
    test('theo khẩu phần từng món, qua bước chọn, gộp trùng', () async {
      final pho = await env.recipe('Phở bò', [
        '400 g thịt bò',
        '2 củ hành tây',
      ], servings: 4);
      final bo = await env.recipe('Bò xào', [
        '300 g thịt bò',
        'tỏi',
      ], servings: 2);
      await env.pantry.add(const PantryDraft(name: 'tỏi'));
      await env.plan.addRecipe(thu, slot('lunch'), pho, servings: 2);
      await env.plan.addRecipe(day(6), slot('dinner'), bo);
      await env.plan.addText(day(6), slot('lunch'), 'Ăn ngoài');
      await env.plan.addRecipe(day(9), slot('lunch'), pho); // ngoài khoảng

      final c = await env.plan.shoppingCandidates(thu, day(8));
      expect(c.map((e) => (e.label(), e.selected, e.recipeName)), [
        ('200 g thịt bò', true, 'Phở bò'),
        ('1 củ hành tây', true, 'Phở bò'),
        ('300 g thịt bò', true, 'Bò xào'),
        ('tỏi', false, 'Bò xào'),
      ]);

      final list = (await env.shopping.getLists()).single.id;
      await env.shopping.addCandidates(list, c);
      final items = await env.shopping.getItems(list);
      expect(items.map((i) => i.label()), ['1 củ hành tây', '500 g thịt bò']);
      expect(items.last.sources.map((s) => s.recipeName), ['Phở bò', 'Bò xào']);
    });
  });

  group('AC-41 gợi ý ngẫu nhiên', () {
    test(
      'điền bữa trống, không lặp món trong tuần, xem trước rồi áp',
      () async {
        final ids = [
          for (var i = 0; i < 13; i++) await env.recipe('Món $i', ['x']),
        ];
        final week = weekDates(thu);
        await env.plan.addRecipe(week[0], slot('lunch'), ids[0]);
        await env.plan.addText(week[0], slot('dinner'), 'Ăn ngoài');
        final lunchDinner = [slot('lunch'), slot('dinner')];

        final preview = await env.plan.suggest(
          dates: week,
          slotIds: lunchDinner,
          recipeIds: ids,
          random: Random(1),
        );
        expect(preview, hasLength(12));
        expect(await env.plan.getRange(week.first, week.last), hasLength(2));
        final used = preview.map((a) => a.recipeId).toList();
        expect(used.toSet(), hasLength(12), reason: 'không lặp khi còn món');
        expect(
          used,
          isNot(contains(ids[0])),
          reason: 'món đã có trong tuần chỉ dùng khi hết món khác',
        );
        expect(
          preview.any(
            (a) => a.date == '2026-11-02' && lunchDinner.contains(a.slotId),
          ),
          isFalse,
        );

        await env.plan.applySuggestions(preview);
        expect(await env.plan.getRange(week.first, week.last), hasLength(14));
        final again = await env.plan.suggest(
          dates: week,
          slotIds: lunchDinner,
          recipeIds: ids,
        );
        expect(again, isEmpty, reason: 'không còn bữa trống');
      },
    );

    test(
      'lọc theo danh mục/thẻ/thời gian bằng RecipeRepository.search',
      () async {
        final quick = await env.recipe('Nhanh', ['x'], totalMinutes: 15);
        await env.recipe('Lâu', ['x'], totalMinutes: 120);
        final found = await env.recipes.search(
          const RecipeQuery(maxTotalMinutes: 30),
        );
        final preview = await env.plan.suggest(
          dates: [thu, day(6)],
          recipeIds: [for (final r in found) r.id],
          random: Random(2),
        );
        // 2 ngày × 4 bữa, chỉ một món thỏa: bắt buộc lặp.
        expect(preview, hasLength(8));
        expect(preview.every((a) => a.recipeId == quick), isTrue);
        expect(
          await env.plan.suggest(dates: [thu], recipeIds: const []),
          isEmpty,
        );
      },
    );
  });
}
