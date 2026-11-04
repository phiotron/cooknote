import 'dart:io';

import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'lưu xong đóng cơ sở dữ liệu, mở lại vẫn còn công thức (AC-04)',
    () async {
      final temp = Directory.systemTemp.createTempSync('cooknote_db_');
      addTearDown(() => temp.deleteSync(recursive: true));
      final file = File('${temp.path}/cooknote.sqlite');
      final images = ImageStore(Directory('${temp.path}/photos'));

      final first = AppDatabase(NativeDatabase(file));
      final id = await RecipeRepository(first, images).save(
        const RecipeDraft(
          name: 'Canh chua',
          ingredients: [RecipeLine('1 con cá lóc')],
          steps: [RecipeLine('Nấu nước')],
        ),
      );
      await first.close();

      final second = AppDatabase(NativeDatabase(file));
      addTearDown(second.close);
      final r = await RecipeRepository(second, images).getRecipe(id);
      expect(r!.draft.name, 'Canh chua');
      expect(r.draft.ingredients.single.text, '1 con cá lóc');
    },
  );
}
