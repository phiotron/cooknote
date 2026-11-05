import 'dart:io';

import 'package:cooknote/src/backup/backup_data.dart';
import 'package:cooknote/src/backup/backup_format.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/meal_plan_repository.dart';
import 'package:cooknote/src/data/pantry_repository.dart';
import 'package:cooknote/src/data/settings_repository.dart';
import 'package:cooknote/src/data/v3_defaults.dart';
import 'package:drift/drift.dart' show Table, TableInfo;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/v3_test_support.dart';

/// Dữ liệu đủ mọi bảng của định dạng 2 trên [env].
Future<void> fillV2(V3Env env) async {
  final pho = await env.recipe('Phở bò', [
    '400 g thịt bò',
    'hành lá',
  ], servings: 4);
  final list = (await env.shopping.getLists()).single.id;
  final other = await env.shopping.createList('Siêu thị');
  await env.shopping.addCandidates(
    list,
    await env.shopping.candidatesForRecipe(pho),
  );
  await env.shopping.addText(other, 'sữa, không đường');
  await env.shopping.addText(other, '1 bó rau muống');
  final veg = (await env.shopping.getItems(other)).last;
  await env.shopping.setChecked(veg.id, true);
  await env.shopping.setFavorite('trứng gà', true);
  final tofu = await env.shopping.addText(list, 'đậu hũ');
  expect(tofu.added, 1);
  final dry = (await env.aisles.getAll()).firstWhere((a) => a.key == 'dry');
  await env.shopping.moveToAisle(
    (await env.shopping.getItems(list))
        .firstWhere((i) => i.name == 'đậu hũ')
        .id,
    dry.id,
  );
  await env.aisles.add('Tiệm bánh');
  await env.pantry.add(const PantryDraft(name: 'gạo', amount: '5 kg'));
  await env.pantry.add(
    PantryDraft(name: 'sữa tươi', expiresOn: DateTime(2026, 11, 6)),
  );
  final slots = await env.plan.getSlots();
  await env.plan.renameSlot(slots.last.id, 'Xế');
  await env.plan.addRecipe(
    DateTime(2026, 11, 5),
    slots[1].id,
    pho,
    servings: 2,
  );
  await env.plan.addText(DateTime(2026, 11, 5), slots[2].id, 'Ăn ngoài');
  await env.plan.createTemplate('Cơm nhà', [
    TemplateEntry(dayOffset: 0, slotId: slots[2].id, recipeId: pho),
    TemplateEntry(dayOffset: 1, slotId: slots[2].id, freeText: 'Cơm'),
  ]);
  final s = SettingsRepository(env.db);
  await s.setWeekStart(DateTime.sunday);
  await s.setUnitSystem('us');
  await s.setIgnoreBasics(true);
}

void main() {
  late V3Env env;

  setUp(() async => env = await V3Env.create());
  tearDown(() => env.dispose());

  test('xuất có đủ khóa định dạng 2', () async {
    await fillV2(env);
    final data = await exportData(env.db);
    for (final k in [
      'aisles',
      'shoppingLists',
      'knownItems',
      'pantry',
      'mealSlots',
      'mealPlan',
      'menuTemplates',
    ]) {
      expect(data[k], isA<List<Object?>>(), reason: k);
    }
    final lists = data['shoppingLists'] as List;
    final items = (lists.first as Map)['items'] as List;
    final beef = items.cast<Map>().firstWhere((i) => i['name'] == 'thịt bò');
    expect(beef['quantity'], 400);
    expect(beef['unit'], 'g');
    expect(beef['sources'], [
      {'recipeId': 1, 'recipeName': 'Phở bò'},
    ]);
    expect((data['pantry'] as List).length, 2);
    expect(data['settings'], containsPair('weekStart', 'sunday'));
    expect(data['settings'], containsPair('ignoreBasics', '1'));
  });

  test('thay thế toàn bộ: dữ liệu khôi phục giống hệt bản xuất', () async {
    await fillV2(env);
    final data = await exportData(env.db);
    final fresh = await V3Env.create(language: 'en');
    addTearDown(fresh.dispose);
    await fresh.shopping.addText(
      (await fresh.shopping.getLists()).single.id,
      'beer',
    );
    await fresh.pantry.add(const PantryDraft(name: 'old'));
    await importData(fresh.db, data, replace: true);
    final again = await exportData(fresh.db);
    data.remove('settings');
    again.remove('settings');
    expect(again, data);
    final s = SettingsRepository(fresh.db);
    expect(await s.watchWeekStart().first, DateTime.sunday);
    expect(await s.watchUnitSystem().first, 'us');
    // Trí nhớ khu vực về theo.
    expect(
      await fresh.aisles.aisleIdFor('Đậu hũ'),
      (await fresh.aisles.getAll()).firstWhere((a) => a.key == 'dry').id,
    );
  });

  test(
    'gộp: chỉ thêm công thức, đi chợ/tủ bếp/lịch ở máy này giữ nguyên',
    () async {
      await fillV2(env);
      final data = await exportData(env.db);
      final mine = await V3Env.create();
      addTearDown(mine.dispose);
      final list = (await mine.shopping.getLists()).single.id;
      await mine.shopping.addText(list, 'bia');
      await mine.pantry.add(const PantryDraft(name: 'muối'));
      final summary = await importData(mine.db, data, replace: false);
      expect(summary.recipesAdded, 1);
      expect((await mine.shopping.getItems(list)).single.name, 'bia');
      expect((await mine.pantry.getItems()).single.name, 'muối');
      expect(await mine.plan.getTemplates(), isEmpty);
      expect((await mine.shopping.getLists()).length, 1);
    },
  );

  test(
    'khôi phục file định dạng 1: giữ khu vực và bữa, xóa đi chợ/lịch cũ',
    () async {
      await fillV2(env);
      final images = ImageStore(Directory('${env.temp.path}/restore'));
      await restoreBackupFile(
        db: env.db,
        images: images,
        file: File('test/fixtures/backup_v1.cooknote'),
        mode: RestoreMode.replace,
      );
      final aisles = await env.aisles.getAll();
      expect(aisles.map((a) => a.name), contains('Tiệm bánh'));
      expect((await env.plan.getSlots()).last.name, 'Xế');
      for (final t in <TableInfo<Table, dynamic>>[
        env.db.shoppingItems,
        env.db.shoppingLists,
        env.db.knownItems,
        env.db.pantryItems,
        env.db.mealPlanEntries,
        env.db.menuTemplates,
      ]) {
        expect(
          await env.db.select(t).get(),
          isEmpty,
          reason: t.actualTableName,
        );
      }
      expect((await env.db.select(env.db.recipes).get()).length, 2);
    },
  );

  test(
    'tham chiếu hỏng thì bỏ món đó, không làm hỏng cả lần khôi phục',
    () async {
      await fillV2(env);
      final data = await exportData(env.db);
      (data['mealPlan'] as List).add({
        'date': '2026-11-07',
        'slotId': 999,
        'recipeId': null,
        'text': 'bữa không tồn tại',
      });
      (data['mealPlan'] as List).add({
        'date': '2026-11-07',
        'slotId': 1,
        'recipeId': 999,
        'text': null,
      });
      final items =
          ((data['shoppingLists'] as List).first as Map)['items'] as List;
      (items.first as Map)['aisleId'] = 999;
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(fresh.close);
      await importData(fresh, data, replace: true);
      expect((await fresh.select(fresh.mealPlanEntries).get()).length, 2);
      final first = (await fresh.select(fresh.shoppingItems).get()).first;
      expect(first.aisleId, isNull);
    },
  );

  test(
    'ngày sai dạng là file hỏng: báo lỗi, dữ liệu hiện có còn nguyên',
    () async {
      await fillV2(env);
      final data = await exportData(env.db);
      ((data['pantry'] as List).first as Map)['purchasedOn'] = '5/11/2026';
      final mine = await V3Env.create();
      addTearDown(mine.dispose);
      await mine.pantry.add(const PantryDraft(name: 'muối'));
      await expectLater(
        importData(mine.db, data, replace: true),
        throwsA(
          isA<BackupException>().having(
            (e) => e.problem,
            'problem',
            BackupProblem.badData,
          ),
        ),
      );
      expect((await mine.pantry.getItems()).single.name, 'muối');
    },
  );

  test('tạo file, đọc lại, khôi phục vào máy khác', () async {
    await fillV2(env);
    final out = File('${env.temp.path}/b.cooknote');
    await createBackupFile(
      db: env.db,
      images: env.images,
      out: out,
      appVersion: '1.0.0',
      now: DateTime.utc(2026, 11, 5, 3),
    );
    final info = await verifyBackupFile(out);
    expect(info.formatVersion, 2);
    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await seedV3Defaults(other, 'en');
    await restoreBackupFile(
      db: other,
      images: ImageStore(Directory('${env.temp.path}/other')),
      file: out,
      mode: RestoreMode.replace,
    );
    expect(
      (await other.select(other.aisles).get()).first.name,
      'Rau củ',
      reason: 'khu vực theo file, không theo ngôn ngữ máy mới',
    );
    expect(
      (await MealPlanRepository(other).getTemplates()).single.name,
      'Cơm nhà',
    );
  });
}
