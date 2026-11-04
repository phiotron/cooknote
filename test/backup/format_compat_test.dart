import 'dart:io';

import 'package:cooknote/src/backup/backup_format.dart';
import 'package:cooknote/src/data/category_repository.dart';
import 'package:cooknote/src/data/database.dart';
import 'package:cooknote/src/data/image_store.dart';
import 'package:cooknote/src/data/recipe_lines.dart';
import 'package:cooknote/src/data/recipe_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures.dart';

/// Mỗi phiên bản định dạng đã phát hành có một file mẫu trong
/// `test/fixtures/` và test này khôi phục TẤT CẢ các file đó (AC-55).
/// Thêm file mới khi định dạng được mở rộng; KHÔNG sửa hay xóa file cũ.
const _fixtures = {'backup_v1.cooknote': 1};

void main() {
  for (final entry in _fixtures.entries) {
    test(
      'khôi phục file mẫu ${entry.key} (định dạng ${entry.value})',
      () async {
        final file = File('test/fixtures/${entry.key}');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'thiếu file mẫu ${entry.key}',
        );

        final info = await verifyBackupFile(file);
        expect(info.formatVersion, entry.value);

        final temp = Directory.systemTemp.createTempSync('cooknote_compat_');
        addTearDown(() {
          try {
            temp.deleteSync(recursive: true);
          } on FileSystemException {
            // Không ảnh hưởng kết quả.
          }
        });
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final images = ImageStore(Directory('${temp.path}/photos'));
        final summary = await restoreBackupFile(
          db: db,
          images: images,
          file: file,
          mode: RestoreMode.replace,
        );
        expect(summary.recipesAdded, 2);

        final recipes = RecipeRepository(db, images);
        final cats = await CategoryRepository(db).getAll();
        expect(cats.map((c) => (c.name, c.depth)), [
          ('Món chính', 1),
          ('Món Việt', 2),
        ]);

        final all = await db.select(db.recipes).get();
        final pho = all.firstWhere((r) => r.name == 'Phở bò');
        final d = (await recipes.getRecipe(pho.id))!;
        expect(d.draft.servings, 4);
        expect(d.draft.servingsUnit, 'người');
        expect(d.draft.totalMinutes, 240);
        expect(d.draft.rating, 5);
        expect(d.draft.favorite, isTrue);
        expect(d.draft.difficulty, Difficulty.hard);
        expect(d.draft.ingredients, const [
          RecipeLine('Nước dùng', isHeading: true),
          RecipeLine('2 kg xương bò'),
        ]);
        expect(d.draft.steps, const [
          RecipeLine('Chần xương'),
          RecipeLine('Ninh 3 tiếng'),
        ]);
        expect(d.draft.tags, ['bò', 'Nước dùng']);
        expect(d.draft.categoryIds.length, 1);
        expect(d.cookCount, 1);
        expect(d.draft.photos.length, 1);
        expect(images.file(d.draft.photos.single).existsSync(), isTrue);
        expect(
          all.firstWhere((r) => r.name == 'Bánh flan').deletedAt,
          isNotNull,
        );
      },
    );
  }

  // Chạy một lần để tạo file mẫu: WRITE_FIXTURE=1 flutter test test/backup/format_compat_test.dart
  // Chỉ dùng khi phát hành MỘT phiên bản định dạng mới, đặt tên file mới.
  test(
    'tạo file mẫu backup_v1.cooknote',
    skip: Platform.environment['WRITE_FIXTURE'] == null,
    () async {
      final temp = Directory.systemTemp.createTempSync('cooknote_fixture_');
      final db = AppDatabase(NativeDatabase.memory());
      final images = ImageStore(Directory('${temp.path}/photos'));
      final clock = DateTime(2026, 11, 3, 9);
      final recipes = RecipeRepository(db, images, clock: () => clock);
      final cats = CategoryRepository(db);
      final main = await cats.add('Món chính');
      final viet = await cats.add('Món Việt', parentId: main);
      final src = File('${temp.path}/p.jpg')
        ..writeAsBytesSync(jpegBytes(40, 30));
      final photo = await images.importImage(src.path);
      final pho = await recipes.save(
        RecipeDraft(
          name: 'Phở bò',
          servings: 4,
          servingsUnit: 'người',
          totalMinutes: 240,
          rating: 5,
          favorite: true,
          difficulty: Difficulty.hard,
          ingredients: const [
            RecipeLine('Nước dùng', isHeading: true),
            RecipeLine('2 kg xương bò'),
          ],
          steps: const [RecipeLine('Chần xương'), RecipeLine('Ninh 3 tiếng')],
          photos: [photo],
          categoryIds: [viet],
          tags: ['bò', 'Nước dùng'],
        ),
      );
      await recipes.markCooked(pho);
      final flan = await recipes.save(const RecipeDraft(name: 'Bánh flan'));
      await recipes.moveToTrash(flan);
      final out = File('test/fixtures/backup_v1.cooknote');
      out.parent.createSync(recursive: true);
      await createBackupFile(
        db: db,
        images: images,
        out: out,
        appVersion: '1.0.0',
        now: DateTime.utc(2026, 11, 4, 3),
      );
      await db.close();
    },
  );
}
