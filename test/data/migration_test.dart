import 'dart:io';

import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_query.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cơ sở dữ liệu đúng như G1 đã tạo (schemaVersion 1), có một công thức.
void _createV1(dynamic raw) {
  raw.execute('''
CREATE TABLE recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  servings REAL, servings_unit TEXT, prep_minutes INTEGER,
  cook_minutes INTEGER, total_minutes INTEGER, source TEXT, source_url TEXT,
  notes TEXT, nutrition TEXT, difficulty INTEGER,
  rating INTEGER NOT NULL DEFAULT 0 CHECK (rating BETWEEN 0 AND 5),
  favorite INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER
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
  raw.execute(
    'CREATE TABLE settings ("key" TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)',
  );
  raw.execute(
    "INSERT INTO recipes (name, notes, created_at, updated_at) "
    "VALUES ('Phở bò', 'Món của bà', 1793000000, 1793000000)",
  );
  raw.execute(
    "INSERT INTO recipe_lines (recipe_id, section, position, body) VALUES "
    "(1, 0, 0, '500 g thịt bò'), (1, 1, 1, 'Ninh xương')",
  );
  raw.execute("INSERT INTO settings VALUES ('locale', 'vi')");
  raw.execute('PRAGMA user_version = 1');
}

void main() {
  test('nâng cấp từ G1 giữ dữ liệu và dựng chỉ mục tìm kiếm (D-006)', () async {
    final temp = Directory.systemTemp.createTempSync('cooknote_mig_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final db = AppDatabase(NativeDatabase.memory(setup: _createV1));
    addTearDown(db.close);
    final repo = RecipeRepository(db, ImageStore(Directory('${temp.path}/p')));

    // Công thức cũ còn nguyên.
    final r = (await repo.getRecipe(1))!;
    expect(r.draft.name, 'Phở bò');
    expect(r.draft.ingredients.single.text, '500 g thịt bò');
    expect(r.draft.steps.single.text, 'Ninh xương');
    expect(r.draft.categoryIds, isEmpty);
    expect(r.draft.tags, isEmpty);

    // Chỉ mục tìm kiếm được tính cho công thức cũ.
    expect((await repo.search(const RecipeQuery(text: 'pho bo'))).length, 1);
    expect(
      (await repo.search(const RecipeQuery(text: 'mon cua ba'))).length,
      1,
    );
    expect(
      (await repo.search(const RecipeQuery(ingredient: 'thit bo'))).length,
      1,
    );
    expect(
      (await repo.search(const RecipeQuery(ingredient: 'xuong'))),
      isEmpty,
    );

    // Cài đặt cũ còn, bảng mới dùng được.
    final settings = await db.select(db.settings).get();
    expect(settings.single.value, 'vi');
    await repo.markCooked(1);
    expect((await repo.getRecipe(1))!.cookCount, 1);
  });
}
