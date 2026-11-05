import 'package:cooknote/src/cooking/ingredient_parser.dart';
import 'package:cooknote/src/data/aisle_repository.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/meal_plan_repository.dart';
import 'package:cooknote/src/data/pantry_repository.dart';
import 'package:cooknote/src/data/settings_repository.dart';
import 'package:cooknote/src/data/shopping_repository.dart';
import 'package:cooknote/src/data/v3_defaults.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phần định dạng 2 của file mẫu `backup_v2.cooknote` (đi kèm hai công thức
/// như file mẫu định dạng 1). Đổi hàm này thì KHÔNG tạo lại file mẫu cũ.
Future<void> fillV2Fixture(AppDatabase db, int pho, DateTime now) async {
  DateTime clock() => now;
  await seedV3Defaults(db, 'vi', clock: clock);
  final aisles = AisleRepository(db);
  final pantry = PantryRepository(db, clock: clock, aisles: aisles);
  final shopping = ShoppingRepository(
    db,
    clock: clock,
    aisles: aisles,
    pantry: pantry,
  );
  final plan = MealPlanRepository(db, clock: clock, pantry: pantry);

  final all = await aisles.getAll();
  await aisles.rename(all.firstWhere((a) => a.key == 'meat').id, 'Hàng thịt');
  await aisles.add('Tiệm bánh');

  final list = (await shopping.getLists()).single.id;
  final market = await shopping.createList('Siêu thị');
  await shopping.addCandidates(
    list,
    await shopping.candidatesForRecipe(pho, servings: 2),
  );
  await shopping.addText(list, 'đậu hũ');
  final tofu = (await shopping.getItems(list))
      .firstWhere((i) => i.name == 'đậu hũ');
  await shopping.moveToAisle(tofu.id, all.firstWhere((a) => a.key == 'dry').id);
  await shopping.addText(market, 'sữa tươi, không đường');
  await shopping.addText(market, '1 bó rau muống');
  final veg = (await shopping.getItems(market))
      .firstWhere((i) => i.name == 'rau muống');
  await shopping.setChecked(veg.id, true);
  await shopping.setFavorite('trứng gà', true);

  await pantry.add(const PantryDraft(name: 'gạo', amount: '5 kg'));
  await pantry.add(
    PantryDraft(
      name: 'sữa tươi',
      amount: '1 l',
      purchasedOn: DateTime(2026, 11, 2),
      expiresOn: DateTime(2026, 11, 6),
    ),
  );

  final slots = await plan.getSlots();
  await plan.renameSlot(slots.last.id, 'Xế');
  await plan.addSlot('Khuya');
  await plan.addRecipe(DateTime(2026, 11, 5), slots[1].id, pho, servings: 2);
  await plan.addText(DateTime(2026, 11, 5), slots[2].id, 'Ăn ngoài');
  await plan.createTemplate('Cơm nhà', [
    TemplateEntry(dayOffset: 0, slotId: slots[2].id, recipeId: pho),
    TemplateEntry(dayOffset: 1, slotId: slots[2].id, freeText: 'Cơm'),
  ]);

  final s = SettingsRepository(db);
  await s.setWeekStart(DateTime.sunday);
  await s.setUnitSystem('us');
  await s.setIgnoreBasics(true);
}

/// Kiểm phần định dạng 2 sau khi khôi phục `backup_v2.cooknote`.
Future<void> checkV2Fixture(AppDatabase db, int pho) async {
  final aisles = await AisleRepository(db).getAll();
  expect(aisles.map((a) => a.name), [
    'Rau củ',
    'Hàng thịt',
    'Sữa trứng',
    'Đồ khô',
    'Gia vị',
    'Đông lạnh',
    'Đồ uống',
    'Khác',
    'Tiệm bánh',
  ]);
  expect(aisles[1].key, 'meat');

  final shopping = ShoppingRepository(db);
  final lists = await shopping.getLists();
  expect(lists.map((l) => l.name), ['Đi chợ', 'Siêu thị']);
  final items = await shopping.getItems(lists.first.id);
  expect(items.map((i) => i.label()), ['1 kg xương bò', 'đậu hũ']);
  expect(items.first.quantity.unit, IngredientUnit.kg);
  expect(items.first.sources.single.recipeId, pho);
  expect(items.first.sources.single.recipeName, 'Phở bò');
  expect(items.last.aisleId, aisles.firstWhere((a) => a.key == 'dry').id);
  final market = await shopping.getItems(lists.last.id);
  expect(market.map((i) => (i.label(), i.checked)), [
    ('sữa tươi (không đường)', false),
    ('1 bó rau muống', true),
  ]);
  expect((await shopping.frequent()).first.name, 'trứng gà');
  expect(
    await AisleRepository(db).aisleIdFor('Đậu hũ'),
    aisles.firstWhere((a) => a.key == 'dry').id,
    reason: 'khu vực đã nhớ đi theo bản sao lưu',
  );

  final pantry = await PantryRepository(db).getItems();
  expect(pantry.map((p) => (p.name, p.amountLabel())), [
    ('sữa tươi', '1 l'),
    ('gạo', '5 kg'),
  ]);
  expect(pantry.first.expiresOn, DateTime(2026, 11, 6));
  expect(pantry.first.purchasedOn, DateTime(2026, 11, 2));

  final plan = MealPlanRepository(db);
  final slots = await plan.getSlots();
  expect(slots.map((s) => s.name), ['Sáng', 'Trưa', 'Tối', 'Xế', 'Khuya']);
  final day = await plan.getRange(DateTime(2026, 11, 5), DateTime(2026, 11, 5));
  expect(day.map((e) => (e.title, e.servings)), [
    ('Phở bò', 2.0),
    ('Ăn ngoài', null),
  ]);
  final t = (await plan.getTemplates()).single;
  expect((t.name, t.entryCount, t.days), ('Cơm nhà', 2, 2));

  final s = SettingsRepository(db);
  expect(await s.watchWeekStart().first, DateTime.sunday);
  expect(await s.watchUnitSystem().first, 'us');
  expect(await s.watchIgnoreBasics().first, isTrue);
}
