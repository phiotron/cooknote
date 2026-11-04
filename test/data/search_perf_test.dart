import 'dart:io';

import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_query.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Đo trên máy tính phát triển, KHÔNG thay cho đo trên điện thoại (SPEC 5b:
/// kết quả tìm kiếm hiện không quá 300 ms với 5.000 công thức).
void main() {
  test('tìm và lọc trong 5.000 công thức (AC-12, NFR)', () async {
    final temp = Directory.systemTemp.createTempSync('cooknote_perf_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = RecipeRepository(db, ImageStore(Directory('${temp.path}/p')));

    const dishes = ['Phở bò', 'Bún chả', 'Bánh xèo', 'Canh chua', 'Gà nướng'];
    final now = DateTime(2026, 11, 3);
    await db.batch((b) {
      for (var i = 0; i < 5000; i++) {
        final name = '${dishes[i % dishes.length]} số $i';
        final ingredients = 'thịt bò $i\nhành tím\nnước mắm\ntiêu';
        final steps =
            'Ướp thịt rồi nấu nhỏ lửa khoảng ${i % 90} phút\nBày ra đĩa';
        final keys = buildSearchKeys(
          name: name,
          ingredients: ingredients,
          steps: steps,
          notes: 'Món số $i của gia đình',
        );
        b.insert(
          db.recipes,
          RecipesCompanion.insert(
            id: Value(i + 1),
            name: name,
            createdAt: now,
            updatedAt: now.add(Duration(minutes: i)),
            searchKey: Value(keys.search),
            ingredientsKey: Value(keys.ingredients),
            rating: Value(i % 6),
          ),
        );
      }
    });

    Future<int> time(RecipeQuery q, int expected) async {
      final sw = Stopwatch()..start();
      final result = await repo.search(q);
      sw.stop();
      expect(result.length, expected);
      return sw.elapsedMilliseconds;
    }

    final ms = [
      await time(const RecipeQuery(), 5000),
      await time(const RecipeQuery(text: 'pho bo'), 1000),
      await time(const RecipeQuery(text: 'so 4999'), 1),
      await time(const RecipeQuery(minRating: 5, text: 'banh'), 167),
    ];
    // ignore: avoid_print
    print(
      '5.000 công thức, ms (tất cả / "pho bo" / "so 4999" / lọc kết hợp): $ms',
    );
    // Ngưỡng rộng để không hỏng thất thường; con số thật nằm trong TESTING.md.
    for (final m in ms) {
      expect(m, lessThan(2000));
    }
  });
}
