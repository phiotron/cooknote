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

// ---------------------------------------------------------------------------
// Phiên bản 3: Đi chợ (F-07), Lịch thực đơn (F-08), Tủ bếp (F-09).
// Ngày lịch (ngày mua, hạn dùng, ngày của bữa) lưu dạng chữ `YYYY-MM-DD` theo
// giờ địa phương: không lệch ngày khi đổi múi giờ. Đơn vị lưu bằng tên của
// `IngredientUnit` (ví dụ `g`, `cup`, `cu`), không theo số thứ tự enum.
// ---------------------------------------------------------------------------

/// Khu vực trong cửa hàng (AC-36). [key] là khóa của khu vực mặc định
/// (`produce`, `meat`...) để từ điển tìm ra; khu vực người dùng thêm có
/// [key] null. Đổi tên không đổi [key].
@DataClassName('AisleRow')
class Aisles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().nullable()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Một danh sách đi chợ, ví dụ "Siêu thị", "Chợ" (AC-34).
@DataClassName('ShoppingListRow')
class ShoppingLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Một món trong danh sách đi chợ (AC-34..AC-37). Số lượng có cấu trúc
/// ([quantity], [unit], [unitText]) khi tách được, không thì chữ tự do
/// [amountText] ("1 ít", "vừa ăn").
@DataClassName('ShoppingItemRow')
class ShoppingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().references(ShoppingLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Khóa so khớp tên (bỏ dấu, số ít), để gộp món trùng (AC-35).
  TextColumn get nameKey => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get unitText => text().withDefault(const Constant(''))();
  TextColumn get amountText => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get aisleId => integer().nullable().references(
    Aisles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get checkedAt => dateTime().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Công thức mà một món đi chợ đến từ (AC-35). Một món gộp có thể đến từ
/// nhiều công thức. Giữ cả tên để còn hiện khi công thức đã bị xóa hẳn.
@DataClassName('ShoppingItemSourceRow')
class ShoppingItemSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId =>
      integer().references(ShoppingItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get recipeId => integer().nullable().references(
    Recipes,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get recipeName => text()();
}

/// Mỗi tên món từng thêm vào đi chợ (theo khóa so khớp): để gợi ý khi gõ,
/// "Món hay mua" (AC-34) và nhớ khu vực người dùng đã chọn (AC-36).
@DataClassName('KnownItemRow')
class KnownItems extends Table {
  TextColumn get nameKey => text()();
  TextColumn get name => text()();

  /// Khu vực người dùng đã chuyển món này vào; null là theo từ điển.
  IntColumn get aisleId => integer().nullable().references(
    Aisles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get useCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  /// Người dùng ghim vào "Món hay mua".
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  IntColumn get favoritePosition => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {nameKey};
}

/// Nguyên liệu đang có trong Tủ bếp (AC-42).
@DataClassName('PantryItemRow')
class PantryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get nameKey => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get unitText => text().withDefault(const Constant(''))();
  TextColumn get amountText => text().nullable()();
  IntColumn get aisleId => integer().nullable().references(
    Aisles,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Ngày mua `YYYY-MM-DD`.
  TextColumn get purchasedOn => text()();

  /// Hạn dùng `YYYY-MM-DD`; null là không ghi.
  TextColumn get expiresOn => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Bữa trong ngày (AC-38): mặc định Sáng, Trưa, Tối, Phụ; đổi tên, thêm,
/// bớt được. [key] là khóa của bữa mặc định (`breakfast`...), null với bữa
/// người dùng thêm.
@DataClassName('MealSlotRow')
class MealSlots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().nullable()();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Một món trong lịch thực đơn (AC-38): công thức HOẶC chữ tự do ("Ăn
/// ngoài"), khẩu phần riêng tùy chọn.
@DataClassName('MealPlanEntryRow')
@TableIndex(name: 'meal_plan_entries_date', columns: {#date})
class MealPlanEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Ngày `YYYY-MM-DD`.
  TextColumn get date => text().withLength(min: 10, max: 10)();
  IntColumn get slotId =>
      integer().references(MealSlots, #id, onDelete: KeyAction.cascade)();
  IntColumn get recipeId => integer().nullable().references(
    Recipes,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get freeText => text().nullable()();
  RealColumn get servings => real().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Thực đơn mẫu đặt tên được, ví dụ "Cơm gia đình 4 món" (AC-39).
@DataClassName('MenuTemplateRow')
class MenuTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Một món của thực đơn mẫu; [dayOffset] 0 là ngày áp, 1 là ngày sau (AC-39).
@DataClassName('MenuTemplateEntryRow')
class MenuTemplateEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId =>
      integer().references(MenuTemplates, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayOffset => integer().withDefault(const Constant(0))();
  IntColumn get slotId =>
      integer().references(MealSlots, #id, onDelete: KeyAction.cascade)();
  IntColumn get recipeId => integer().nullable().references(
    Recipes,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get freeText => text().nullable()();
  RealColumn get servings => real().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
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
    Aisles,
    ShoppingLists,
    ShoppingItems,
    ShoppingItemSources,
    KnownItems,
    PantryItems,
    MealSlots,
    MealPlanEntries,
    MenuTemplates,
    MenuTemplateEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'cooknote'));

  @override
  int get schemaVersion => 3;

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
      if (from < 3) {
        // F-07, F-08, F-09. Dữ liệu mặc định theo ngôn ngữ (khu vực, bữa,
        // danh sách đầu tiên) do `seedV3Defaults` tạo lúc mở app.
        await m.createTable(aisles);
        await m.createTable(shoppingLists);
        await m.createTable(shoppingItems);
        await m.createTable(shoppingItemSources);
        await m.createTable(knownItems);
        await m.createTable(pantryItems);
        await m.createTable(mealSlots);
        await m.createTable(mealPlanEntries);
        await m.createIndex(mealPlanEntriesDate);
        await m.createTable(menuTemplates);
        await m.createTable(menuTemplateEntries);
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
