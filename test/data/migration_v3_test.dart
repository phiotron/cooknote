import 'dart:io';

import 'package:cooknote/src/data/category_repository.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/meal_plan_repository.dart';
import 'package:cooknote/src/data/recipe_query.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:cooknote/src/data/settings_repository.dart';
import 'package:cooknote/src/data/shopping_repository.dart';
import 'package:cooknote/src/data/v3_defaults.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cơ sở dữ liệu đúng như G2/G3 đã tạo (schemaVersion 2), có một công thức
/// đủ danh mục, thẻ, lịch sử nấu, ảnh và cài đặt.
void _createV2(dynamic raw) {
  raw.execute('''
CREATE TABLE recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  servings REAL, servings_unit TEXT, prep_minutes INTEGER,
  cook_minutes INTEGER, total_minutes INTEGER, source TEXT, source_url TEXT,
  notes TEXT, nutrition TEXT, difficulty INTEGER,
  rating INTEGER NOT NULL DEFAULT 0 CHECK (rating BETWEEN 0 AND 5),
  favorite INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER,
  search_key TEXT NOT NULL DEFAULT '', ingredients_key TEXT NOT NULL DEFAULT ''
)''');
  raw.execute('''
CREATE TABLE recipe_lines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE,
  section INTEGER NOT NULL, position INTEGER NOT NULL,
  is_heading INTEGER NOT NULL DEFAULT 0, body TEXT NOT NULL
)''');
  raw.execute('''
CREATE TABLE recipe_photos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE,
  file_name TEXT NOT NULL, position INTEGER NOT NULL
)''');
  raw.execute('''
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
  parent_id INTEGER NULL REFERENCES categories (id),
  position INTEGER NOT NULL DEFAULT 0
)''');
  raw.execute('''
CREATE TABLE recipe_categories (
  recipe_id INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES categories (id) ON DELETE CASCADE,
  PRIMARY KEY (recipe_id, category_id)
)''');
  raw.execute('''
CREATE TABLE recipe_tags (
  recipe_id INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE,
  tag TEXT NOT NULL, tag_key TEXT NOT NULL,
  PRIMARY KEY (recipe_id, tag_key)
)''');
  raw.execute('''
CREATE TABLE cook_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE,
  cooked_at INTEGER NOT NULL
)''');
  raw.execute(
    'CREATE TABLE settings ("key" TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)',
  );
  raw.execute(
    "INSERT INTO recipes (name, servings, created_at, updated_at, search_key, "
    "ingredients_key) VALUES ('Phở bò', 4, 1793000000, 1793000000, "
    "'pho bo\n500 g thit bo', '500 g thit bo')",
  );
  raw.execute(
    "INSERT INTO recipe_lines (recipe_id, section, position, body) VALUES "
    "(1, 0, 0, '500 g thịt bò'), (1, 1, 1, 'Ninh xương')",
  );
  raw.execute(
    "INSERT INTO recipe_photos (recipe_id, file_name, position) "
    "VALUES (1, 'a.jpg', 0)",
  );
  raw.execute("INSERT INTO categories (name) VALUES ('Món Việt')");
  raw.execute("INSERT INTO recipe_categories VALUES (1, 1)");
  raw.execute("INSERT INTO recipe_tags VALUES (1, 'Bò', 'bo')");
  raw.execute(
    "INSERT INTO cook_log (recipe_id, cooked_at) VALUES (1, 1793001000)",
  );
  raw.execute(
    "INSERT INTO settings VALUES ('locale', 'en'), ('categoriesSeeded', '1'), "
    "('backup.treeUri', 'content://x')",
  );
  raw.execute('PRAGMA user_version = 2');
}

void main() {
  test('nâng cấp 2 → 3 giữ nguyên dữ liệu cũ, bảng mới dùng được', () async {
    final temp = Directory.systemTemp.createTempSync('cooknote_mig3_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final db = AppDatabase(NativeDatabase.memory(setup: _createV2));
    addTearDown(db.close);
    final recipes = RecipeRepository(
      db,
      ImageStore(Directory('${temp.path}/p')),
    );

    // Dữ liệu cũ còn nguyên.
    final r = (await recipes.getRecipe(1))!;
    expect(r.draft.name, 'Phở bò');
    expect(r.draft.servings, 4);
    expect(r.draft.ingredients.single.text, '500 g thịt bò');
    expect(r.draft.steps.single.text, 'Ninh xương');
    expect(r.draft.photos, ['a.jpg']);
    expect(r.draft.tags, ['Bò']);
    expect(r.draft.categoryIds, [1]);
    expect(r.cookCount, 1);
    expect((await CategoryRepository(db).getAll()).single.name, 'Món Việt');
    expect((await recipes.search(const RecipeQuery(text: 'pho bo'))).length, 1);
    final settings = {
      for (final s in await db.select(db.settings).get()) s.key: s.value,
    };
    expect(settings['locale'], 'en');
    expect(settings['backup.treeUri'], 'content://x');

    // Bảng mới có, rỗng, chưa có dữ liệu mặc định trước khi mở app.
    expect(await db.select(db.aisles).get(), isEmpty);
    expect(await db.select(db.mealSlots).get(), isEmpty);

    // Dữ liệu mặc định theo ngôn ngữ đã chọn (en).
    expect(await seedV3Defaults(db, 'en'), isTrue);
    expect(await seedV3Defaults(db, 'en'), isFalse, reason: 'chỉ một lần');
    expect(
      (await db.select(db.aisles).get()).map((a) => a.name).first,
      'Produce',
    );
    final plan = MealPlanRepository(db);
    final slots = await plan.getSlots();
    expect(slots.map((s) => s.name), ['Breakfast', 'Lunch', 'Dinner', 'Snack']);
    final shopping = ShoppingRepository(db);
    final list = (await shopping.getLists()).single;
    expect(list.name, 'Shopping');

    // Bảng mới nối được với công thức cũ.
    await plan.addRecipe(DateTime(2026, 11, 5), slots[1].id, 1, servings: 2);
    final candidates = await plan.shoppingCandidates(
      DateTime(2026, 11, 5),
      DateTime(2026, 11, 5),
    );
    await shopping.addCandidates(list.id, candidates);
    final item = (await shopping.getItems(list.id)).single;
    expect(item.label(), '250 g thịt bò');
    expect(item.sources.single.recipeId, 1);

    // Cài đặt mới có giá trị mặc định.
    final s = SettingsRepository(db);
    expect(await s.watchWeekStart().first, DateTime.monday);
    expect(await s.watchUnitSystem().first, 'metric');
    expect(await s.watchIgnoreBasics().first, isFalse);
  });

  test('cài mới tạo đủ bảng; dữ liệu mặc định tiếng Việt', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedV3Defaults(db, 'vi');
    expect((await MealPlanRepository(db).getSlots()).map((s) => s.name), [
      'Sáng',
      'Trưa',
      'Tối',
      'Phụ',
    ]);
    expect((await ShoppingRepository(db).getLists()).single.name, 'Đi chợ');
    expect((await db.select(db.aisles).get()).map((a) => a.key), [
      'produce',
      'meat',
      'dairy',
      'dry',
      'spice',
      'frozen',
      'drink',
      'other',
    ]);
  });

  test('người dùng xóa hết khu vực thì không tạo lại', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedV3Defaults(db, 'vi');
    await db.delete(db.aisles).go();
    await db.delete(db.shoppingLists).go();
    expect(await seedV3Defaults(db, 'vi'), isFalse);
    expect(await db.select(db.aisles).get(), isEmpty);
  });
}
