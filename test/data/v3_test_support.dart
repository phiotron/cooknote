import 'dart:io';

import 'package:cooknote/src/data/aisle_repository.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/meal_plan_repository.dart';
import 'package:cooknote/src/data/pantry_repository.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:cooknote/src/data/shopping_repository.dart';
import 'package:cooknote/src/data/v3_defaults.dart';
import 'package:drift/native.dart';

/// Bộ kho dữ liệu phiên bản 3 trên cơ sở dữ liệu trong bộ nhớ, ngày cố định.
class V3Env {
  V3Env._(this.temp, this.db, this.now);

  static Future<V3Env> create({
    String language = 'vi',
    DateTime? now,
    bool seed = true,
  }) async {
    final temp = Directory.systemTemp.createTempSync('cooknote_v3_');
    final env = V3Env._(
      temp,
      AppDatabase(NativeDatabase.memory()),
      now ?? DateTime(2026, 11, 5, 9),
    );
    if (seed) await seedV3Defaults(env.db, language, clock: env.clock);
    return env;
  }

  final Directory temp;
  final AppDatabase db;
  DateTime now;

  DateTime clock() => now;

  late final images = ImageStore(Directory('${temp.path}/photos'));
  late final recipes = RecipeRepository(db, images, clock: clock);
  late final aisles = AisleRepository(db);
  late final pantry = PantryRepository(db, clock: clock, aisles: aisles);
  late final shopping = ShoppingRepository(
    db,
    clock: clock,
    aisles: aisles,
    pantry: pantry,
  );
  late final plan = MealPlanRepository(db, clock: clock, pantry: pantry);

  /// Lưu một công thức có các dòng nguyên liệu [ingredients].
  Future<int> recipe(
    String name,
    List<String> ingredients, {
    double? servings,
    int? totalMinutes,
  }) => recipes.save(
    RecipeDraft(
      name: name,
      servings: servings,
      totalMinutes: totalMinutes,
      ingredients: [for (final l in ingredients) RecipeLine(l)],
    ),
  );

  Future<void> dispose() async {
    await db.close();
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException {
      // Không ảnh hưởng kết quả.
    }
  }
}
