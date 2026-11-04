import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'recipe_lines.dart';
import 'text_normalize.dart';

export 'recipe_lines.dart' show LineSection;

part 'database.g.dart';

/// Độ khó của công thức (AC-02).
enum Difficulty { easy, medium, hard }

class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Số khẩu phần và chữ đi kèm, ví dụ 4 và "người" (AC-02).
  RealColumn get servings => real().nullable()();
  TextColumn get servingsUnit => text().withLength(max: 50).nullable()();
  IntColumn get prepMinutes => integer().nullable()();
  IntColumn get cookMinutes => integer().nullable()();
  IntColumn get totalMinutes => integer().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get nutrition => text().nullable()();
  IntColumn get difficulty => intEnum<Difficulty>().nullable()();
  IntColumn get rating => integer()
      .withDefault(const Constant(0))
      // ignore: recursive_getters
      .check(rating.isBetweenValues(0, 5))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Thời điểm vào thùng rác; null là đang dùng (AC-05).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Tên, nguyên liệu, bước, ghi chú, nguồn đã bỏ dấu và hạ chữ thường, để
  /// tìm bằng LIKE (AC-12). Tính lại mỗi lần lưu.
  TextColumn get searchKey => text().withDefault(const Constant(''))();

  /// Riêng phần nguyên liệu, đã chuẩn hóa, cho bộ lọc "có nguyên liệu X"
  /// (AC-13).
  TextColumn get ingredientsKey => text().withDefault(const Constant(''))();
}

/// Dòng nguyên liệu hoặc bước, theo thứ tự [position] trong từng phần.
@DataClassName('RecipeLineRow')
class RecipeLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get section => intEnum<LineSection>()();
  IntColumn get position => integer()();
  BoolColumn get isHeading => boolean().withDefault(const Constant(false))();
  TextColumn get body => text()();
}

/// Ảnh của công thức; ảnh có [position] 0 là ảnh bìa (AC-02).
@DataClassName('RecipePhotoRow')
class RecipePhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileName => text()();
  IntColumn get position => integer()();
}

/// Danh mục lồng nhau tối đa 3 cấp; [parentId] null là cấp đầu (AC-10).
@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get parentId => integer().nullable().references(Categories, #id)();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Công thức thuộc 0 hoặc nhiều danh mục (AC-10).
class RecipeCategories extends Table {
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {recipeId, categoryId};
}

/// Thẻ tự do; [tagKey] là bản đã chuẩn hóa để so khớp (AC-11).
class RecipeTags extends Table {
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tag => text().withLength(min: 1, max: 40)();
  TextColumn get tagKey => text()();

  @override
  Set<Column> get primaryKey => {recipeId, tagKey};
}

/// Lịch sử "Đã nấu" (AC-15).
@DataClassName('CookLogRow')
class CookLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get cookedAt => dateTime()();
}

/// Cài đặt dạng khóa-giá trị, nằm cùng cơ sở dữ liệu để sao lưu chung.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Recipes,
    RecipeLines,
    RecipePhotos,
    Categories,
    RecipeCategories,
    RecipeTags,
    CookLog,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'cooknote'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // G2: chỉ mục tìm kiếm, danh mục, thẻ, lịch sử nấu (D-006).
        await m.addColumn(recipes, recipes.searchKey);
        await m.addColumn(recipes, recipes.ingredientsKey);
        await m.createTable(categories);
        await m.createTable(recipeCategories);
        await m.createTable(recipeTags);
        await m.createTable(cookLog);
        await _backfillSearchKeys();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Tính chỉ mục tìm kiếm cho các công thức đã có từ trước phiên bản 2.
  Future<void> _backfillSearchKeys() async {
    final rows = await select(recipes).get();
    for (final r in rows) {
      final lines = await (select(
        recipeLines,
      )..where((l) => l.recipeId.equals(r.id))).get();
      String of(LineSection s) => [
        for (final l in lines)
          if (l.section == s) l.body,
      ].join('\n');
      final keys = buildSearchKeys(
        name: r.name,
        ingredients: of(LineSection.ingredient),
        steps: of(LineSection.step),
        notes: r.notes,
        source: r.source,
      );
      await (update(recipes)..where((t) => t.id.equals(r.id))).write(
        RecipesCompanion(
          searchKey: Value(keys.search),
          ingredientsKey: Value(keys.ingredients),
        ),
      );
    }
  }
}

/// Hai chỉ mục tìm kiếm của một công thức (AC-12, AC-13).
({String search, String ingredients}) buildSearchKeys({
  required String name,
  required String ingredients,
  required String steps,
  String? notes,
  String? source,
}) => (
  search: normalizeText(
    '$name\n$ingredients\n$steps\n${notes ?? ''}\n${source ?? ''}',
  ),
  ingredients: normalizeText(ingredients),
);
